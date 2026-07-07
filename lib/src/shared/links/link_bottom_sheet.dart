import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/presentation/utils/effective_account_context.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_link_metadata.dart';
import 'package:thunder/src/features/post/data/repositories/link_metadata_repository.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Handles the long press on a link by showing a bottom sheet with the link details.
void handleLinkLongPress(
  BuildContext context,
  String text,
  String? url, {
  LinkBottomSheetPage initialPage = LinkBottomSheetPage.general,
  String? preferredImageUrl,
  void Function(String)? customNavigation,
}) {
  HapticFeedback.mediumImpact();

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => LinkBottomSheet(
      text: text,
      url: url,
      initialPage: initialPage,
      preferredImageUrl: preferredImageUrl,
      customNavigation: customNavigation,
    ),
  );
}

/// The pages that can be displayed in the link bottom sheet
enum LinkBottomSheetPage {
  general,
  alternateLinks,
}

/// A bottom sheet that displays the link details.
class LinkBottomSheet extends StatefulWidget {
  /// The URL of the link
  final String? url;

  /// The text of the link
  final String text;

  /// The initial page to display
  final LinkBottomSheetPage initialPage;

  /// The function to call when the user wants to navigate to a custom URL
  final void Function(String)? customNavigation;

  /// The preferred image URL to display before falling back to fetched metadata.
  final String? preferredImageUrl;

  const LinkBottomSheet({
    super.key,
    required this.text,
    required this.url,
    this.initialPage = LinkBottomSheetPage.general,
    this.preferredImageUrl,
    this.customNavigation,
  });

  @override
  State<LinkBottomSheet> createState() => _LinkBottomSheetState();
}

class _LinkBottomSheetState extends State<LinkBottomSheet> {
  LinkBottomSheetPage? page;
  Future<ThunderLinkMetadata?>? _linkMetadataFuture;
  String? _linkMetadataUrl;
  String? _linkMetadataAccountKey;

  Account? _resolveMetadataAccount(BuildContext context) {
    try {
      return resolveEffectiveAccount(context);
    } catch (_) {
      return null;
    }
  }

  void _ensureLinkMetadataFuture(Account? account) {
    final url = widget.url?.trim();

    if (account == null || url == null || !url.toLowerCase().startsWith('http')) {
      _linkMetadataFuture = null;
      _linkMetadataUrl = url;
      _linkMetadataAccountKey = null;
      return;
    }

    final accountKey = '${account.id}:${account.instance}:${account.platform}';

    if (_linkMetadataFuture != null && _linkMetadataUrl == url && _linkMetadataAccountKey == accountKey) {
      return;
    }

    _linkMetadataUrl = url;
    _linkMetadataAccountKey = accountKey;
    _linkMetadataFuture = LinkMetadataRepositoryImpl(account: account).getLinkMetadata(url: url);
  }

  Widget _buildLinkMetadataPreviewSection(ThemeData theme) {
    final metadataFuture = _linkMetadataFuture;
    final preferredImageUrl = widget.preferredImageUrl;

    if (metadataFuture == null && preferredImageUrl == null) {
      return const SizedBox.shrink();
    }

    if (metadataFuture == null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Container(
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: preferredImageUrl!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return FutureBuilder<ThunderLinkMetadata?>(
      future: metadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        }

        final metadata = snapshot.data;
        final hasMetadataContent = metadata?.hasContent ?? false;
        if (!hasMetadataContent && preferredImageUrl == null) {
          return const SizedBox.shrink();
        }

        final title = metadata?.title;
        final description = metadata?.description;
        final imageUrl = preferredImageUrl ?? metadata?.imageUrl;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    if (title != null || description != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                            if (title != null && description != null) const SizedBox(height: 6),
                            if (description != null)
                              Text(
                                description,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final normalizedUrl = widget.url?.trim();
    final isValidUrl = normalizedUrl?.toLowerCase().startsWith('http') ?? false;
    final resolvedUrl = normalizedUrl?.isNotEmpty == true ? normalizedUrl! : widget.text;
    final metadataAccount = isValidUrl ? _resolveMetadataAccount(context) : null;

    _ensureLinkMetadataFuture(metadataAccount);

    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Material(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: (page ?? widget.initialPage) == LinkBottomSheetPage.general ? null : () => setState(() => page = LinkBottomSheetPage.general),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            if ((page ?? widget.initialPage) != LinkBottomSheetPage.general) ...[
                              const Icon(Icons.chevron_left, size: 30),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              switch (page ?? widget.initialPage) {
                                LinkBottomSheetPage.alternateLinks => l10n.alternateSources,
                                _ => l10n.linkActions,
                              },
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (isValidUrl && (page ?? widget.initialPage) == LinkBottomSheetPage.general) ...[
                _buildLinkMetadataPreviewSection(theme),
              ],
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      resolvedUrl.characters.join('\u200B'), // Add a zero-width space to allow the text to wrap at any character
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if ((page ?? widget.initialPage) == LinkBottomSheetPage.general) ...[
                ThunderPickerItem(
                  label: l10n.open,
                  icon: Icons.language,
                  onSelected: () => handleLinkTap(context, widget.text, widget.url),
                ),
                ThunderPickerItem(
                  label: l10n.copy,
                  icon: Icons.copy_rounded,
                  onSelected: () => Clipboard.setData(ClipboardData(text: widget.url ?? widget.text)),
                ),
                ThunderPickerItem(
                  label: l10n.share,
                  icon: Icons.share_rounded,
                  onSelected: () => SharePlus.instance.share(ShareParams(
                    text: widget.url ?? widget.text,
                    sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                  )),
                ),
                ThunderPickerItem(
                  label: l10n.alternateSources,
                  icon: Icons.link_rounded,
                  onSelected: () => setState(() => page = LinkBottomSheetPage.alternateLinks),
                  trailingIcon: Icons.chevron_right_rounded,
                ),
              ],
              if ((page ?? widget.initialPage) == LinkBottomSheetPage.alternateLinks)
                ...generateAlternateSources(widget.url ?? widget.text).map((alternateSource) {
                  return ThunderPickerItem(
                    label: alternateSource.sourceName,
                    subtitle: alternateSource.link,
                    icon: Icons.archive_rounded,
                    onSelected: () {
                      if (widget.customNavigation != null) {
                        widget.customNavigation!.call(alternateSource.link);
                      } else {
                        handleLink(context, url: alternateSource.link);
                      }

                      Navigator.of(context).pop();
                    },
                    trailingIcon: Icons.chevron_right_rounded,
                  );
                }),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}
