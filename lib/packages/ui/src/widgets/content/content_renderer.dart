import 'package:flutter/widgets.dart';

import 'package:thunder/packages/ui/src/models/content/content_action_handlers.dart';

class ContentRenderer extends StatelessWidget {
  const ContentRenderer({
    super.key,
    required this.builder,
    this.handlers = const ContentActionHandlers(),
  });

  final Widget Function(BuildContext context, ContentActionHandlers handlers) builder;
  final ContentActionHandlers handlers;

  @override
  Widget build(BuildContext context) {
    return builder(context, handlers);
  }
}
