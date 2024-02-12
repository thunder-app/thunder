import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/cubit/create_post_cubit.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/post/utils/navigate_post.dart';

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
  Timer? _draftTimer;

  /// Whether or not to show the preview for the post from the raw markdown
  bool showPreview = false;

  /// Keeps the last known state of the keyboard. This is used to re-open the keyboard when the preview is dismissed
  bool wasKeyboardVisible = false;

  /// Whether or not the submit button is disabled
  bool isSubmitButtonDisabled = true;

  /// Whether or not the post is marked as NSFW
  bool isNSFW = false;

  /// The shared link for the post. This is used to determine any cross posts
  String url = "";

  /// The error message for the shared link if available
  String? urlError;

  /// The id of the community that the post will be created in
  int? communityId;

  int? languageId;

  /// The [CommunityView] associated with the post. This is used to display the community information
  CommunityView? communityView;

  /// A list of cross posts for the given post. This is determined by the URL parameter
  List<PostView> crossPosts = [];

  /// The corresponding controllers for the title, body and url text fields
  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();

  /// The focus node for the body. This is used to keep track of the position of the cursor when toggling preview
  final FocusNode _bodyFocusNode = FocusNode();

  /// The keyboard visibility controller used to determine if the keyboard is visible at a given time
  final keyboardVisibilityController = KeyboardVisibilityController();

  /// Used for restoring and saving drafts
  SharedPreferences? sharedPreferences;

  final imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

    communityId = widget.communityId;
    communityView = widget.communityView;

    // Set up any text controller listeners
    _titleTextController.addListener(() {
      draftPost.title = _titleTextController.text;
      _validateSubmission();
    });

    _urlTextController.addListener(() {
      url = _urlTextController.text;
      draftPost.url = _urlTextController.text;

      _validateSubmission();
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
      _getDataFromLink(updateTitleField: _titleTextController.text.isEmpty);

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
      languageId = widget.postView!.post.languageId;

      return;
    }

    // Finally, if there is no pre-populated fields, then we retrieve the most recent draft
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _restoreExistingDraft();
    });
  }

  @override
  void dispose() {
    _bodyTextController.dispose();
    _titleTextController.dispose();
    _urlTextController.dispose();
    _bodyFocusNode.dispose();

    FocusManager.instance.primaryFocus?.unfocus();

    _draftTimer?.cancel();

    if (draftPost.isNotEmpty && draftPost.saveAsDraft) {
      sharedPreferences?.setString(draftId, jsonEncode(draftPost.toJson()));
      showSnackbar(l10n.postSavedAsDraft);
    } else {
      sharedPreferences?.remove(draftId);
    }

    super.dispose();
  }

  /// Attempts to restore an existing draft of a post
  void _restoreExistingDraft() async {
    sharedPreferences = (await UserPreferences.instance).sharedPreferences;

    if (widget.postView != null) {
      draftId = '${LocalSettings.draftsCache.name}-post-edit-${widget.postView!.post.id}';
    } else if (widget.communityId != null) {
      draftId = '${LocalSettings.draftsCache.name}-post-create-${widget.communityId}';
    } else if (widget.communityView != null) {
      draftId = '${LocalSettings.draftsCache.name}-post-create-${widget.communityView!.community.id}';
    } else {
      draftId = '${LocalSettings.draftsCache.name}-post-create-general';
    }

    String? draftPostJson = sharedPreferences?.getString(draftId);

    if (draftPostJson != null) {
      draftPost = DraftPost.fromJson(jsonDecode(draftPostJson));

      _titleTextController.text = draftPost.title ?? '';
      _urlTextController.text = draftPost.url ?? '';
      _bodyTextController.text = draftPost.text ?? '';
    }

    _draftTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (draftPost.isNotEmpty && draftPost.saveAsDraft) {
        sharedPreferences?.setString(draftId, jsonEncode(draftPost.toJson()));
      } else {
        sharedPreferences?.remove(draftId);
      }
    });

    if (context.mounted && draftPost.isNotEmpty) {
      showSnackbar(
        AppLocalizations.of(context)!.restoredPostFromDraft,
        trailingIcon: Icons.delete_forever_rounded,
        trailingIconColor: Theme.of(context).colorScheme.errorContainer,
        trailingAction: () {
          sharedPreferences?.remove(draftId);
          _titleTextController.clear();
          _urlTextController.clear();
          _bodyTextController.clear();
        },
      );
    }
  }

  /// Attempts to get the suggested title for a given link
  Future<String?> _getDataFromLink({String? link, bool updateTitleField = true}) async {
    link ??= widget.url;

    if (link?.isNotEmpty == true) {
      try {
        final WebInfo info = await LinkPreview.scrapeFromURL(link!);
        if (updateTitleField) _titleTextController.text = info.title;
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

          if (state.status == CreatePostStatus.error && state.message != null) {
            showSnackbar(state.message!);
            context.read<CreatePostCubit>().clearMessage();
          }

          switch (state.status) {
            case CreatePostStatus.imageUploadSuccess:
              _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, "![](${state.imageUrl})");
              break;
            case CreatePostStatus.postImageUploadSuccess:
              _urlTextController.text = state.imageUrl ?? '';
              break;
            case CreatePostStatus.imageUploadFailure:
            case CreatePostStatus.postImageUploadFailure:
              showSnackbar(l10n.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
            default:
              break;
          }
        },
        builder: (context, state) {
          return KeyboardDismissOnTap(
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.postView != null ? l10n.editPost : l10n.createPost),
                toolbarHeight: 70.0,
                centerTitle: false,
                actions: [
                  state.status == CreatePostStatus.submitting
                      ? const Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            onPressed: isSubmitButtonDisabled
                                ? null
                                : () {
                                    draftPost.saveAsDraft = false;

                                    context.read<CreatePostCubit>().createOrEditPost(
                                          communityId: communityId!,
                                          name: _titleTextController.text,
                                          body: _bodyTextController.text,
                                          nsfw: isNSFW,
                                          url: url,
                                          postIdBeingEdited: widget.postView?.post.id,
                                          languageId: languageId,
                                        );
                                  },
                            icon: Icon(
                              widget.postView != null ? Icons.edit_rounded : Icons.send_rounded,
                              semanticLabel: widget.postView != null ? l10n.editPost : l10n.createPost,
                            ),
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
                            const SizedBox(height: 4.0),
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
                                return ListTile(
                                  title: Text(itemData),
                                  subtitle: Text(l10n.suggestedTitle),
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
                                    if (state.status == CreatePostStatus.postImageUploadInProgress) return;

                                    String imagePath = await selectImageToUpload();
                                    if (context.mounted) context.read<CreatePostCubit>().uploadImage(imagePath, isPostImage: true);
                                  },
                                  icon: state.status == CreatePostStatus.postImageUploadInProgress
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: LanguageSelector(
                                    languageId: languageId,
                                    onLanguageSelected: (Language? language) {
                                      setState(() => languageId = language?.id);
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(l10n.postNSFW),
                                    const SizedBox(width: 10),
                                    Switch(
                                      value: isNSFW,
                                      onChanged: (bool value) => setState(() => isNSFW = value),
                                    ),
                                  ],
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
                              imageIsLoading: state.status == CreatePostStatus.imageUploadInProgress,
                              customImageButtonAction: () async {
                                if (state.status == CreatePostStatus.imageUploadInProgress) return;

                                String imagePath = await selectImageToUpload();
                                if (context.mounted) context.read<CreatePostCubit>().uploadImage(imagePath, isPostImage: false);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                            child: IconButton(
                              onPressed: () {
                                if (!showPreview) {
                                  setState(() => wasKeyboardVisible = keyboardVisibilityController.isVisible);
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }

                                setState(() => showPreview = !showPreview);
                                if (!showPreview && wasKeyboardVisible) _bodyFocusNode.requestFocus();
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

/// Creates a widget which displays a preview of a pre-selected language, with the ability to change the selected language
///
/// Passing in [languageId] will set the initial state of the widget to display that given language.
/// A callback function [onLanguageSelected] will be triggered whenever a new language is selected from the dropdown.
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({
    super.key,
    required this.languageId,
    required this.onLanguageSelected,
  });

  /// The initial language id to be passed in
  final int? languageId;

  /// A callback function to trigger whenever a language is selected from the dropdown
  final Function(Language?) onLanguageSelected;

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late int? _languageId;
  late Language? _language;

  @override
  void initState() {
    super.initState();
    _languageId = widget.languageId;

    // Determine the language from the languageId
    List<Language> languages = context.read<AuthBloc>().state.getSiteResponse?.allLanguages ?? [];
    _language = languages.firstWhereOrNull((Language language) => language.id == _languageId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Transform.translate(
      offset: const Offset(-8, 0),
      child: InkWell(
        onTap: () {
          showLanguageInputDialog(
            context,
            title: l10n.language,
            onLanguageSelected: (language) {
              if (language.id == -1) {
                setState(() => _languageId = _language = null);
                widget.onLanguageSelected(null);
              } else {
                setState(() {
                  _languageId = language.id;
                  _language = language;
                });
                widget.onLanguageSelected(language);
              }
            },
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
          child: Text(
            '${l10n.language}: ${_language?.name ?? l10n.selectLanguage}',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
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
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
          child: Row(
            children: [
              CommunityAvatar(community: _communityView?.community, radius: 16),
              const SizedBox(width: 12),
              _communityId != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_communityView?.community.title} '),
                        FutureBuilder(
                          future: getLemmyCommunity(_communityView?.community.actorId ?? ''),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? '',
                              style: theme.textTheme.bodySmall,
                            );
                          },
                        ),
                      ],
                    )
                  : SizedBox(
                      height: 36,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.selectCommunity,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.error,
                          ),
                        ),
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
