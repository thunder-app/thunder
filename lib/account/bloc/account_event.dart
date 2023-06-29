part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class GetAccountInformation extends AccountEvent {}

class GetAccountContent extends AccountEvent {
  final bool reset;

  const GetAccountContent({this.reset = false});
}

class VotePostEvent extends AccountEvent {
  final int postId;
  final VoteType score;

  const VotePostEvent({required this.postId, required this.score});
}

class SavePostEvent extends AccountEvent {
  final int postId;
  final bool save;

  const SavePostEvent({required this.postId, required this.save});
}
