import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/app/wiring/state_factories.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/feed.dart';

import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/shared/media/media_utils.dart';
import 'package:thunder/packages/ui/ui.dart';

class MediaManagementPage extends StatelessWidget {
  const MediaManagementPage({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final dateFormat = context.select<FeedPreferencesCubit, DateFormat?>((cubit) => cubit.state.dateFormat);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final imageCachingMode = context.select<ThunderCubit, ImageCachingMode>((cubit) => cubit.state.imageCachingMode);

    return BlocConsumer<UserMediaCubit, UserMediaState>(
      listener: (context, state) {
        if (state.status == UserMediaStatus.loadFailure && state.errorMessage?.isNotEmpty == true) {
          showThunderSnackbar(
            state.errorMessage!,
            trailingIcon: Icons.refresh_rounded,
            trailingAction: () => context.read<UserMediaCubit>().loadMedia(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            color: theme.colorScheme.surface,
            child: SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: APP_BAR_HEIGHT,
                    title: ListTile(
                      title: Text(
                        l10n.manageMedia,
                        style: theme.textTheme.titleLarge,
                      ),
                      subtitle: UserFullNameWidget(name: account.username, displayName: account.displayName, instance: account.instance),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                  if (state.status == UserMediaStatus.loading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == UserMediaStatus.searching ||
                      state.status == UserMediaStatus.searchSuccess ||
                      state.status == UserMediaStatus.deleting ||
                      state.status == UserMediaStatus.loadFailure ||
                      state.status == UserMediaStatus.loadSuccess) ...[
                    if (state.images?.isNotEmpty == true)
                      SliverList.builder(
                        addSemanticIndexes: false,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        itemCount: state.images!.length,
                        itemBuilder: (context, index) {
                          final image = state.images![index];

                          return KeepAlive(
                            keepAlive: true,
                            child: Card(
                              elevation: 2,
                              clipBehavior: Clip.hardEdge,
                              child: Column(
                                children: [
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    child: Stack(
                                      children: [
                                        ExtendedImage.network(
                                          image.url,
                                          cache: true,
                                          clearMemoryCacheWhenDispose: imageCachingMode == ImageCachingMode.relaxed,
                                          loadStateChanged: (state) {
                                            if (state.extendedImageLoadState == LoadState.loading) {
                                              return SizedBox(
                                                width: double.infinity,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Text(l10n.loading),
                                                  ),
                                                ),
                                              );
                                            }
                                            if (state.extendedImageLoadState == LoadState.failed) {
                                              return SizedBox(
                                                width: double.infinity,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Text(
                                                      l10n.unableToLoadImageFrom(account.instance),
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            return null;
                                          },
                                        ),
                                        Positioned.fill(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => showImageViewer(context, url: image.url),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Text(l10n.uploadedDate(image.uploadedAt != null ? dateFormat?.format(image.uploadedAt!.toLocal()) ?? '' : '')),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () async {
                                          final UserMediaCubit userMediaCubit = context.read<UserMediaCubit>();
                                          userMediaCubit.findMediaUsages(id: image.alias);

                                          showModalBottomSheet(
                                            context: context,
                                            showDragHandle: true,
                                            isScrollControlled: false,
                                            builder: (context) {
                                              return AnimatedSize(
                                                duration: const Duration(milliseconds: 250),
                                                child: BlocProvider.value(
                                                  value: userMediaCubit,
                                                  child: BlocBuilder<UserMediaCubit, UserMediaState>(
                                                    builder: (context, state) {
                                                      if (state.status == UserMediaStatus.loadFailure) {
                                                        Navigator.of(context).pop();
                                                      }

                                                      return SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            if (state.status == UserMediaStatus.searching)
                                                              const SizedBox(
                                                                height: 200,
                                                                child: Center(
                                                                  child: CircularProgressIndicator(),
                                                                ),
                                                              )
                                                            else if (state.status == UserMediaStatus.searchSuccess) ...[
                                                              if (state.imageSearchPosts?.isNotEmpty == true)
                                                                BlocProvider.value(
                                                                  value: createFeedBloc(account),
                                                                  child: CustomScrollView(
                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                    shrinkWrap: true,
                                                                    slivers: [
                                                                      FeedPostCardList(
                                                                        posts: state.imageSearchPosts!,
                                                                        tabletMode: false,
                                                                        markPostReadOnScroll: false,
                                                                        disableSwiping: true,
                                                                        indicateRead: false,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              if (state.imageSearchComments?.isNotEmpty == true)
                                                                ListView.builder(
                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                  shrinkWrap: true,
                                                                  itemCount: state.imageSearchComments!.length,
                                                                  itemBuilder: (context, index) => CommentListEntry(comment: state.imageSearchComments![index]),
                                                                ),
                                                            ],
                                                            if (state.status == UserMediaStatus.searchSuccess &&
                                                                state.imageSearchComments?.isNotEmpty != true &&
                                                                state.imageSearchPosts?.isNotEmpty != true)
                                                              SizedBox(
                                                                width: double.infinity,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(bottom: 24),
                                                                  child: Container(
                                                                    color: theme.dividerColor.withValues(alpha: 0.1),
                                                                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                                                                    child: ThunderScalableText(
                                                                      l10n.noReferencesToImage,
                                                                      textAlign: TextAlign.center,
                                                                      style: theme.textTheme.titleSmall,
                                                                      textScaleFactor: metadataFontSizeScale.textScaleFactor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            if (state.status == UserMediaStatus.searchSuccess &&
                                                                (state.imageSearchComments?.isNotEmpty == true || state.imageSearchPosts?.isNotEmpty == true))
                                                              const SizedBox(height: 50),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.search_rounded),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          bool result = false;
                                          await showThunderDialog<bool>(
                                            context: context,
                                            title: l10n.deleteImageConfirmTitle,
                                            contentText: l10n.deleteImageConfirmMessage,
                                            onSecondaryButtonPressed: (dialogContext) {
                                              result = false;
                                              Navigator.of(dialogContext).pop();
                                            },
                                            secondaryButtonText: l10n.cancel,
                                            onPrimaryButtonPressed: (dialogContext, _) {
                                              result = true;
                                              Navigator.of(dialogContext).pop();
                                            },
                                            primaryButtonText: l10n.delete,
                                          );

                                          if (result && context.mounted) {
                                            context.read<UserMediaCubit>().deleteMedia(deleteToken: image.deleteToken, id: image.alias);
                                          }
                                        },
                                        icon: const Icon(Icons.delete_forever),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    if (state.images?.isNotEmpty != true)
                      SliverToBoxAdapter(
                        child: Container(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: ThunderScalableText(
                            l10n.noImages,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall,
                            textScaleFactor: metadataFontSizeScale.textScaleFactor,
                          ),
                        ),
                      ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
