import 'package:flutter/material.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/settings/widgets/post_placeholder.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

enum SwipePickerSide { left, right }

class SwipePickerItem {
  String label;
  List<ListPickerItem<SwipeAction>> options;
  SwipeAction value;
  final void Function(ListPickerItem<SwipeAction>) onChanged;

  SwipePickerItem({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });
}

class SwipePicker<T> extends StatelessWidget {
  final SwipePickerSide side;
  final List<SwipePickerItem> items;

  const SwipePicker({super.key, required this.side, required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 1,
            top: 1,
            bottom: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (side == SwipePickerSide.left && items.isNotEmpty)
                SizedBox(
                  width: 100,
                  height: 65,
                  child: Material(
                    color: items[0].value.getColor(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (context) => BottomSheetListPicker(
                            title: items[0].label,
                            items: items[0].options,
                            onSelect: (value) async {
                              items[0].onChanged(value);
                            },
                            previouslySelected: items[0].value,
                          ),
                        );
                      },
                      child: Icon(
                        items[0].value.getIcon(),
                        semanticLabel: 'Short swipe right, ${items[0].value.label}',
                      ),
                    ),
                  ),
                ),
              if (side == SwipePickerSide.left && items.length >= 2)
                SizedBox(
                  width: 100,
                  height: 65,
                  child: Material(
                    color: items[1].value.getColor(context),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (context) => BottomSheetListPicker(
                            title: items[1].label,
                            items: items[1].options,
                            onSelect: (value) async {
                              items[1].onChanged(value);
                            },
                            previouslySelected: items[1].value,
                          ),
                        );
                      },
                      child: Icon(
                        items[1].value.getIcon(),
                        semanticLabel: 'Long swipe right, ${items[1].value.label}',
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  height: 65,
                  decoration: const BoxDecoration(),
                  child: const PostPlaceholder(),
                ),
              ),
              if (side == SwipePickerSide.right && items.length >= 2)
                SizedBox(
                  width: 100,
                  height: 65,
                  child: Material(
                    color: items[1].value.getColor(context),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (context) => BottomSheetListPicker(
                            title: items[1].label,
                            items: items[1].options,
                            onSelect: (value) async {
                              items[1].onChanged(value);
                            },
                            previouslySelected: items[1].value,
                          ),
                        );
                      },
                      child: Icon(
                        items[1].value.getIcon(),
                        semanticLabel: 'Long swipe left, ${items[1].value.label}',
                      ),
                    ),
                  ),
                ),
              if (side == SwipePickerSide.right && items.isNotEmpty)
                SizedBox(
                  width: 100,
                  height: 65,
                  child: Material(
                    color: items[0].value.getColor(context),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (context) => BottomSheetListPicker(
                            title: items[0].label,
                            items: items[0].options,
                            onSelect: (value) async {
                              items[0].onChanged(value);
                            },
                            previouslySelected: items[0].value,
                          ),
                        );
                      },
                      child: Icon(
                        items[0].value.getIcon(),
                        semanticLabel: 'Short swipe left, ${items[0].value.label}',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
