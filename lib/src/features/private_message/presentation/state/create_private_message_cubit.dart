import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/private_message/data/repositories/private_message_repository.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

part 'create_private_message_state.dart';

/// Coordinates recipient selection, body edits, and submission for direct messages.
class CreatePrivateMessageCubit extends Cubit<CreatePrivateMessageState> {
  /// Creates a cubit for composing direct messages from [account].
  CreatePrivateMessageCubit({
    required this.account,
    required PrivateMessageRepository Function(Account account) privateMessageRepository,
    required SearchRepository Function(Account account) searchRepository,
    required LocalizationService localizationService,
  })  : _privateMessageRepository = privateMessageRepository(account),
        _searchRepository = searchRepository(account),
        _localizationService = localizationService,
        super(const CreatePrivateMessageState());

  /// Account currently used to send direct messages.
  final Account account;
  final LocalizationService _localizationService;

  final PrivateMessageRepository _privateMessageRepository;
  final SearchRepository _searchRepository;

  /// Initializes the composer with optional pre-filled recipient and content.
  void initialize({ThunderUser? recipient, String? content}) {
    emit(state.copyWith(
      status: CreatePrivateMessageStatus.initial,
      recipient: recipient,
      content: content ?? '',
      message: null,
      errorReason: null,
      privateMessage: null,
    ));
  }

  /// Sets the selected recipient.
  void setRecipient(ThunderUser? recipient) {
    emit(state.copyWith(
      status: CreatePrivateMessageStatus.initial,
      recipient: recipient,
      suggestions: const <ThunderUser>[],
      message: null,
      errorReason: null,
    ));
  }

  /// Updates the message body.
  void updateContent(String content) {
    if (content == state.content) return;
    emit(state.copyWith(content: content, message: null, errorReason: null));
  }

  /// Searches for users that can be selected as recipients.
  Future<void> searchRecipients(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(status: CreatePrivateMessageStatus.initial, suggestions: const <ThunderUser>[]));
      return;
    }

    try {
      emit(state.copyWith(status: CreatePrivateMessageStatus.searching, message: null, errorReason: null));
      final results = await _searchRepository.search(query: trimmed, type: MetaSearchType.users, limit: 20);
      emit(state.copyWith(status: CreatePrivateMessageStatus.initial, suggestions: results.users));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: CreatePrivateMessageStatus.error,
        message: message,
        errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
      ));
    }
  }

  /// Sends the direct message when the current state is valid.
  Future<ThunderPrivateMessage?> submit() async {
    final l10n = _localizationService.l10n;
    final recipient = state.recipient;
    final content = state.content.trim();

    if (account.anonymous) {
      emit(state.copyWith(
        status: CreatePrivateMessageStatus.error,
        message: l10n.userNotLoggedIn,
        errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
      ));
      return null;
    }

    if (recipient == null || content.isEmpty) {
      emit(state.copyWith(
        status: CreatePrivateMessageStatus.error,
        message: l10n.missingErrorMessage,
        errorReason: AppErrorReason.validation(message: l10n.missingErrorMessage),
      ));
      return null;
    }

    try {
      emit(state.copyWith(status: CreatePrivateMessageStatus.submitting, message: null, errorReason: null));
      final privateMessage = await _privateMessageRepository.create(recipientId: recipient.id, content: content);
      emit(state.copyWith(
        status: CreatePrivateMessageStatus.success,
        privateMessage: privateMessage,
        content: '',
        message: null,
        errorReason: null,
      ));
      return privateMessage;
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: CreatePrivateMessageStatus.error,
        message: message,
        errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
      ));
      return null;
    }
  }
}
