import 'package:flutter/cupertino.dart';

class MarkdownTextEditingController extends TextEditingController {
  void makeBold() => _addAroundSelection("**");

  void makeItalic() => _addAroundSelection("_");

  void makeQuote() => _addBeforeSelection("> ");

  void makeStrikethrough() => _addAroundSelection("~~");

  void makeList() => _addBeforeSelection("* ");

  void makeCode() => _addAroundSelection("```");

  void makeSeparator() => _addAfterSelection("\n\n------\n");

  void makeLink() {
    _addAfterSelection("](URL)");
    _addBeforeSelection("[");
  }

  void _addBeforeSelection(String toAdd) {
    value = value.copyWith(
        text: text.replaceRange(selection.start, selection.start, toAdd),
        selection: selection.copyWith(baseOffset: selection.baseOffset + toAdd.length, extentOffset: selection.extentOffset + toAdd.length));
  }

  void _addAfterSelection(String toAdd) {
    value = value.copyWith(text: text.replaceRange(selection.end, selection.end, toAdd));
  }

  void _addAroundSelection(String toAdd) {
    _addAfterSelection(toAdd);
    _addBeforeSelection(toAdd);
  }
}
