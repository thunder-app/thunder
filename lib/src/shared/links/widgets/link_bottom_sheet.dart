import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show PickerItem;

void handleLinkLongPress(BuildContext context, String text, String? url, {LinkBottomSheetPage initialPage = LinkBottomSheetPage.general, void Function(String)? customNavigation}) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => LinkBottomSheet(
      text: text,
      url: url,
      initialPage: initialPage,
      customNavigation: customNavigation,
    ),
  );
}

enum LinkBottomSheetPage {
  general,
  alternateLinks,
}

class LinkBottomSheet extends StatefulWidget {
  final String? url;
  final String text;
  final LinkBottomSheetPage initialPage;
  final void Function(String)? customNavigation;

  const LinkBottomSheet({
    super.key,
    required this.text,
    required this.url,
    this.initialPage = LinkBottomSheetPage.general,
    this.customNavigation,
  });

  @override
  State<LinkBottomSheet> createState() => _LinkBottomSheetState();
}

class _LinkBottomSheetState extends State<LinkBottomSheet> {
  LinkBottomSheetPage? page;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    bool isValidUrl = widget.url?.startsWith('http') ?? false;

    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
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
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: LinkPreviewGenerator(
                    link: widget.url!,
                    placeholderWidget: const CircularProgressIndicator(),
                    linkPreviewStyle: LinkPreviewStyle.large,
                    cacheDuration: Duration.zero,
                    onTap: null,
                    bodyTextOverflow: TextOverflow.fade,
                    graphicFit: BoxFit.scaleDown,
                    removeElevation: true,
                    backgroundColor: theme.dividerColor.withValues(alpha: 0.25),
                    borderRadius: 10,
                    useDefaultOnTap: false,
                  ),
                ),
                const SizedBox(height: 10),
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
                    child: Text(widget.url!),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if ((page ?? widget.initialPage) == LinkBottomSheetPage.general) ...[
                PickerItem(
                  label: l10n.open,
                  icon: Icons.language,
                  onSelected: () => handleLinkTap(context, widget.text, widget.url),
                ),
                PickerItem(
                  label: l10n.copy,
                  icon: Icons.copy_rounded,
                  onSelected: () => Clipboard.setData(ClipboardData(text: widget.url ?? widget.text)),
                ),
                PickerItem(
                  label: l10n.share,
                  icon: Icons.share_rounded,
                  onSelected: () => SharePlus.instance.share(ShareParams(
                    text: widget.url ?? widget.text,
                    sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                  )),
                ),
                PickerItem(
                  label: l10n.alternateSources,
                  icon: Icons.link_rounded,
                  onSelected: () => setState(() => page = LinkBottomSheetPage.alternateLinks),
                  trailingIcon: Icons.chevron_right_rounded,
                ),
              ],
              if ((page ?? widget.initialPage) == LinkBottomSheetPage.alternateLinks)
                ...generateAlternateSources(widget.url ?? widget.text).map((alternateSource) {
                  return PickerItem(
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
