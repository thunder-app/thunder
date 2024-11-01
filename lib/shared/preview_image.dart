import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/enums/image_caching_mode.dart';
import 'package:thunder/core/enums/theme_type.dart';

import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/links.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 130), lowerBound: 0.0, upperBound: 1.0);
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
    final useDarkTheme = state.themeType == ThemeType.dark || state.themeType == ThemeType.pureBlack;

    double? height = widget.viewMode == ViewMode.compact ? ViewMode.compact.height : (widget.showFullHeightImages ? widget.height : ViewMode.comfortable.height);
    double width = widget.viewMode == ViewMode.compact ? ViewMode.compact.height : MediaQuery.of(context).size.width - 24;

    return ExtendedImage.network(
      widget.mediaUrl,
      height: height,
      width: width,
      fit: widget.viewMode == ViewMode.compact ? BoxFit.cover : BoxFit.fitWidth,
      cache: true,
      clearMemoryCacheWhenDispose: state.imageCachingMode == ImageCachingMode.relaxed,
      cacheWidth: widget.viewMode == ViewMode.compact
          ? (ViewMode.compact.height * View.of(context).devicePixelRatio.ceil()).toInt()
          : ((MediaQuery.of(context).size.width - 24) * View.of(context).devicePixelRatio.ceil()).toInt(),
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            _controller.reset();
            return Container();
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                                  widget.mediaUrl,
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
                    handleLink(context, url: widget.mediaUrl);
                  },
                ),
              ),
            );
        }
      },
    );
  }
}
