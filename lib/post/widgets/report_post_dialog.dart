import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/feed/feed.dart';

import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/snackbar.dart';

class ReportPostDialog extends StatefulWidget {
  const ReportPostDialog({super.key, required this.postId, this.onReport});

  /// A callback function that returns the reason for the report as a [String] to PostCardAction.reportPost:
  /// A post can either be reported using `FeedBloc` (From feed_page) or `PostBloc` (from post_page)

  final void Function(String)? onReport;

  /// An integer representing the ID of the post being reported.

  final int postId;

  @override
  State<ReportPostDialog> createState() => _ReportPostDialogState();
}

class _ReportPostDialogState extends State<ReportPostDialog> {
  /// This variable is used to display the error message to the user when an error occurs.
  String errorMessage = '';

  /// When this flag is set to `true`, it indicates that an error has occurred.
  bool hasError = false;

  late TextEditingController messageController;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(l10n.reportAPost),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: l10n.message(0),
                ),
                autofocus: true,
                controller: messageController,
                maxLines: 4,
              ),
              const SizedBox(
                height: 12,
              ),
              if (hasError)
                AutoSizeText(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.cancel)),
                  const SizedBox(
                    width: 8,
                  ),
                  if (widget.onReport != null)
                    BlocProvider.value(
                      value: context.read<FeedBloc>(),
                      child: FilledButton(
                          onPressed: () {
                            if (messageController.text.isNotEmpty) {
                              widget.onReport!(messageController.text);
                            }
                          },
                          child: BlocConsumer<FeedBloc, FeedState>(
                            listener: (context, state) {
                              switch (state.status) {
                                case FeedStatus.fetching:
                                  setState(() => hasError = false);

                                case FeedStatus.success:
                                  showSnackbar(l10n.postReported);
                                  Navigator.of(context).pop();

                                  break;
                                case FeedStatus.failure:
                                  setState(() {
                                    hasError = true;
                                    errorMessage = state.message ?? l10n.unexpectedError;
                                  });

                                default:
                              }
                            },
                            builder: (context, state) {
                              switch (state.status) {
                                case FeedStatus.fetching:
                                  return const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ));
                                default:
                                  return Text(l10n.submit);
                              }
                            },
                          )),
                    )
                  else
                    FilledButton(
                        onPressed: () {
                          if (messageController.text.isNotEmpty) {
                            context.read<PostBloc>().add(ReportPostEvent(postId: widget.postId, message: messageController.text));
                          }
                        },
                        child: BlocConsumer<PostBloc, PostState>(
                          bloc: context.read<PostBloc>(),
                          listener: (context, state) {
                            switch (state.status) {
                              case PostStatus.loading:
                                setState(() => hasError = false);
                              case PostStatus.refreshing:
                                setState(() => hasError = false);
                              case PostStatus.success:
                                showSnackbar(l10n.postReported);
                                Navigator.of(context).pop();

                              case PostStatus.failure:
                                setState(() {
                                  hasError = true;
                                  errorMessage = state.errorMessage ?? l10n.unexpectedError;
                                });

                              default:
                            }
                          },
                          builder: (context, state) {
                            switch (state.status) {
                              case PostStatus.loading:
                                return const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white));

                              case PostStatus.refreshing:
                                return const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white));
                              default:
                                return Text(l10n.submit);
                            }
                          },
                        ))
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
