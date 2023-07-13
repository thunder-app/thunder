import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:url_launcher/url_launcher.dart' hide launch;

class PreviewImage extends StatefulWidget {
  final ViewMode viewMode;
  final bool showFullHeightImages;
  final String mediaUrl;
  final double? height;

  const PreviewImage({
    super.key,
    required this.viewMode,
    required this.showFullHeightImages,
    required this.mediaUrl,
    this.height,
  });

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.0, upperBound: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;
    final useDarkTheme = state.themeType == 'dark';

    final openInExternalBrowser = state.openInExternalBrowser;

    double? height = widget.viewMode == ViewMode.compact ? 75 : (widget.showFullHeightImages ? widget.height : 150);
    double width = widget.viewMode == ViewMode.compact ? 75 : MediaQuery.of(context).size.width - 24;

    return Hero(
      tag: widget.mediaUrl!,
      child: ExtendedImage.network(
        widget.mediaUrl!,
        height: height,
        width: width,
        fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
        cache: true,
        clearMemoryCacheWhenDispose: true,
        cacheWidth:
            widget.viewMode == ViewMode.compact ? (75 * View.of(context).devicePixelRatio.ceil()) : ((MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt(),
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              _controller.reset();

              return Container(
                color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
                child: SizedBox(
                  height: height,
                  width: width,
                  child: const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator())),
                ),
              );
            case LoadState.completed:
              if (state.wasSynchronouslyLoaded) {
                return state.completedWidget;
              }
              _controller.forward();

              return FadeTransition(
                opacity: _controller,
                child: state.completedWidget,
              );
            case LoadState.failed:
              _controller.reset();

              state.imageProvider.evict();

              return Container(
                color: useDarkTheme ? Colors.grey.shade900 : Colors.grey.shade300,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: InkWell(
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        fit: StackFit.passthrough,
                        children: [
                          Container(
                            color: Colors.grey.shade900,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(
                                    Icons.link,
                                    color: Colors.white60,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.mediaUrl ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (widget.mediaUrl != null) {
                        if (openInExternalBrowser) {
                          launchUrl(Uri.parse(widget.mediaUrl!), mode: LaunchMode.externalApplication);
                        } else {
                          launch(widget.mediaUrl!,
                            customTabsOption: CustomTabsOption(
                              toolbarColor: Theme.of(context).canvasColor,
                              enableUrlBarHiding: true,
                              showPageTitle: true,
                              enableDefaultShare: true,
                              enableInstantApps: true,
                            ),
                            safariVCOption: SafariViewControllerOption(
                              preferredBarTintColor: Theme.of(context).canvasColor,
                              preferredControlTintColor: Theme.of(context).textTheme.titleLarge?.color ?? Theme.of(context).primaryColor,
                              barCollapsingEnabled: true,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
