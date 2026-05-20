import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_detection/keyboard_detection.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/private_message/presentation/widgets/create_private_message/create_private_message_bottom_bar.dart';
import 'package:thunder/src/features/private_message/presentation/widgets/create_private_message/create_private_message_editor_section.dart';
import 'package:thunder/src/features/private_message/presentation/widgets/create_private_message/create_private_message_recipient_tile.dart';
import 'package:thunder/src/features/private_message/presentation/state/create_private_message_cubit.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/foundation/config/global_context.dart';

/// Page for composing and sending a direct message.
class CreatePrivateMessagePage extends StatefulWidget {
  /// Creates a direct-message composer for [account].
  const CreatePrivateMessagePage({
    super.key,
    required this.account,
    this.recipient,
    this.initialContent,
    this.onMessageSent,
  });

  /// Account used to send the message.
  final Account account;

  /// Optional recipient used when the composer is opened from a user action.
  final ThunderUser? recipient;

  /// Optional markdown content used when expanding a quick reply into the full composer.
  final String? initialContent;

  /// Callback invoked after a message is successfully sent.
  final void Function(ThunderPrivateMessage message)? onMessageSent;

  @override
  State<CreatePrivateMessagePage> createState() => _CreatePrivateMessagePageState();
}

class _CreatePrivateMessagePageState extends State<CreatePrivateMessagePage> {
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();
  final KeyboardDetectionController _keyboardDetectionController = KeyboardDetectionController();

  bool _showPreview = false;
  bool _wasKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _bodyController.text = widget.initialContent ?? '';
    _bodyController.addListener(() => context.read<CreatePrivateMessageCubit>().updateContent(_bodyController.text));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreatePrivateMessageCubit>().initialize(
            recipient: widget.recipient,
            content: widget.initialContent,
          );
      _bodyFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  void _selectRecipient(Account account) {
    final l10n = GlobalContext.l10n;

    showUserInputDialog(
      context,
      title: l10n.selectRecipient,
      account: account,
      onUserSelected: (user) => context.read<CreatePrivateMessageCubit>().setRecipient(user),
    );
  }

  Future<void> _submit() async {
    final message = await context.read<CreatePrivateMessageCubit>().submit();
    if (!mounted || message == null) return;

    widget.onMessageSent?.call(message);
    Navigator.of(context).pop(message);
  }

  void _togglePreview() {
    if (!_showPreview) {
      _wasKeyboardVisible = _keyboardDetectionController.stateAsBool(true) ?? false;
      FocusManager.instance.primaryFocus?.unfocus();
    }

    setState(() => _showPreview = !_showPreview);
    if (!_showPreview && _wasKeyboardVisible) {
      _bodyFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return BlocConsumer<CreatePrivateMessageCubit, CreatePrivateMessageState>(
      listener: (context, state) {
        if (state.message?.isNotEmpty == true) {
          showSnackbar(state.message!);
        }
      },
      builder: (context, state) {
        final account = widget.account;

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: KeyboardDetection(
            controller: _keyboardDetectionController,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(l10n.directMessage),
                centerTitle: false,
              ),
              body: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: UserSelector(
                                account: account,
                                enableAccountSwitching: false,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: CreatePrivateMessageRecipientTile(
                                recipient: state.recipient,
                                onTap: () => _selectRecipient(account),
                              ),
                            ),
                            const SizedBox(height: 10),
                            CreatePrivateMessageEditorSection(
                              controller: _bodyController,
                              focusNode: _bodyFocusNode,
                              showPreview: _showPreview,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    CreatePrivateMessageBottomBar(
                      account: account,
                      controller: _bodyController,
                      focusNode: _bodyFocusNode,
                      showPreview: _showPreview,
                      canSubmit: state.canSubmit,
                      status: state.status,
                      onTogglePreview: _togglePreview,
                      onSubmit: _submit,
                    ),
                    Container(
                      height: MediaQuery.of(context).padding.bottom,
                      color: theme.cardColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
