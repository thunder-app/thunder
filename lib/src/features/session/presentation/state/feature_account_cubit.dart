import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/session/domain/models/feature_account.dart';

part 'feature_account_state.dart';

class FeatureAccountCubit extends Cubit<FeatureAccountState> {
  FeatureAccountCubit({required Account baseAccount}) : super(FeatureAccountState.initial(baseAccount));

  void syncBaseAccount(Account baseAccount) {
    final overrideAccount = state.overrideAccount;

    if (overrideAccount != null && overrideAccount.id == baseAccount.id) {
      emit(FeatureAccountState.initial(baseAccount));
      return;
    }

    emit(state.copyWith(featureAccount: state.featureAccount.copyWith(baseAccount: baseAccount)));
  }

  void setOverride(Account overrideAccount) {
    if (overrideAccount.id == state.baseAccount.id) {
      clearOverride();
      return;
    }

    emit(state.copyWith(featureAccount: state.featureAccount.copyWith(overrideAccount: overrideAccount)));
  }

  void clearOverride() {
    emit(state.copyWith(featureAccount: state.featureAccount.copyWith(overrideAccount: null)));
  }
}
