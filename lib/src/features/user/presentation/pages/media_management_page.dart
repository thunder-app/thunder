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

import 'package:thunder/src/features/identity/presentation/widgets/full_name_widgets.dart';
import 'package:thunder/src/features/identity/presentation/widgets/text/scalable_text.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/features/content/presentation/widgets/media/media_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar, showThunderDialog;

class MediaManagementPage extends StatelessWidget {
  const MediaManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final dateFormat = context.select<FeedPreferencesCubit, DateFormat?>((cubit) => cubit.state.dateFormat);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final imageCachingMode = context.select<ThunderBloc, ImageCachingMode>((cubit) => cubit.state.imageCachingMode);

    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) {
        if (state.status == UserSettingsStatus.failedListingMedia && state.errorMessage?.isNotEmpty == true) {
          showSnackbar(
            state.errorMessage!,
            trailingIcon: Icons.refresh_rounded,
            trailingAction: () => context.read<UserSettingsBloc>().add(const ListMediaEvent()),
          );
        }

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
                      subtitle: UserFullNameWidget(
                        context,
                        context.read<ProfileBloc>().state.account.username,
                        context.read<ProfileBloc>().state.account.displayName,
                        context.read<ProfileBloc>().state.account.instance,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                  if (state.status == UserSettingsStatus.listingMedia)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == UserSettingsStatus.searchingMedia ||
                      state.status == UserSettingsStatus.succeededSearchingMedia ||
                      state.status == UserSettingsStatus.deletingMedia ||
                      state.status == UserSettingsStatus.failedListingMedia ||
                      state.status == UserSettingsStatus.succeededListingMedia) ...[
                    if (state.images?.isNotEmpty == true)
                      SliverList.builder(
                        addSemanticIndexes: false,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        itemCount: state.images!.length,
                        itemBuilder: (context, index) {
                          final account = context.read<ProfileBloc>().state.account;
                          String url = 'https://${account.instance}/pictrs/image/${state.images![index]['local_image']['pictrs_alias']}';

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
                                          url,
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
                                              onTap: () => showImageViewer(context, url: url),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Text(l10n.uploadedDate(dateFormat?.format(DateTime.parse(state.images![index]['local_image']['published']).toLocal()) ?? '')),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () async {
                                          final UserSettingsBloc userSettingsBloc = context.read<UserSettingsBloc>();
                                          userSettingsBloc.add(FindMediaUsagesEvent(id: state.images![index]['local_image']['pictrs_alias']));

                                          showModalBottomSheet(
                                            context: context,
                                            showDragHandle: true,
                                            isScrollControlled: false,
                                            builder: (context) {
                                              return AnimatedSize(
                                                duration: const Duration(milliseconds: 250),
                                                child: BlocProvider.value(
                                                  value: userSettingsBloc,
                                                  child: BlocBuilder<UserSettingsBloc, UserSettingsState>(
                                                    builder: (context, state) {
                                                      if (state.status == UserSettingsStatus.failedListingMedia) {
                                                        Navigator.of(context).pop();
                                                      }

                                                      final account = context.read<ProfileBloc>().state.account;

                                                      return SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            if (state.status == UserSettingsStatus.searchingMedia)
                                                              const SizedBox(
                                                                height: 200,
                                                                child: Center(
                                                                  child: CircularProgressIndicator(),
                                                                ),
                                                              )
                                                            else if (state.status == UserSettingsStatus.succeededSearchingMedia) ...[
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
                                                            if (state.status == UserSettingsStatus.succeededSearchingMedia &&
                                                                state.imageSearchComments?.isNotEmpty != true &&
                                                                state.imageSearchPosts?.isNotEmpty != true)
                                                              SizedBox(
                                                                width: double.infinity,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(bottom: 24),
                                                                  child: Container(
                                                                    color: theme.dividerColor.withValues(alpha: 0.1),
                                                                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                                                                    child: ScalableText(
                                                                      l10n.noReferencesToImage,
                                                                      textAlign: TextAlign.center,
                                                                      style: theme.textTheme.titleSmall,
                                                                      fontScale: metadataFontSizeScale,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            if (state.status == UserSettingsStatus.succeededSearchingMedia &&
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
                                            context.read<UserSettingsBloc>().add(
                                                DeleteMediaEvent(deleteToken: state.images![index]['local_image']['pictrs_delete_token'], id: state.images![index]['local_image']['pictrs_alias']));
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
                          child: ScalableText(
                            l10n.noImages,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall,
                            fontScale: metadataFontSizeScale,
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
