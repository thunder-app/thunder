import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/navigation/navigation_private_message.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/private_message/domain/utils/private_message_thread_utils.dart';
import 'package:thunder/src/features/private_message/presentation/state/private_message_thread_cubit.dart';
import 'package:thunder/src/features/private_message/presentation/widgets/thread/private_message_bubble.dart';
import 'package:thunder/src/features/private_message/presentation/widgets/thread/quick_reply_bar.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/avatars/user_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';

/// Page showing a direct-message conversation with one participant.
class PrivateMessageThreadPage extends StatefulWidget {
  /// Creates a direct-message thread page.
  const PrivateMessageThreadPage({
    super.key,
    required this.account,
    required this.participant,
    this.onThreadUpdated,
  });

  /// Account viewing the thread.
  final Account account;

  /// User on the other side of the thread.
  final ThunderUser participant;

  /// Callback invoked with the latest local messages when the thread closes.
  final ValueChanged<List<ThunderPrivateMessage>>? onThreadUpdated;

  @override
  State<PrivateMessageThreadPage> createState() => _PrivateMessageThreadPageState();
}

class _PrivateMessageThreadPageState extends State<PrivateMessageThreadPage> {
  final TextEditingController _quickReplyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final PrivateMessageThreadCubit _cubit;
  int _previousMessageCount = 0;
  PrivateMessageThreadStatus _previousStatus = PrivateMessageThreadStatus.initial;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PrivateMessageThreadCubit>();
    _previousMessageCount = _cubit.state.messages.length;
    _previousStatus = _cubit.state.status;
    _quickReplyController.addListener(() => _cubit.updateQuickReply(_quickReplyController.text));
    if (_cubit.state.messages.isNotEmpty) {
      _scrollToLatest();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _cubit.load());
  }

  @override
  void dispose() {
    widget.onThreadUpdated?.call(_cubit.state.messages);
    _quickReplyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls to the newest message at the bottom of the list.
  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _openComposer() async {
    final cubit = context.read<PrivateMessageThreadCubit>();
    final result = await navigateToCreatePrivateMessagePage(
      context,
      account: widget.account,
      recipient: widget.participant,
      initialContent: cubit.state.quickReply,
    );

    if (!mounted || result == null) return;
    if (!_belongsToCurrentThread(result)) return;

    cubit.appendMessage(result);
    _quickReplyController.clear();
  }

  bool _belongsToCurrentThread(ThunderPrivateMessage message) {
    final participant = otherPrivateMessageParticipant(message, widget.account);
    if (participant == null) return false;

    if (participant.actorId.isNotEmpty && widget.participant.actorId.isNotEmpty) {
      return participant.actorId == widget.participant.actorId;
    }

    return participant.id == widget.participant.id;
  }

  Future<void> _sendQuickReply() async {
    final message = await _cubit.sendQuickReply();
    if (message != null) {
      _quickReplyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrivateMessageThreadCubit, PrivateMessageThreadState>(
      listenWhen: (previous, current) => previous.messages.length != current.messages.length || previous.status != current.status || previous.message != current.message,
      listener: (context, state) {
        if (state.message?.isNotEmpty == true) {
          showThunderSnackbar(state.message!);
        }

        final messagesGrew = state.messages.length > _previousMessageCount;
        final finishedInitialLoad =
            _previousStatus == PrivateMessageThreadStatus.loading && _previousMessageCount == 0 && state.status == PrivateMessageThreadStatus.success && state.messages.isNotEmpty;

        if (messagesGrew || finishedInitialLoad) {
          _scrollToLatest();
        }

        _previousMessageCount = state.messages.length;
        _previousStatus = state.status;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                UserAvatar(user: widget.participant, radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: UserFullNameWidget(
                    name: widget.participant.name,
                    displayName: widget.participant.displayName,
                    instance: fetchInstanceNameFromUrl(widget.participant.actorId),
                    includeInstance: true,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: state.status == PrivateMessageThreadStatus.loading && state.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                              sliver: SliverList.builder(
                                itemCount: state.messages.length,
                                itemBuilder: (context, index) {
                                  final message = state.messages[index];
                                  return PrivateMessageBubble(
                                    account: widget.account,
                                    message: message,
                                  );
                                },
                              ),
                            ),
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: SizedBox.shrink(),
                            ),
                          ],
                        ),
                ),
                QuickReplyBar(
                  controller: _quickReplyController,
                  canSend: state.canSendQuickReply,
                  sending: state.status == PrivateMessageThreadStatus.sending,
                  onOpenComposer: _openComposer,
                  onSend: _sendQuickReply,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
