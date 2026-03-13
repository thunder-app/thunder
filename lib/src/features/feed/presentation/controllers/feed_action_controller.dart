import 'dart:async';

import 'package:flutter/widgets.dart';

typedef FeedScrollToTopCallback = Future<void> Function();
typedef FeedDismissReadCallback = Future<void> Function();
typedef FeedDismissBlockedCallback = Future<void> Function({int? userId, int? communityId});
typedef FeedDismissHiddenPostCallback = Future<void> Function(int postId);

class FeedActionController {
  FeedScrollToTopCallback? _scrollToTop;
  FeedDismissReadCallback? _dismissRead;
  FeedDismissBlockedCallback? _dismissBlocked;
  FeedDismissHiddenPostCallback? _dismissHiddenPost;

  Object? _bindingToken;

  void bind({
    required Object token,
    required FeedScrollToTopCallback scrollToTop,
    required FeedDismissReadCallback dismissRead,
    required FeedDismissBlockedCallback dismissBlocked,
    required FeedDismissHiddenPostCallback dismissHiddenPost,
  }) {
    _bindingToken = token;
    _scrollToTop = scrollToTop;
    _dismissRead = dismissRead;
    _dismissBlocked = dismissBlocked;
    _dismissHiddenPost = dismissHiddenPost;
  }

  void unbind(Object token) {
    if (_bindingToken != token) {
      return;
    }

    _bindingToken = null;
    _scrollToTop = null;
    _dismissRead = null;
    _dismissBlocked = null;
    _dismissHiddenPost = null;
  }

  Future<void> scrollToTop() async => _scrollToTop?.call();

  Future<void> dismissRead() async => _dismissRead?.call();

  Future<void> dismissBlocked({int? userId, int? communityId}) async => _dismissBlocked?.call(userId: userId, communityId: communityId);

  Future<void> dismissHiddenPost(int postId) async => _dismissHiddenPost?.call(postId);
}

class FeedActionScope extends InheritedWidget {
  const FeedActionScope({super.key, required this.controller, required super.child});

  final FeedActionController controller;

  static FeedActionController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FeedActionScope>()?.controller;
  }

  @override
  bool updateShouldNotify(FeedActionScope oldWidget) => controller != oldWidget.controller;
}
