import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/account/account.dart';

enum FeatureAccountOverrideStatus { inactive, active }

class FeatureAccount extends Equatable {
  const FeatureAccount({required this.baseAccount, this.overrideAccount});

  final Account baseAccount;
  final Account? overrideAccount;

  Account get effectiveAccount => overrideAccount ?? baseAccount;

  bool get hasOverride => overrideAccount != null && overrideAccount!.id != baseAccount.id;

  FeatureAccountOverrideStatus get overrideStatus => hasOverride ? FeatureAccountOverrideStatus.active : FeatureAccountOverrideStatus.inactive;

  FeatureAccount copyWith({Account? baseAccount, Object? overrideAccount = _sentinel}) {
    return FeatureAccount(baseAccount: baseAccount ?? this.baseAccount, overrideAccount: identical(overrideAccount, _sentinel) ? this.overrideAccount : overrideAccount as Account?);
  }

  @override
  List<Object?> get props => [baseAccount, overrideAccount, effectiveAccount, hasOverride, overrideStatus];
}

const Object _sentinel = Object();
