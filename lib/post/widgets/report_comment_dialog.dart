import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/snackbar.dart';

class ReportCommentDialog extends StatefulWidget {
  const ReportCommentDialog({super.key, required this.commentId});

  final int commentId;
  @override
  State<ReportCommentDialog> createState() => _ReportCommentDialogState();
}

class _ReportCommentDialogState extends State<ReportCommentDialog> {
  late TextEditingController messageController;
  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                '${AppLocalizations.of(context)!.report} ${AppLocalizations.of(context)!.comment}',
              ),
              const SizedBox(
                height: 12,
              ),
              TextFormField(
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!.message(0),
                ),
                autofocus: true,
                controller: messageController,
                maxLines: 4,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  BlocConsumer<PostBloc, PostState>(
                    bloc: context.read<PostBloc>(),
                    listener: (context, state) {
                      switch (state.status) {
                        case PostStatus.success:
                          showSnackbar(
                            context,
                            AppLocalizations.of(context)!.commentReported,
                          );
                          Navigator.of(context).pop();
                          break;
                        case PostStatus.failure:
                          showSnackbar(context, state.errorMessage ?? AppLocalizations.of(context)!.unexpectedError);
                        default:
                      }
                    },
                    builder: (context, state) {
                      switch (state.status) {
                        case PostStatus.loading:
                          return const CircularProgressIndicator.adaptive();

                        case PostStatus.refreshing:
                          return const CircularProgressIndicator.adaptive();
                        default:
                          return FilledButton(
                              onPressed: () {
                                if (messageController.text.isNotEmpty) {
                                  context.read<PostBloc>().add(
                                        ReportCommentEvent(
                                          commentId: widget.commentId,
                                          message: messageController.text,
                                        ),
                                      );
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.submit,
                              ));
                      }
                    },
                  )
                ],
              ),
              const SizedBox(
                height: kToolbarHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
