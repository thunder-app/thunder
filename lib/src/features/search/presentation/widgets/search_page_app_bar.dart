import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/config/config.dart';

/// The app bar for the search page containing the search bar.
class SearchPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The text controller for the search field.
  final TextEditingController controller;

  /// The focus node for the search field.
  final FocusNode focusNode;

  /// The hint text to display in the search field.
  final String hintText;

  /// Called when the search text changes.
  final ValueChanged<String> onChanged;

  /// Called when the clear button is pressed.
  final VoidCallback onClear;

  const SearchPageAppBar({super.key, required this.controller, required this.focusNode, required this.hintText, required this.onChanged, required this.onClear});

  @override
  Size get preferredSize => const Size.fromHeight(APP_BAR_HEIGHT);

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return AppBar(
      toolbarHeight: APP_BAR_HEIGHT,
      scrolledUnderElevation: 0.0,
      title: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => SearchBar(
          elevation: WidgetStateProperty.all(0.0),
          controller: controller,
          focusNode: focusNode,
          hintText: hintText,
          keyboardType: (!kIsWeb && Platform.isIOS) ? TextInputType.text : TextInputType.url,
          onChanged: onChanged,
          onTap: () => HapticFeedback.selectionClick(),
          leading: const Padding(padding: EdgeInsets.only(left: 8.0), child: Icon(Icons.search_rounded)),
          trailing: controller.text.isNotEmpty
              ? [
                  IconButton(
                    icon: Icon(Icons.close, semanticLabel: l10n.clearSearch),
                    onPressed: onClear,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
