import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/image_caching_mode.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_settings_bloc.dart';
import 'package:thunder/utils/media/image.dart';

class MediaManagementPage extends StatelessWidget {
  const MediaManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThunderBloc thunderBloc = context.read<ThunderBloc>();

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
            color: theme.colorScheme.background,
            child: SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    toolbarHeight: 70.0,
                    title: ListTile(
                      title: Text(
                        l10n.manageMedia,
                        style: theme.textTheme.titleLarge,
                      ),
                      subtitle: UserFullNameWidget(context, context.read<AuthBloc>().state.account?.username, context.read<AuthBloc>().state.account?.instance),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                  if (state.status == UserSettingsStatus.listingMedia)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == UserSettingsStatus.deletingMedia || state.status == UserSettingsStatus.failedListingMedia || state.status == UserSettingsStatus.succeededListingMedia) ...[
                    if (state.images?.isNotEmpty == true)
                      SliverList.builder(
                        addSemanticIndexes: false,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        itemCount: state.images!.length,
                        itemBuilder: (context, index) {
                          String url = 'https://${LemmyClient.instance.lemmyApiV3.host}/pictrs/image/${state.images![index].localImage.pictrsAlias}';

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
                                          clearMemoryCacheWhenDispose: thunderBloc.state.imageCachingMode == ImageCachingMode.relaxed,
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
                                                      l10n.unableToLoadImageFrom(LemmyClient.instance.lemmyApiV3.host),
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
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
                                      Text(l10n.uploadedDate(thunderBloc.state.dateFormat?.format(DateTime.parse(state.images![index].localImage.published).toLocal()) ?? '')),
                                      const Spacer(),
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
                                              context
                                                  .read<UserSettingsBloc>()
                                                  .add(DeleteMediaEvent(deleteToken: state.images![index].localImage.pictrsDeleteToken, id: state.images![index].localImage.pictrsAlias));
                                            }
                                          },
                                          icon: const Icon(Icons.delete_forever)),
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
                          color: theme.dividerColor.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: ScalableText(
                            l10n.noImages,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall,
                            fontScale: thunderBloc.state.metadataFontSizeScale,
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
