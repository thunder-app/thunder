import 'package:flutter/widgets.dart';

typedef ParentBuilder = Widget Function(Widget child);

/// {@template conditionalParent}
/// Conditionally wrap a subtree with a parent widget without breaking the code tree.
///
/// - [condition]           controls how/whether the [child] is wrapped.
/// - [child]               the subtree that should always be build.
/// - [parentBuilder]       build this parent with the subtree [child] if [condition] is `true`.
/// - [parentBuilderElse]   build this parent with the subtree [child] if [condition] is `false`.
///                         return [child] if [condition] is `false` and [parentBuilderElse] is null.
///
/// ___________
/// Tree will look like:
/// ```dart
/// return SomeWidget(
///   child: SomeOtherWidget(
///     child: ConditionalParentWidget(
///       condition: shouldIncludeParent,
///       parentBuilder: (Widget child) => SomeParentWidget(child: child),
///       child: Widget1(
///         child: Widget2(
///           child: Widget3(),
///         ),
///       ),
///     ),
///   ),
/// );
/// ```
///
/// ___________
/// Instead of:
/// ```dart
/// Widget child = Widget1(
///   child: Widget2(
///     child: Widget3(),
///   ),
/// );
///
/// return SomeWidget(
///   child: SomeOtherWidget(
///     child: shouldIncludeParent
///       ? SomeParentWidget(child: child)
///       : child
///   ),
/// );
/// ```
/// {@endtemplate}
class ConditionalParentWidget extends StatelessWidget {
  /// {@macro conditionalParent}
  const ConditionalParentWidget({
    super.key,
    required this.condition,
    required this.parentBuilder,
    this.parentBuilderElse,
    required this.child,
  });

  /// The [condition] which controls how/whether the [child] is wrapped.
  final bool condition;

  /// The [child] which should be conditionally wrapped.
  final Widget child;

  /// Builder to wrap [child] when [condition] is `true`.
  final ParentBuilder? parentBuilder;

  /// Optional builder to wrap [child] when [condition] is `false`.
  ///
  /// [child] is returned directly when this is `null`.
  final ParentBuilder? parentBuilderElse;

  @override
  Widget build(BuildContext context) {
    return condition //
        ? parentBuilder?.call(child) ?? child
        : parentBuilderElse?.call(child) ?? child;
  }
}
