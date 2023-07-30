import 'package:flutter/material.dart';

class PostPlaceholder extends StatelessWidget {
  const PostPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 2),
            child: Container(
              width: 100,
              height: 10,
              decoration: BoxDecoration(
                color: theme.hintColor.withOpacity(.25),
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(5, 5),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
            child: Container(
              width: 75,
              height: 10,
              decoration: BoxDecoration(
                color: theme.hintColor.withOpacity(.1),
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(5, 5),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 0, 10),
            child: Container(
              width: 75,
              height: 10,
              decoration: BoxDecoration(
                color: theme.hintColor.withOpacity(.1),
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(5, 5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
