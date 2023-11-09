import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/cubit/create_post_cubit.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';

class CreatePostPage extends StatefulWidget {
  final int? communityId;
  final CommunityView? communityView;

  /// Whether or not to pre-populate the post with the [title], [text], [image] and/or [url]
  final bool? prePopulated;

  /// Used to pre-populate the post title
  final String? title;

  /// Used to pre-populate the post body
  final String? text;

  /// Used to pre-populate the image of the post
  final File? image;

  /// Used to pre-populate the shared link for the post
  final String? url;

  /// [postView] is passed in when editing an existing post
  final PostView? postView;

  /// Callback function that is triggered whenever the post is successfully created or updated
  final Function(PostViewMedia postViewMedia)? onPostSuccess;

  const CreatePostPage({
    super.key,
    required this.communityId,
    this.communityView,
    this.image,
    this.title,
    this.text,
    this.url,
    this.prePopulated = false,
    this.postView,
    this.onPostSuccess,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  /// Holds the draft id associated with the post. This id is determined by the input parameters passed in.
  /// If [postView] is passed in, the id will be in the form 'drafts_cache-post-edit-{postView.post.id}'
  /// If [communityId] is passed in, the id will be in the form 'drafts_cache-post-create-{communityId}'
  /// If [communityView] is passed in, the id will be in the form 'drafts_cache-post-create-{communityView.community.id}'
  /// If none of these are passed in, the id will be in the form 'drafts_cache-post-create-general'
  String draftId = '';

  /// Holds the current draft for the post.
  DraftPost draftPost = DraftPost();

  /// Timer for saving the current draft to local storage
  late Timer _draftTimer;

  /// Whether or not to show the preview for the post from the raw markdown
  bool showPreview = false;

  /// Status of image upload when uploading to the post body
  bool imageUploading = false;

  /// Status of image upload when uploading to the post URL
  bool postImageUploading = false;

  bool isSubmitButtonDisabled = true;
  bool isNSFW = false;
  String url = "";
  String? urlError;
  DraftPost newDraftPost = DraftPost();
  int? communityId;
  CommunityView? communityView;
  List<PostView> crossPosts = [];

  /// The corresponding controllers for the title, body and url text fields
  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();

  final FocusNode _bodyFocusNode = FocusNode();
  final imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

    communityId = widget.communityId;
    communityView = widget.communityView;

    // Set up any text controller listeners
    _titleTextController.addListener(() {
      _validateSubmission();
      draftPost.title = _titleTextController.text;
    });

    _urlTextController.addListener(() {
      _validateSubmission();
      url = _urlTextController.text;
      draftPost.url = _urlTextController.text;

      debounce(const Duration(milliseconds: 1000), _updatePreview, [url]);
    });

    _bodyTextController.addListener(() {
      draftPost.text = _bodyTextController.text;
    });

    // Logic for pre-populating the post with the given fields
    if (widget.prePopulated == true) {
      _titleTextController.text = widget.title ?? '';
      _bodyTextController.text = widget.text ?? '';
      _urlTextController.text = widget.url ?? '';
      _getDataFromLink();

      if (widget.image != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          uploadImage(
            context,
            imageBloc,
            postImage: true,
            imagePath: widget.image?.path,
          );
        });
      }

      return;
    }

    // Logic for pre-populating the post with the [postView] for edits
    if (widget.postView != null) {
      _titleTextController.text = widget.postView!.post.name;
      _urlTextController.text = widget.postView!.post.url ?? '';
      _bodyTextController.text = widget.postView!.post.body ?? '';
      isNSFW = widget.postView!.post.nsfw;

      return;
    }

    // Finally, if there is no pre-populated fields, then we retrieve the most recent draft
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _restoreExistingDraft();
    });
  }

  @override
  void dispose() async {
    _bodyTextController.dispose();
    _titleTextController.dispose();
    _urlTextController.dispose();
    _bodyFocusNode.dispose();

    FocusManager.instance.primaryFocus?.unfocus();

    _draftTimer.cancel();

    SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

    if (draftPost.isNotEmpty && draftPost.saveAsDraft) {
      prefs.setString(draftId, jsonEncode(draftPost.toJson()));
      if (context.mounted) showSnackbar(context, AppLocalizations.of(context)!.postSavedAsDraft);
    } else {
      prefs.remove(draftId);
    }

    super.dispose();
  }

  /// Attempts to restore an existing draft of a post
  void _restoreExistingDraft() async {
    SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

    if (widget.postView != null) {
      draftId = '${LocalSettings.draftsCache.name}-post-edit-${widget.postView!.post.id}';
    } else if (widget.communityId != null) {
      draftId = '${LocalSettings.draftsCache.name}-post-create-${widget.communityId}';
    } else if (widget.communityView != null) {
      draftId = '${LocalSettings.draftsCache.name}-post-create-${widget.communityView!.community.id}';
    } else {
      draftId = '${LocalSettings.draftsCache.name}-post-create-general';
    }

    String? draftPostJson = prefs.getString(draftId);

    if (draftPostJson != null) {
      draftPost = DraftPost.fromJson(jsonDecode(draftPostJson));

      _titleTextController.text = draftPost.title ?? '';
      _urlTextController.text = draftPost.url ?? '';
      _bodyTextController.text = draftPost.text ?? '';
    }

    _draftTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (draftPost.isNotEmpty && draftPost.saveAsDraft) {
        prefs.setString(draftId, jsonEncode(draftPost.toJson()));
      } else {
        prefs.remove(draftId);
      }
    });

    if (context.mounted && draftPost.isNotEmpty) {
      showSnackbar(
        context,
        AppLocalizations.of(context)!.restoredPostFromDraft,
        trailingIcon: Icons.delete_forever_rounded,
        trailingIconColor: Theme.of(context).colorScheme.error,
        trailingAction: () {
          prefs.remove(draftId);
          _titleTextController.clear();
          _urlTextController.clear();
          _bodyTextController.clear();
        },
      );
    }
  }

  Future<String?> _getDataFromLink({String? link, bool updateTitleField = true}) async {
    link ??= widget.url;
    if (link?.isNotEmpty == true) {
      try {
        final WebInfo info = await LinkPreview.scrapeFromURL(link!);
        if (updateTitleField) {
          _titleTextController.text = info.title;
        }
        return info.title;
      } catch (e) {
        // It's ok if we can't scrape. The user will just have to supply the title themselves.
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => CreatePostCubit(),
      child: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state.status == CreatePostStatus.success && state.postViewMedia != null) {
            widget.onPostSuccess?.call(state.postViewMedia!);
            Navigator.of(context).pop();
          }

          switch (state.status) {
            case CreatePostStatus.imageUploadSuccess:
              _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, "![](${state.imageUrl})");
              setState(() => imageUploading = false);
              break;
            case CreatePostStatus.postImageUploadSuccess:
              _urlTextController.text = state.imageUrl ?? '';
              setState(() => postImageUploading = false);
              break;
            case CreatePostStatus.imageUploadInProgress:
              setState(() => imageUploading = true);
              break;
            case CreatePostStatus.postImageUploadInProgress:
              setState(() => postImageUploading = true);
              break;
            case CreatePostStatus.imageUploadFailure:
            case CreatePostStatus.postImageUploadFailure:
              showSnackbar(context, l10n.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
              setState(() {
                imageUploading = false;
                postImageUploading = false;
              });
            default:
              break;
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              // Dismiss keyboard when we go tap anywhere on the screen
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.postView != null ? l10n.editPost : l10n.createPost),
                toolbarHeight: 70.0,
                centerTitle: false,
                actions: [
                  IconButton(
                    onPressed: isSubmitButtonDisabled
                        ? null
                        : () {
                            newDraftPost.saveAsDraft = false;
                            context.read<CreatePostCubit>().createOrEditPost(
                                  communityId: communityId!,
                                  name: _titleTextController.text,
                                  body: _bodyTextController.text,
                                  nsfw: isNSFW,
                                  url: url,
                                  postIdBeingEdited: widget.postView?.post.id,
                                );
                          },
                    icon: Icon(
                      Icons.send_rounded,
                      semanticLabel: l10n.createPost,
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            CommunitySelector(
                              communityId: communityId,
                              communityView: communityView,
                              onCommunitySelected: (CommunityView cv) {
                                setState(() {
                                  communityId = cv.community.id;
                                  communityView = cv;
                                });
                                _validateSubmission();
                              },
                            ),
                            const UserIndicator(),
                            const SizedBox(height: 12.0),
                            TypeAheadField<String>(
                              suggestionsCallback: (String pattern) async {
                                if (pattern.isEmpty) {
                                  String? linkTitle = await _getDataFromLink(link: _urlTextController.text, updateTitleField: false);
                                  if (linkTitle?.isNotEmpty == true) {
                                    return [linkTitle!];
                                  }
                                }
                                return const Iterable.empty();
                              },
                              itemBuilder: (BuildContext context, String itemData) {
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(l10n.useSuggestedTitle(itemData)),
                                );
                              },
                              onSuggestionSelected: (String suggestion) {
                                _titleTextController.text = suggestion;
                              },
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _titleTextController,
                                decoration: InputDecoration(hintText: l10n.postTitle),
                              ),
                              hideOnEmpty: true,
                              hideOnLoading: true,
                              hideOnError: true,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _urlTextController,
                              decoration: InputDecoration(
                                hintText: l10n.postURL,
                                errorText: urlError,
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (postImageUploading) return;

                                    String imagePath = await selectImageToUpload();
                                    if (context.mounted) context.read<CreatePostCubit>().uploadImage(imagePath, isPostImage: true);
                                  },
                                  icon: postImageUploading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        )
                                      : Icon(Icons.image, semanticLabel: l10n.uploadImage),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Visibility(
                              visible: url.isNotEmpty,
                              child: LinkPreviewCard(
                                hideNsfw: false,
                                scrapeMissingPreviews: false,
                                originURL: url,
                                mediaURL: isImageUrl(url) ? url : null,
                                mediaHeight: null,
                                mediaWidth: null,
                                showFullHeightImages: false,
                                edgeToEdgeImages: false,
                                viewMode: ViewMode.comfortable,
                                postId: null,
                                markPostReadOnMediaView: false,
                                isUserLoggedIn: true,
                              ),
                            ),
                            if (crossPosts.isNotEmpty && widget.postView == null)
                              Visibility(
                                visible: url.isNotEmpty,
                                child: CrossPosts(
                                  crossPosts: crossPosts,
                                  isNewPost: true,
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(child: Text(l10n.postNSFW)),
                                Switch(
                                  value: isNSFW,
                                  onChanged: (bool value) => setState(() => isNSFW = value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            showPreview
                                ? Container(
                                    constraints: const BoxConstraints(minWidth: double.infinity),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.all(12),
                                    child: SingleChildScrollView(
                                      child: CommonMarkdownBody(
                                        body: _bodyTextController.text,
                                        isComment: true,
                                      ),
                                    ),
                                  )
                                : MarkdownTextInputField(
                                    controller: _bodyTextController,
                                    focusNode: _bodyFocusNode,
                                    label: l10n.postBody,
                                    minLines: 8,
                                    maxLines: null,
                                    textStyle: theme.textTheme.bodyLarge,
                                  ),
                          ]),
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: MarkdownButtons(
                              controller: _bodyTextController,
                              focusNode: _bodyFocusNode,
                              actions: const [
                                MarkdownType.image,
                                MarkdownType.link,
                                MarkdownType.bold,
                                MarkdownType.italic,
                                MarkdownType.blockquote,
                                MarkdownType.strikethrough,
                                MarkdownType.title,
                                MarkdownType.list,
                                MarkdownType.separator,
                                MarkdownType.code,
                                MarkdownType.username,
                                MarkdownType.community,
                              ],
                              customTapActions: {
                                MarkdownType.username: () {
                                  showUserInputDialog(context, title: l10n.username, onUserSelected: (person) {
                                    _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                        '[@${person.person.name}@${fetchInstanceNameFromUrl(person.person.actorId)}](${person.person.actorId})');
                                  });
                                },
                                MarkdownType.community: () {
                                  showCommunityInputDialog(context, title: l10n.community, onCommunitySelected: (community) {
                                    _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                        '[@${community.community.title}@${fetchInstanceNameFromUrl(community.community.actorId)}](${community.community.actorId})');
                                  });
                                },
                              },
                              imageIsLoading: imageUploading,
                              customImageButtonAction: () async {
                                if (imageUploading) return;

                                String imagePath = await selectImageToUpload();
                                if (context.mounted) context.read<CreatePostCubit>().uploadImage(imagePath, isPostImage: false);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                            child: IconButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() => showPreview = !showPreview);
                                if (!showPreview) {
                                  _bodyFocusNode.requestFocus();
                                }
                              },
                              icon: Icon(
                                showPreview ? Icons.visibility_outlined : Icons.visibility,
                                color: theme.colorScheme.onSecondary,
                                semanticLabel: l10n.postTogglePreview,
                              ),
                              visualDensity: const VisualDensity(horizontal: 1.0, vertical: 1.0),
                              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _updatePreview(String text) async {
    if (url == text) {
      SearchResponse? searchResponse;
      try {
        // Fetch cross-posts
        final Account? account = await fetchActiveProfileAccount();
        searchResponse = await LemmyClient.instance.lemmyApiV3.run(Search(
          q: url,
          type: SearchType.url,
          sort: SortType.topAll,
          listingType: ListingType.all,
          limit: 20,
          auth: account?.jwt,
        ));
      } finally {
        setState(() {
          crossPosts = searchResponse?.posts ?? [];
        });
      }
    }
  }

  void _validateSubmission() {
    final Uri? parsedUrl = Uri.tryParse(_urlTextController.text);

    if (isSubmitButtonDisabled) {
      // It's disabled, check if we can enable it.
      if (_titleTextController.text.isNotEmpty && parsedUrl != null && communityId != null) {
        setState(() {
          isSubmitButtonDisabled = false;
          urlError = null;
        });
      }
    } else {
      // It's enabled, check if we need to disable it.
      if (_titleTextController.text.isEmpty || parsedUrl == null || communityId == null) {
        setState(() {
          isSubmitButtonDisabled = true;
          urlError = parsedUrl == null ? AppLocalizations.of(context)!.notValidUrl : null;
        });
      }
    }
  }
}

/// Creates a widget which displays a preview of a pre-selected community, with the ability to change the selected community
///
/// Passing in either [communityId] or [communityView] will set the initial state of the widget to display that given community.
/// A callback function [onCommunitySelected] will be triggered whenever a new community is selected from the dropdown.
class CommunitySelector extends StatefulWidget {
  const CommunitySelector({
    super.key,
    this.communityId,
    this.communityView,
    required this.onCommunitySelected,
  });

  /// The initial community id to be passed in
  final int? communityId;

  /// The initial [CommunityView] to be passed in
  final CommunityView? communityView;

  /// A callback function to trigger whenever a community is selected from the dropdown
  final Function(CommunityView) onCommunitySelected;

  @override
  State<CommunitySelector> createState() => _CommunitySelectorState();
}

class _CommunitySelectorState extends State<CommunitySelector> {
  int? _communityId;
  CommunityView? _communityView;

  @override
  void initState() {
    super.initState();

    _communityId = widget.communityId;
    _communityView = widget.communityView;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accountState = context.read<AccountBloc>().state;

    return Transform.translate(
      offset: const Offset(-8, 0),
      child: InkWell(
        onTap: () {
          showCommunityInputDialog(
            context,
            title: l10n.community,
            onCommunitySelected: (cv) {
              setState(() {
                _communityId = cv.community.id;
                _communityView = cv;
              });

              widget.onCommunitySelected(cv);
            },
            emptySuggestions: accountState.subsciptions,
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
          child: Row(
            children: [
              CommunityIcon(community: _communityView?.community, radius: 16),
              const SizedBox(width: 12),
              _communityId != null
                  ? Text(
                      '${_communityView?.community.name} '
                      '· ${fetchInstanceNameFromUrl(_communityView?.community.actorId)}',
                      style: theme.textTheme.titleSmall,
                    )
                  : Text(
                      l10n.selectCommunity,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.error,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class DraftPost {
  String? title;
  String? url;
  String? text;
  bool saveAsDraft = true;

  DraftPost({this.title, this.url, this.text});

  Map<String, dynamic> toJson() => {'title': title, 'url': url, 'text': text};

  static fromJson(Map<String, dynamic> json) => DraftPost(title: json['title'], url: json['url'], text: json['text']);

  bool get isNotEmpty => title?.isNotEmpty == true || url?.isNotEmpty == true || text?.isNotEmpty == true;
}
