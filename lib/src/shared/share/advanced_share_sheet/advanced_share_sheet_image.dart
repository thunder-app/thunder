import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_options.dart';

Future<Uint8List> generateShareImage(BuildContext context, AdvancedShareSheetOptions options, ThunderPost post) {
  final theme = Theme.of(context);

  final themePreferencesCubit = context.read<ThemePreferencesCubit>();

  final view = View.maybeOf(context);
  final viewSize = view == null ? null : view.physicalSize / view.devicePixelRatio;
  final constraints = BoxConstraints(
    maxWidth: viewSize?.width ?? double.infinity,
    maxHeight: double.maxFinite,
  );
  final thumbnailUrl = advancedShareThumbnailUrl(post);

  return _captureSettledLongWidget(
    context: context,
    pixelRatio: 4,
    constraints: constraints,
    child: BlocProvider.value(
      value: themePreferencesCubit,
      child: Container(
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (options.includeTitle) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    post.name,
                    textAlign: TextAlign.left,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
              if (options.includeImage && thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(thumbnailUrl, width: viewSize?.width, fit: BoxFit.fitWidth),
                ),
              if (options.includeText && advancedShareHasText(post)) ...[
                if (thumbnailUrl != null) const SizedBox(height: 10.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CommonMarkdownBody(
                      body: post.body!,
                      isComment: true,
                    ),
                  ),
                ),
              ],
              if (options.includeCommnity && post.community?.actorId.isNotEmpty == true) ...[
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    post.community!.actorId,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

Future<Uint8List> _captureSettledLongWidget({
  required BuildContext context,
  required Widget child,
  required BoxConstraints constraints,
  required double pixelRatio,
}) async {
  final targetSize = await _measureSettledLongWidget(
    context: context,
    child: child,
    constraints: constraints,
  );

  return ScreenshotController().captureFromWidget(
    child,
    context: context,
    targetSize: targetSize,
    pixelRatio: pixelRatio,
    delay: _settleDelay,
  );
}

Future<Size> _measureSettledLongWidget({
  required BuildContext context,
  required Widget child,
  required BoxConstraints constraints,
}) async {
  var isDirty = false;
  var previousSize = Size.zero;

  final pipelineOwner = PipelineOwner();
  final rootView = pipelineOwner.rootNode = _MeasurementView(constraints);
  final buildOwner = BuildOwner(
    focusManager: FocusManager(),
    onBuildScheduled: () => isDirty = true,
  );

  final element = RenderObjectToWidgetAdapter<RenderBox>(
    container: rootView,
    debugShortDescription: 'advanced_share_image_measurement',
    child: Directionality(
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: _inheritCaptureContext(context, child),
    ),
  ).attachToRenderTree(buildOwner);

  try {
    rootView.scheduleInitialLayout();

    for (var pass = 0; pass < _maxSettlePasses; pass++) {
      isDirty = false;
      buildOwner.buildScope(element);
      buildOwner.finalizeTree();
      pipelineOwner.flushLayout();

      final currentSize = rootView.size;
      if (!isDirty && currentSize == previousSize) break;

      previousSize = currentSize;
      await Future<void>.delayed(_settleDelay);
    }

    buildOwner.buildScope(element);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();

    return rootView.size;
  } finally {
    element.update(RenderObjectToWidgetAdapter<RenderBox>(container: rootView));
    buildOwner.finalizeTree();
  }
}

Widget _inheritCaptureContext(BuildContext context, Widget child) {
  return InheritedTheme.captureAll(
    context,
    MediaQuery(
      data: MediaQuery.of(context),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    ),
  );
}

class _MeasurementView extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  _MeasurementView(this.boxConstraints);

  final BoxConstraints boxConstraints;

  @override
  void performLayout() {
    assert(child != null);
    child!.layout(boxConstraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}

const _settleDelay = Duration(milliseconds: 250);
const _maxSettlePasses = 4;
