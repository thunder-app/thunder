import 'package:flutter/material.dart';

import 'package:thunder/src/features/post/presentation/state/create_post_cubit.dart';
import 'package:thunder/src/core/config/global_context.dart';

class CreatePostUrlField extends StatelessWidget {
  const CreatePostUrlField({
    super.key,
    required this.controller,
    required this.state,
    required this.onUploadPostImageRequested,
  });

  /// The controller for the URL input field.
  final TextEditingController controller;

  /// The current state of the post creation process, used to display errors and loading states.
  final CreatePostState state;

  /// Callback function to be called when the user requests to upload an image for the post.
  final Future<void> Function() onUploadPostImageRequested;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: l10n.postURL,
        errorText: state.urlError,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: onUploadPostImageRequested,
          icon: state.status == CreatePostStatus.postImageUploadInProgress
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Center(
                    child: SizedBox(
                      width: 18.0,
                      height: 18.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : Icon(Icons.image, semanticLabel: l10n.uploadImage),
        ),
      ),
    );
  }
}
