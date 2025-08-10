// Dart imports
import 'dart:async';
import 'dart:io';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:markdown_editor/markdown_editor.dart';

// Project imports
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/models/thunder_language.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/core/enums/media_type.dart';
import 'package:thunder/src/core/models/media.dart';
import 'package:thunder/src/core/enums/view_mode.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/widgets/avatars/community_avatar.dart';
import 'package:thunder/src/shared/widgets/common_markdown_body.dart';
import 'package:thunder/src/shared/cross_posts.dart';
import 'package:thunder/src/shared/full_name_widgets.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/shared/language_selector.dart';
import 'package:thunder/src/shared/widgets/media/media_view.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/colors.dart';
import 'package:thunder/src/shared/utils/debounce.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/instance.dart';
import 'package:thunder/src/shared/utils/media/image.dart';

class CreatePostPage extends StatefulWidget {
  /// The community ID to create the post in
  final int? communityId;

  /// The community to create the post in
  final ThunderCommunity? community;

  /// Whether or not to pre-populate the post with the [title], [text], [image], [url], [customThumbnail], and/or [altText]
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

  /// Alternative text for the image
  final String? altText;

  /// [post] is passed in when editing an existing post
  final ThunderPost? post;

  /// Whether or not this post is a cross post
  final bool isCrossPost;

  /// Callback function that is triggered whenever the post is successfully created or updated
  final Function(ThunderPost post, bool userChanged)? onPostSuccess;

  const CreatePostPage({
    super.key,
    required this.communityId,
    this.community,
    this.image,
    this.title,
    this.text,
    this.url,
    this.customThumbnail,
    this.altText,
    this.prePopulated = false,
    this.post,
    this.isCrossPost = false,
    this.onPostSuccess,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  /// The account to use for the post
  Account? account;

  /// The account's user information
  ThunderUser? user;

  /// Holds the draft type associated with the post. This type is determined by the input parameters passed in.
  /// If [post] is passed in, this will be a [DraftType.postEdit].
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

  /// Alternative text for the image
  String? altText;

  /// The error message for the shared link if available
  String? urlError;

  /// The error message for the custom thumbnail if available
  String? customThumbnailError;

  /// The id of the community that the post will be created in
  int? communityId;

  /// The language ID for the post
  int? languageId;

  /// The community associated with the post. This is used to display the community information
  ThunderCommunity? community;

  /// A list of cross posts for the given post. This is determined by the URL parameter
  List<ThunderPost> crossPosts = [];

  /// The corresponding controllers for the title, body and url text fields
  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();
  final TextEditingController _customThumbnailTextController = TextEditingController();
  final TextEditingController _altTextTextController = TextEditingController();

  /// The focus node for the body. This is used to keep track of the position of the cursor when toggling preview
  final FocusNode _bodyFocusNode = FocusNode();

  /// The keyboard visibility controller used to determine if the keyboard is visible at a given time
  final keyboardVisibilityController = KeyboardVisibilityController();

  bool userChanged = false;

  @override
  void initState() {
    super.initState();

    account = context.read<ProfileBloc>().state.account;

    communityId = widget.communityId;

    if (widget.community != null) {
      community = widget.community;
    }

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

    _altTextTextController.addListener(() {
      altText = _altTextTextController.text;
      _validateSubmission();
      debounce(const Duration(milliseconds: 1000), _updatePreview, [altText]);
    });

    // Logic for pre-populating the post with the given fields
    if (widget.prePopulated == true) {
      _titleTextController.text = widget.title ?? '';
      _urlTextController.text = widget.url ?? '';
      _customThumbnailTextController.text = widget.customThumbnail ?? '';
      _altTextTextController.text = widget.altText ?? '';
      _getDataFromLink(updateTitleField: _titleTextController.text.isEmpty);

      // If the post is a cross-post, then prompt the user if they want to add the original post body
      if (widget.url != null && widget.text?.isNotEmpty == true && widget.isCrossPost) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          final l10n = GlobalContext.l10n;

          showSnackbar(
            l10n.addOriginalPostBody,
            duration: const Duration(seconds: 10),
            trailingIcon: Icons.add_rounded,
            trailingIconColor: Theme.of(context).colorScheme.secondary,
            trailingAction: () => _bodyTextController.text = widget.text ?? '',
          );
        });
      } else {
        _bodyTextController.text = widget.text ?? '';
      }

      if (widget.image != null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (context.mounted) context.read<CreatePostCubit>().uploadImages([widget.image!.path], isPostImage: true);
        });
      }

      return;
    }

    // Logic for pre-populating the post with the [postView] for edits
    if (widget.post != null) {
      _titleTextController.text = widget.post!.name;
      _urlTextController.text = widget.post!.url ?? '';
      _customThumbnailTextController.text = widget.post!.thumbnailUrl ?? '';
      _altTextTextController.text = widget.post!.altText ?? '';
      _bodyTextController.text = widget.post!.body ?? '';
      isNSFW = widget.post!.nsfw;
      languageId = widget.post!.languageId;
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
    _altTextTextController.dispose();
    _bodyFocusNode.dispose();

    FocusManager.instance.primaryFocus?.unfocus();

    _draftTimer?.cancel();

    Draft draft = _generateDraft();

    if (draft.isPostNotEmpty && saveDraft && _draftDiffersFromEdit(draft)) {
      final l10n = GlobalContext.l10n;

      Draft.upsertDraft(draft);
      showSnackbar(l10n.postSavedAsDraft);
    } else {
      Draft.deleteDraft(draftType, draftExistingId, draftReplyId);
    }

    super.dispose();
  }

  /// Attempts to restore an existing draft of a post
  void _restoreExistingDraft() async {
    if (widget.post != null) {
      draftType = DraftType.postEdit;
      draftExistingId = widget.post?.id;
    } else if (widget.communityId != null) {
      draftType = DraftType.postCreate;
      draftReplyId = widget.communityId;
    } else if (widget.community != null) {
      draftType = DraftType.postCreate;
      draftReplyId = widget.community!.id;
    } else {
      draftType = DraftType.postCreateGeneral;
    }

    Draft? draft = await Draft.fetchDraft(draftType, draftExistingId, draftReplyId);

    if (draft != null) {
      _titleTextController.text = draft.title ?? '';
      _urlTextController.text = draft.url ?? '';
      _customThumbnailTextController.text = draft.customThumbnail ?? '';
      _altTextTextController.text = draft.altText ?? '';
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
          _titleTextController.text = widget.post?.name ?? '';
          _urlTextController.text = widget.post?.url ?? '';
          _customThumbnailTextController.text = widget.post?.thumbnailUrl ?? '';
          _altTextTextController.text = widget.post?.altText ?? '';
          _bodyTextController.text = widget.post?.body ?? '';
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
      altText: _altTextTextController.text,
      body: _bodyTextController.text,
    );
  }

  /// Checks whether we are potentially saving a draft of an edit and, if so,
  /// whether the draft contains different contents from the edit
  bool _draftDiffersFromEdit(Draft draft) {
    if (widget.post == null) {
      return true;
    }

    return draft.title != widget.post!.name ||
        draft.url != (widget.post!.url ?? '') ||
        draft.customThumbnail != (widget.post!.thumbnailUrl ?? '') ||
        draft.altText != (widget.post!.altText ?? '') ||
        draft.body != (widget.post!.body ?? '');
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
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocConsumer<CreatePostCubit, CreatePostState>(
        listener: (context, state) {
          if (state.status == CreatePostStatus.success && state.post != null) {
            widget.onPostSuccess?.call(state.post!, userChanged);
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
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(widget.post != null ? l10n.editPost : l10n.createPost),
                centerTitle: false,
              ),
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            CommunitySelector(
                              account: account!,
                              community: community,
                              onCommunitySelected: (ThunderCommunity c) {
                                setState(() {
                                  communityId = c.id;
                                  community = c;
                                });
                                _validateSubmission();
                              },
                            ),
                            const SizedBox(height: 4.0),
                            UserSelector(
                              account: account!,
                              communityActorId: community?.actorId,
                              onCommunityChanged: (community) {
                                setState(() {
                                  communityId = community?.id;
                                  community = community;
                                });

                                _validateSubmission();
                              },
                              onUserChanged: (account) {
                                setState(() {
                                  userChanged = this.account?.instance != account.instance;
                                  this.account = account;
                                });

                                context.read<CreatePostCubit>().switchAccount(account);
                              },
                              enableAccountSwitching: widget.post == null,
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
                            if (!isImageUrl(_urlTextController.text)) ...[
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
                            if (isImageUrl(_urlTextController.text)) ...[
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _altTextTextController,
                                decoration: InputDecoration(
                                  labelText: l10n.altText,
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(13),
                                ),
                              ),
                            ],
                            SizedBox(height: url.isNotEmpty ? 10 : 5),
                            Visibility(
                              visible: url.isNotEmpty,
                              child: MediaView(
                                showFullHeightImages: false,
                                edgeToEdgeImages: false,
                                viewMode: ViewMode.comfortable,
                                markPostReadOnMediaView: false,
                                isUserLoggedIn: true,
                                media: Media(
                                  originalUrl: url,
                                  mediaUrl: isImageUrl(url)
                                      ? url
                                      : customThumbnail?.isNotEmpty == true && isImageUrl(customThumbnail!)
                                          ? customThumbnail
                                          : null,
                                  nsfw: isNSFW,
                                  mediaType: MediaType.link,
                                ),
                              ),
                            ),
                            if (crossPosts.isNotEmpty && widget.post == null) const SizedBox(height: 6),
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
                                    onLanguageSelected: (ThunderLanguage? language) {
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
                    const Divider(height: 1),
                    Container(
                      color: theme.cardColor,
                      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                  showUserInputDialog(
                                    context,
                                    title: l10n.username,
                                    account: account!,
                                    onUserSelected: (ThunderUser user) {
                                      _bodyTextController.text = _bodyTextController.text.replaceRange(
                                        _bodyTextController.selection.end,
                                        _bodyTextController.selection.end,
                                        '[@${user.name}@${fetchInstanceNameFromUrl(user.actorId)}](${user.actorId})',
                                      );
                                    },
                                  );
                                },
                                MarkdownType.community: () {
                                  showCommunityInputDialog(
                                    context,
                                    title: l10n.community,
                                    account: account!,
                                    onCommunitySelected: (community) {
                                      _bodyTextController.text = _bodyTextController.text
                                          .replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, '!${community.name}@${fetchInstanceNameFromUrl(community.actorId)}');
                                    },
                                  );
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
                                        widget.post != null ? Icons.edit_rounded : Icons.send_rounded,
                                        color: theme.colorScheme.onSecondary,
                                        semanticLabel: widget.post != null ? l10n.editPost : l10n.createPost,
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
                    Container(
                      height: MediaQuery.of(context).padding.bottom,
                      color: theme.cardColor,
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
    if (url != text) return;

    try {
      // Fetch cross-posts
      final response = await SearchRepositoryImpl(account: account!).search(
        query: url,
        type: MetaSearchType.url,
        sort: PostSortType.topAll,
        listingType: FeedListType.all,
        limit: 20,
      );

      setState(() => crossPosts = response['posts']);
    } catch (e) {
      // Ignore
    }
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
          altText: altText,
          postIdBeingEdited: widget.post?.id,
          languageId: languageId,
        );
  }
}

/// Creates a widget which displays a preview of a pre-selected community, with the ability to change the selected community
///
/// Passing in a [community] will set the initial state of the widget to display that given community.
/// A callback function [onCommunitySelected] will be triggered whenever a new community is selected from the dropdown.
class CommunitySelector extends StatefulWidget {
  const CommunitySelector({
    super.key,
    required this.account,
    this.community,
    required this.onCommunitySelected,
  });

  /// The account to use for the post
  final Account account;

  /// The initial community to be passed in
  final ThunderCommunity? community;

  /// A callback function to trigger whenever a community is selected from the dropdown
  final Function(ThunderCommunity) onCommunitySelected;

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
            account: widget.account,
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
                spacing: 12.0,
                children: [
                  if (widget.community != null) CommunityAvatar(community: widget.community!, radius: 16),
                  widget.community != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${widget.community!.title} '),
                            CommunityFullNameWidget(
                              context,
                              widget.community!.name,
                              widget.community!.title,
                              fetchInstanceNameFromUrl(widget.community!.actorId),
                              // Override, because we have the display name right above
                              useDisplayName: false,
                            )
                          ],
                        )
                      : SizedBox(
                          height: 39,
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
