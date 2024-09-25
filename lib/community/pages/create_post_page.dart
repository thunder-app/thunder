// Dart imports
import 'dart:async';
import 'dart:io';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:markdown_editor/markdown_editor.dart';

// Project imports
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/models/draft.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/drafts/draft_type.dart';
import 'package:thunder/post/cubit/create_post_cubit.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/cross_posts.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/language_selector.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/utils/restore_user.dart';
import 'package:thunder/user/widgets/user_selector.dart';
import 'package:thunder/utils/colors.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/media/image.dart';

class CreatePostPage extends StatefulWidget {
  final int? communityId;
  final CommunityView? communityView;

  /// Whether or not to pre-populate the post with the [title], [text], [image], [url], and/or [customThumbnail]
  final bool? prePopulated;

  /// Used to pre-populate the post title
  final String? title;

  /// Used to pre-populate the post body
  final String? text;

  /// Used to pre-populate the image of the post
  final File? image;

  /// Used to pre-populate the shared link for the post
  final String? url;

  /// Used to pre-populate the custom thumbnail for the post
  final String? customThumbnail;

  /// [postView] is passed in when editing an existing post
  final PostView? postView;

  /// Callback function that is triggered whenever the post is successfully created or updated
  final Function(PostViewMedia postViewMedia, bool userChanged)? onPostSuccess;

  const CreatePostPage({
    super.key,
    required this.communityId,
    this.communityView,
    this.image,
    this.title,
    this.text,
    this.url,
    this.customThumbnail,
    this.prePopulated = false,
    this.postView,
    this.onPostSuccess,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  /// Holds the draft type associated with the post. This type is determined by the input parameters passed in.
  /// If [postView] is passed in, this will be a [DraftType.postEdit].
  /// If [communityId] or [communityView] is passed in, this will be a [DraftType.postCreate].
  /// Otherwise it will be a [DraftType.postCreateGeneral].
  late DraftType draftType;

  /// The ID of the post we are editing, to find a corresponding draft, if any
  int? draftExistingId;

  /// The ID of the community we're replying to, to find a corresponding draft, if any
  int? draftReplyId;

  /// Whether to save this post as a draft
  bool saveDraft = true;

  /// Timer for saving the current draft
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

  /// The custom thumbnail for this post.
  String? customThumbnail;

  /// The error message for the shared link if available
  String? urlError;

  /// The error message for the custom thumbnail if available
  String? customThumbnailError;

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
  final TextEditingController _customThumbnailTextController = TextEditingController();

  /// The focus node for the body. This is used to keep track of the position of the cursor when toggling preview
  final FocusNode _bodyFocusNode = FocusNode();

  /// The keyboard visibility controller used to determine if the keyboard is visible at a given time
  final keyboardVisibilityController = KeyboardVisibilityController();

  final imageBloc = ImageBloc();

  Account? originalUser;
  bool userChanged = false;

  @override
  void initState() {
    super.initState();

    communityId = widget.communityId;
    communityView = widget.communityView;

    // Set up any text controller listeners
    _titleTextController.addListener(() {
      _validateSubmission();
    });

    _urlTextController.addListener(() {
      url = _urlTextController.text;
      _validateSubmission();
      debounce(const Duration(milliseconds: 1000), _updatePreview, [url]);
    });

    _customThumbnailTextController.addListener(() {
      customThumbnail = _customThumbnailTextController.text;
      _validateSubmission();
      debounce(const Duration(milliseconds: 1000), _updatePreview, [customThumbnail]);
    });

    // Logic for pre-populating the post with the given fields
    if (widget.prePopulated == true) {
      _titleTextController.text = widget.title ?? '';
      _bodyTextController.text = widget.text ?? '';
      _urlTextController.text = widget.url ?? '';
      _customThumbnailTextController.text = widget.customThumbnail ?? '';
      _getDataFromLink(updateTitleField: _titleTextController.text.isEmpty);

      if (widget.image != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (context.mounted) context.read<CreatePostCubit>().uploadImages([widget.image!.path], isPostImage: true);
        });
      }

      return;
    }

    // Logic for pre-populating the post with the [postView] for edits
    if (widget.postView != null) {
      _titleTextController.text = widget.postView!.post.name;
      _urlTextController.text = widget.postView!.post.url ?? '';
      _customThumbnailTextController.text = widget.postView!.post.thumbnailUrl ?? '';
      _bodyTextController.text = widget.postView!.post.body ?? '';
      isNSFW = widget.postView!.post.nsfw;
      languageId = widget.postView!.post.languageId;
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
    _customThumbnailTextController.dispose();
    _bodyFocusNode.dispose();

    FocusManager.instance.primaryFocus?.unfocus();

    _draftTimer?.cancel();

    Draft draft = _generateDraft();

    if (draft.isPostNotEmpty && saveDraft && _draftDiffersFromEdit(draft)) {
      Draft.upsertDraft(draft);
      showSnackbar(l10n.postSavedAsDraft);
    } else {
      Draft.deleteDraft(draftType, draftExistingId, draftReplyId);
    }

    super.dispose();
  }

  /// Attempts to restore an existing draft of a post
  void _restoreExistingDraft() async {
    if (widget.postView != null) {
      draftType = DraftType.postEdit;
      draftExistingId = widget.postView?.post.id;
    } else if (widget.communityId != null) {
      draftType = DraftType.postCreate;
      draftReplyId = widget.communityId;
    } else if (widget.communityView != null) {
      draftType = DraftType.postCreate;
      draftReplyId = widget.communityView!.community.id;
    } else {
      draftType = DraftType.postCreateGeneral;
    }

    Draft? draft = await Draft.fetchDraft(draftType, draftExistingId, draftReplyId);

    if (draft != null) {
      _titleTextController.text = draft.title ?? '';
      _urlTextController.text = draft.url ?? '';
      _customThumbnailTextController.text = draft.customThumbnail ?? '';
      _bodyTextController.text = draft.body ?? '';
    }

    _draftTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      Draft draft = _generateDraft();
      if (draft.isPostNotEmpty && saveDraft && _draftDiffersFromEdit(draft)) {
        Draft.upsertDraft(draft);
      } else {
        Draft.deleteDraft(draftType, draftExistingId, draftReplyId);
      }
    });

    if (context.mounted && draft?.isPostNotEmpty == true && _draftDiffersFromEdit(draft!)) {
      showSnackbar(
        AppLocalizations.of(context)!.restoredPostFromDraft,
        trailingIcon: Icons.delete_forever_rounded,
        trailingIconColor: Theme.of(context).colorScheme.errorContainer,
        trailingAction: () {
          Draft.deleteDraft(draftType, draftExistingId, draftReplyId);
          _titleTextController.text = widget.postView?.post.name ?? '';
          _urlTextController.text = widget.postView?.post.url ?? '';
          _customThumbnailTextController.text = widget.postView?.post.thumbnailUrl ?? '';
          _bodyTextController.text = widget.postView?.post.body ?? '';
        },
      );
    }
  }

  Draft _generateDraft() {
    return Draft(
      id: '',
      draftType: draftType,
      existingId: draftExistingId,
      replyId: draftReplyId,
      title: _titleTextController.text,
      url: _urlTextController.text,
      customThumbnail: _customThumbnailTextController.text,
      body: _bodyTextController.text,
    );
  }

  /// Checks whether we are potentially saving a draft of an edit and, if so,
  /// whether the draft contains different contents from the edit
  bool _draftDiffersFromEdit(Draft draft) {
    if (widget.postView == null) {
      return true;
    }

    return draft.title != widget.postView!.post.name ||
        draft.url != (widget.postView!.post.url ?? '') ||
        draft.customThumbnail != (widget.postView!.post.thumbnailUrl ?? '') ||
        draft.body != (widget.postView!.post.body ?? '');
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
    originalUser ??= context.read<AuthBloc>().state.account;

    return PopScope(
      onPopInvoked: (_) {
        if (context.mounted) {
          restoreUser(context, originalUser);
        }
      },
      child: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state.status == CreatePostStatus.success && state.postViewMedia != null) {
            widget.onPostSuccess?.call(state.postViewMedia!, userChanged);
            Navigator.of(context).pop();
          }

          if (state.status == CreatePostStatus.error && state.message != null) {
            showSnackbar(state.message!);
            context.read<CreatePostCubit>().clearMessage();
          }

          switch (state.status) {
            case CreatePostStatus.imageUploadSuccess:
              String markdownImages = state.imageUrls?.map((url) => '![]($url)').join('\n\n') ?? '';
              _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, markdownImages);
              break;
            case CreatePostStatus.postImageUploadSuccess:
              _urlTextController.text = state.imageUrls?.first ?? '';
              break;
            case CreatePostStatus.imageUploadFailure:
            case CreatePostStatus.postImageUploadFailure:
              showSnackbar(l10n.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
            default:
              break;
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.postView != null ? l10n.editPost : l10n.createPost),
                toolbarHeight: 70.0,
                centerTitle: false,
              ),
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            UserSelector(
                              profileModalHeading: l10n.selectAccountToPostAs,
                              communityActorId: communityView?.community.actorId,
                              onCommunityChanged: (CommunityView? cv) {
                                if (cv == null) {
                                  showSnackbar(l10n.unableToFindCommunityOnInstance);
                                }

                                setState(() {
                                  communityId = cv?.community.id;
                                  communityView = cv;
                                });
                                _validateSubmission();
                              },
                              onUserChanged: () => userChanged = true,
                              enableAccountSwitching: widget.postView == null,
                            ),
                            const SizedBox(height: 12.0),
                            TypeAheadField<String>(
                              controller: _titleTextController,
                              suggestionsCallback: (String pattern) async {
                                if (pattern.isEmpty) {
                                  String? linkTitle = await _getDataFromLink(link: _urlTextController.text, updateTitleField: false);
                                  if (linkTitle?.isNotEmpty == true) {
                                    return [linkTitle!];
                                  }
                                }
                                return [];
                              },
                              itemBuilder: (BuildContext context, String itemData) {
                                return ListTile(
                                  title: Text(itemData),
                                  subtitle: Text(l10n.suggestedTitle),
                                );
                              },
                              onSelected: (String suggestion) {
                                _titleTextController.text = suggestion;
                              },
                              builder: (context, controller, focusNode) => TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: l10n.postTitle,
                                  helperText: l10n.requiredField,
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(13),
                                ),
                              ),
                              hideOnEmpty: true,
                              hideOnLoading: true,
                              hideOnError: true,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _urlTextController,
                              decoration: InputDecoration(
                                labelText: l10n.postURL,
                                errorText: urlError,
                                isDense: true,
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.all(13),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    if (state.status == CreatePostStatus.postImageUploadInProgress) return;

                                    List<String> imagesPath = await selectImagesToUpload();
                                    if (context.mounted) context.read<CreatePostCubit>().uploadImages(imagesPath, isPostImage: true);
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
                            if (LemmyClient.instance.supportsFeature(LemmyFeature.customThumbnail) && !isImageUrl(_urlTextController.text)) ...[
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _customThumbnailTextController,
                                decoration: InputDecoration(
                                  labelText: l10n.thumbnailUrl,
                                  errorText: customThumbnailError,
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(13),
                                ),
                              ),
                            ],
                            SizedBox(height: url.isNotEmpty ? 10 : 5),
                            Visibility(
                              visible: url.isNotEmpty,
                              child: LinkPreviewCard(
                                hideNsfw: false,
                                scrapeMissingPreviews: false,
                                originURL: url,
                                mediaURL: isImageUrl(url)
                                    ? url
                                    : customThumbnail?.isNotEmpty == true && isImageUrl(customThumbnail!)
                                        ? customThumbnail
                                        : null,
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
                            if (crossPosts.isNotEmpty && widget.postView == null) const SizedBox(height: 6),
                            Visibility(
                              visible: url.isNotEmpty && crossPosts.isNotEmpty,
                              child: CrossPosts(
                                crossPosts: crossPosts,
                                isNewPost: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.60),
                                  child: LanguageSelector(
                                    languageId: languageId,
                                    onLanguageSelected: (Language? language) {
                                      setState(() => languageId = language?.id);
                                    },
                                  ),
                                ),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(l10n.nsfw),
                                    const SizedBox(width: 4.0),
                                    Switch(
                                      value: isNSFW,
                                      onChanged: (bool value) => setState(() => isNSFW = value),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AnimatedCrossFade(
                              firstChild: Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: getBackgroundColor(context),
                                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: CommonMarkdownBody(body: _bodyTextController.text, isComment: true),
                              ),
                              secondChild: MarkdownTextInputField(
                                controller: _bodyTextController,
                                focusNode: _bodyFocusNode,
                                label: l10n.postBody,
                                minLines: 8,
                                maxLines: null,
                                textStyle: theme.textTheme.bodyLarge,
                                spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                              ),
                              crossFadeState: showPreview ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                              duration: const Duration(milliseconds: 120),
                              excludeBottomFocus: false,
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                    ),
                    Container(
                      color: theme.cardColor,
                      child: Row(
                        children: [
                          Expanded(
                            child: MarkdownToolbar(
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
                                MarkdownType.spoiler,
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
                                    _bodyTextController.text = _bodyTextController.text.replaceRange(
                                        _bodyTextController.selection.end, _bodyTextController.selection.end, '!${community.community.name}@${fetchInstanceNameFromUrl(community.community.actorId)}');
                                  });
                                },
                              },
                              imageIsLoading: state.status == CreatePostStatus.imageUploadInProgress,
                              customImageButtonAction: () async {
                                if (state.status == CreatePostStatus.imageUploadInProgress) return;

                                List<String> imagesPath = await selectImagesToUpload(allowMultiple: true);
                                if (context.mounted) context.read<CreatePostCubit>().uploadImages(imagesPath, isPostImage: false);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 4.0, right: 2.0),
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
                                showPreview ? Icons.visibility_off_rounded : Icons.visibility,
                                color: theme.colorScheme.onSecondary,
                                semanticLabel: l10n.postTogglePreview,
                              ),
                              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondaryContainer),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 2.0, right: 8.0),
                            child: SizedBox(
                              width: 60,
                              child: IconButton(
                                onPressed: isSubmitButtonDisabled || state.status == CreatePostStatus.submitting ? null : () => _onCreatePost(context),
                                icon: state.status == CreatePostStatus.submitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(),
                                      )
                                    : Icon(
                                        widget.postView != null ? Icons.edit_rounded : Icons.send_rounded,
                                        color: theme.colorScheme.onSecondary,
                                        semanticLabel: widget.postView != null ? l10n.editPost : l10n.createPost,
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  disabledBackgroundColor: getBackgroundColor(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _updatePreview(String text) async {
    SearchResponse? searchResponse;
    if (url == text) {
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
      } catch (e) {
        // Ignore
      }
    }

    setState(() {
      crossPosts = searchResponse?.posts ?? [];
    });
  }

  void _validateSubmission() {
    final Uri? parsedUrl = Uri.tryParse(_urlTextController.text);
    final Uri? parsedCustomThumbnail = Uri.tryParse(_customThumbnailTextController.text);

    if (isSubmitButtonDisabled) {
      // It's disabled, check if we can enable it.
      if (_titleTextController.text.isNotEmpty && parsedUrl != null && parsedCustomThumbnail != null && communityId != null) {
        setState(() {
          isSubmitButtonDisabled = false;
          urlError = null;
          customThumbnailError = null;
        });
      }
    } else {
      // It's enabled, check if we need to disable it.
      if (_titleTextController.text.isEmpty || parsedUrl == null || parsedCustomThumbnail == null || communityId == null) {
        setState(() {
          isSubmitButtonDisabled = true;
          urlError = parsedUrl == null ? AppLocalizations.of(context)!.notValidUrl : null;
          customThumbnailError = parsedCustomThumbnail == null ? AppLocalizations.of(context)!.notValidUrl : null;
        });
      }
    }
  }

  void _onCreatePost(BuildContext context) {
    saveDraft = false;

    context.read<CreatePostCubit>().createOrEditPost(
          communityId: communityId!,
          name: _titleTextController.text,
          body: _bodyTextController.text,
          nsfw: isNSFW,
          url: url,
          customThumbnail: customThumbnail,
          postIdBeingEdited: widget.postView?.post.id,
          languageId: languageId,
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
            onCommunitySelected: widget.onCommunitySelected,
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CommunityAvatar(community: widget.communityView?.community, radius: 16),
                  const SizedBox(width: 12),
                  widget.communityId != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${widget.communityView?.community.title} '),
                            CommunityFullNameWidget(
                              context,
                              widget.communityView?.community.name,
                              widget.communityView?.community.title,
                              fetchInstanceNameFromUrl(widget.communityView?.community.actorId),
                              // Override, because we have the display name right above
                              useDisplayName: false,
                            )
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
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

@Deprecated('Use Draft model through database instead')
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
