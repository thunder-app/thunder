import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_detection/keyboard_detection.dart';

import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/post/presentation/widgets/cross_posts.dart';
import 'package:thunder/src/features/post/presentation/widgets/create_post/community_selector.dart';
import 'package:thunder/src/features/post/presentation/widgets/create_post/create_post_additional_settings_page.dart';
import 'package:thunder/src/features/post/presentation/widgets/create_post/create_post_bottom_bar.dart';
import 'package:thunder/src/features/post/presentation/widgets/create_post/create_post_editor_section.dart';
import 'package:thunder/src/features/post/presentation/widgets/create_post/create_post_metadata_row.dart';
import 'package:thunder/src/features/post/presentation/widgets/create_post/create_post_title_field.dart';
import 'package:thunder/src/features/post/presentation/widgets/create_post/create_post_url_field.dart';
import 'package:thunder/src/features/session/session.dart';
import 'package:thunder/src/features/user/presentation/widgets/user_selector.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/media/media_utils.dart' show isImageUrl, selectImagesToUpload;
import 'package:thunder/src/shared/media/media_view.dart';
import 'package:thunder/src/shared/language_selector.dart';
import 'package:thunder/packages/ui/ui.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({
    super.key,
    this.account,
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
    this.showMediaPreview = true,
    this.showAdditionalSettingsButton = true,
  });

  /// The account of the user creating the post.
  final Account? account;

  /// The id of the community to create the post in.
  final int? communityId;

  /// The community to create the post in.
  final ThunderCommunity? community;

  /// Whether the post is pre-populated.
  final bool? prePopulated;

  /// The title of the post.
  final String? title;

  /// The text of the post.
  final String? text;

  /// The image to upload with the post.
  final File? image;

  /// The url of the post.
  final String? url;

  /// The custom thumbnail of the post.
  final String? customThumbnail;

  /// The alternate text of the post.
  final String? altText;

  /// The post to edit.
  final ThunderPost? post;

  /// Whether the post is a cross post.
  final bool isCrossPost;

  /// Callback function that is triggered whenever the post is successfully created or updated.
  final Function(ThunderPost post, bool userChanged)? onPostSuccess;

  /// Whether to show the media preview.
  final bool showMediaPreview;

  /// Whether to show the additional settings button.
  final bool showAdditionalSettingsButton;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> with WidgetsBindingObserver {
  late final CreatePostCubit _createPostCubit;

  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();
  final TextEditingController _customThumbnailTextController = TextEditingController();
  final TextEditingController _altTextTextController = TextEditingController();
  final TextEditingController _tagsTextController = TextEditingController();

  final FocusNode _bodyFocusNode = FocusNode();
  final KeyboardDetectionController _keyboardDetectionController = KeyboardDetectionController();

  bool _showPreview = false;
  bool _wasKeyboardVisible = false;
  bool _syncingControllers = false;
  int _lastHandledDraftNoticeId = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _createPostCubit = context.read<CreatePostCubit>();

    _initControllers();
    _bindControllerListeners();

    unawaited(
      _createPostCubit.initialize(
        communityId: widget.communityId,
        community: widget.community,
        post: widget.post,
        prePopulated: widget.prePopulated ?? false,
        title: widget.title,
        text: widget.text,
        url: widget.url,
        customThumbnail: widget.customThumbnail,
        altText: widget.altText,
        isCrossPost: widget.isCrossPost,
      ),
    );

    if (widget.prePopulated == true && widget.url != null && widget.text?.isNotEmpty == true && widget.isCrossPost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = GlobalContext.l10n;
        showThunderSnackbar(
          l10n.addOriginalPostBody,
          duration: const Duration(seconds: 10),
          trailingIcon: Icons.add_rounded,
          trailingIconColor: Theme.of(context).colorScheme.secondary,
          trailingAction: () => _bodyTextController.text = widget.text ?? '',
        );
      });
    }

    if (widget.image != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<CreatePostCubit>().uploadImages([widget.image!.path], isPostImage: true);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.primaryFocus?.unfocus();

    final cubit = _createPostCubit;
    unawaited(
      () async {
        final result = await cubit.persistDraftNow();
        await cubit.clearActiveDraft();

        if (result == DraftPersistenceResult.saved && GlobalContext.scaffoldMessengerKey.currentState != null) {
          showThunderSnackbar(GlobalContext.l10n.postSavedAsDraft);
        }
      }(),
    );

    _bodyTextController.dispose();
    _titleTextController.dispose();
    _urlTextController.dispose();
    _customThumbnailTextController.dispose();
    _altTextTextController.dispose();
    _tagsTextController.dispose();
    _bodyFocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      unawaited(_createPostCubit.handleAppLifecyclePause());
    }
  }

  /// Initializes the controllers with the data from the widget.
  void _initControllers() {
    if (widget.post != null) {
      _titleTextController.text = widget.post!.name;
      _urlTextController.text = widget.post!.url ?? '';
      _customThumbnailTextController.text = widget.post!.thumbnailUrl ?? '';
      _altTextTextController.text = widget.post!.altText ?? '';
      _tagsTextController.text = encodePiefedTags(widget.post!.tags);
      _bodyTextController.text = widget.post!.body ?? '';
      return;
    }

    if (widget.prePopulated == true) {
      _titleTextController.text = widget.title ?? '';
      _urlTextController.text = widget.url ?? '';
      _customThumbnailTextController.text = widget.customThumbnail ?? '';
      _altTextTextController.text = widget.altText ?? '';
      _bodyTextController.text = widget.url != null && widget.text?.isNotEmpty == true && widget.isCrossPost ? '' : widget.text ?? '';
    }
  }

  /// Binds the controllers to the cubit logic.
  void _bindControllerListeners() {
    _titleTextController.addListener(() {
      if (_syncingControllers) return;
      _createPostCubit.updateTitle(_titleTextController.text);
    });
    _bodyTextController.addListener(() {
      if (_syncingControllers) return;
      _createPostCubit.updateBody(_bodyTextController.text);
    });
    _urlTextController.addListener(() {
      if (_syncingControllers) return;
      _createPostCubit.updateUrl(_urlTextController.text);
    });
    _customThumbnailTextController.addListener(() {
      if (_syncingControllers) return;
      _createPostCubit.updateCustomThumbnail(_customThumbnailTextController.text);
    });
    _altTextTextController.addListener(() {
      if (_syncingControllers) return;
      _createPostCubit.updateAltText(_altTextTextController.text);
    });
    _tagsTextController.addListener(() {
      if (_syncingControllers) return;
      _createPostCubit.updateTags(_tagsTextController.text);
    });
  }

  void _handleCreatePostStateChange(BuildContext context, CreatePostState state) {
    _syncControllersWithState(state);

    if (state.restoredDraftAvailable && state.restoredDraftNoticeId != _lastHandledDraftNoticeId) {
      _lastHandledDraftNoticeId = state.restoredDraftNoticeId;

      showThunderSnackbar(
        GlobalContext.l10n.restoredPostFromDraft,
        trailingIcon: Icons.delete_forever_rounded,
        trailingIconColor: Theme.of(context).colorScheme.errorContainer,
        trailingAction: () => context.read<CreatePostCubit>().discardRestoredDraft(),
      );
    }

    if (state.status == CreatePostStatus.success && state.post != null) {
      widget.onPostSuccess?.call(state.post!, state.userChanged);
      Navigator.of(context).pop();
      return;
    }

    if (state.status == CreatePostStatus.error && state.message != null) {
      showThunderSnackbar(state.message!);
      context.read<CreatePostCubit>().clearMessage();
      return;
    }

    switch (state.status) {
      case CreatePostStatus.imageUploadSuccess:
        final markdownImages = state.imageUrls?.map((url) => '![]($url)').join('\n\n') ?? '';
        if (markdownImages.isEmpty) {
          context.read<CreatePostCubit>().clearMessage();
          return;
        }

        final selection = _bodyTextController.selection;
        final insertIndex = selection.isValid ? selection.end : _bodyTextController.text.length;
        final newBody = _bodyTextController.text.replaceRange(insertIndex, insertIndex, markdownImages);

        _syncingControllers = true;
        _bodyTextController.text = newBody;
        _bodyTextController.selection = TextSelection.collapsed(offset: insertIndex + markdownImages.length);
        _syncingControllers = false;

        context.read<CreatePostCubit>().updateBody(newBody);
        break;
      case CreatePostStatus.imageUploadFailure:
      case CreatePostStatus.postImageUploadFailure:
        showThunderSnackbar(
          GlobalContext.l10n.postUploadImageError + (state.message?.isNotEmpty == true ? '. ${state.message}' : ''),
          leadingIcon: Icons.warning_rounded,
          leadingIconColor: Theme.of(context).colorScheme.errorContainer,
        );
        break;
      default:
        break;
    }
  }

  void _syncControllersWithState(CreatePostState state) {
    _syncingControllers = true;
    _setControllerText(_titleTextController, state.title);
    _setControllerText(_bodyTextController, state.body);
    _setControllerText(_urlTextController, state.url);
    _setControllerText(_customThumbnailTextController, state.customThumbnail);
    _setControllerText(_altTextTextController, state.altText);
    _setControllerText(_tagsTextController, state.tags);
    _syncingControllers = false;
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    final selectionOffset = controller.selection.isValid ? controller.selection.baseOffset.clamp(0, value.length) : value.length;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: selectionOffset),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {},
      child: MultiBlocListener(
        listeners: [
          BlocListener<FeatureAccountCubit, FeatureAccountState>(
            listenWhen: (previous, current) => previous.effectiveAccount.id != current.effectiveAccount.id,
            listener: (context, featureAccountState) {
              context.read<CreatePostCubit>().switchAccount(featureAccountState.effectiveAccount);
            },
          ),
          BlocListener<CreatePostCubit, CreatePostState>(
            listener: _handleCreatePostStateChange,
          ),
        ],
        child: BlocBuilder<FeatureAccountCubit, FeatureAccountState>(
          builder: (context, featureAccountState) {
            final account = featureAccountState.effectiveAccount;

            return BlocBuilder<CreatePostCubit, CreatePostState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: KeyboardDetection(
                    controller: _keyboardDetectionController,
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      appBar: AppBar(
                        title: Text(widget.post != null ? l10n.editPost : l10n.createPost),
                        centerTitle: false,
                        actions: widget.showAdditionalSettingsButton
                            ? [
                                IconButton(
                                  key: const Key('create-post-additional-settings-button'),
                                  onPressed: () => _openAdditionalSettingsPage(context),
                                  icon: const Icon(Icons.tune_rounded),
                                  tooltip: l10n.advanced,
                                ),
                              ]
                            : null,
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      CommunitySelector(
                                        account: account,
                                        community: state.community,
                                        onCommunitySelected: (community) => context.read<CreatePostCubit>().updateCommunity(community),
                                      ),
                                      const SizedBox(height: 4.0),
                                      UserSelector(
                                        account: account,
                                        communityActorId: state.community?.actorId,
                                        onCommunityChanged: (community) => context.read<CreatePostCubit>().updateCommunity(community),
                                        onUserChanged: (account) => context.read<FeatureAccountCubit>().setOverride(account),
                                        enableAccountSwitching: widget.post == null,
                                      ),
                                      const SizedBox(height: 12.0),
                                      CreatePostTitleField(
                                        controller: _titleTextController,
                                        suggestedLinkTitle: state.suggestedLinkTitle,
                                      ),
                                      const SizedBox(height: 10),
                                      CreatePostUrlField(
                                        controller: _urlTextController,
                                        state: state,
                                        onUploadPostImageRequested: () async {
                                          if (state.status == CreatePostStatus.postImageUploadInProgress) {
                                            return;
                                          }

                                          final imagesPath = await selectImagesToUpload();
                                          if (mounted) {
                                            context.read<CreatePostCubit>().uploadImages(imagesPath, isPostImage: true);
                                          }
                                        },
                                      ),
                                      if (isImageUrl(state.url)) ...[
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          key: const Key('create-post-alt-text-field'),
                                          controller: _altTextTextController,
                                          decoration: InputDecoration(
                                            labelText: l10n.altText,
                                            isDense: true,
                                            border: const OutlineInputBorder(),
                                            contentPadding: const EdgeInsets.all(13),
                                          ),
                                        ),
                                      ],
                                      SizedBox(height: state.url.isNotEmpty ? 10 : 5),
                                      if (state.url.isNotEmpty && widget.showMediaPreview)
                                        MediaView(
                                          showFullHeightImages: false,
                                          edgeToEdgeImages: false,
                                          viewMode: ViewMode.comfortable,
                                          markPostReadOnMediaView: false,
                                          isUserLoggedIn: true,
                                          media: Media(
                                            originalUrl: state.url,
                                            mediaUrl: isImageUrl(state.url)
                                                ? state.url
                                                : state.customThumbnail.isNotEmpty && isImageUrl(state.customThumbnail)
                                                    ? state.customThumbnail
                                                    : null,
                                            nsfw: state.isNsfw,
                                            mediaType: MediaType.link,
                                          ),
                                        ),
                                      if (state.crossPosts.isNotEmpty && widget.post == null) const SizedBox(height: 6),
                                      if (state.url.isNotEmpty && state.crossPosts.isNotEmpty && widget.post == null)
                                        CrossPosts(
                                          crossPosts: state.crossPosts,
                                          isNewPost: true,
                                        ),
                                      const SizedBox(height: 10),
                                      CreatePostMetadataRow(
                                        languageSelector: LanguageSelector(
                                          account: account,
                                          languageId: state.languageId,
                                          onLanguageSelected: (language) => context.read<CreatePostCubit>().updateLanguage(language?.id),
                                        ),
                                        nsfw: state.isNsfw,
                                        onNsfwChanged: (value) => context.read<CreatePostCubit>().updateNsfw(value),
                                      ),
                                      const SizedBox(height: 10),
                                      CreatePostEditorSection(
                                        body: state.body,
                                        controller: _bodyTextController,
                                        focusNode: _bodyFocusNode,
                                        showPreview: _showPreview,
                                        nsfw: state.isNsfw,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            CreatePostBottomBar(
                              account: account,
                              state: state,
                              bodyController: _bodyTextController,
                              bodyFocusNode: _bodyFocusNode,
                              post: widget.post,
                              showPreview: _showPreview,
                              onTogglePreview: _togglePreview,
                              onUploadBodyImages: () async {
                                if (state.status == CreatePostStatus.imageUploadInProgress) {
                                  return;
                                }

                                final imagesPath = await selectImagesToUpload(allowMultiple: true);
                                if (mounted) {
                                  context.read<CreatePostCubit>().uploadImages(imagesPath, isPostImage: false);
                                }
                              },
                            ),
                            Container(
                              height: MediaQuery.of(context).padding.bottom,
                              color: theme.cardColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _togglePreview() {
    if (!_showPreview) {
      setState(() => _wasKeyboardVisible = _keyboardDetectionController.stateAsBool(true) ?? false);
      FocusManager.instance.primaryFocus?.unfocus();
    }

    setState(() => _showPreview = !_showPreview);
    if (!_showPreview && _wasKeyboardVisible) {
      _bodyFocusNode.requestFocus();
    }
  }

  Future<void> _openAdditionalSettingsPage(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider<CreatePostCubit>.value(
          value: _createPostCubit,
          child: CreatePostAdditionalSettingsPage(
            customThumbnailController: _customThumbnailTextController,
            tagsController: _tagsTextController,
          ),
        ),
      ),
    );
  }
}
