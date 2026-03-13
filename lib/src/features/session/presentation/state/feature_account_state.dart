part of 'feature_account_cubit.dart';

class FeatureAccountState extends Equatable {
  const FeatureAccountState({required this.featureAccount});

  factory FeatureAccountState.initial(Account baseAccount) {
    return FeatureAccountState(featureAccount: FeatureAccount(baseAccount: baseAccount));
  }

  final FeatureAccount featureAccount;

  Account get baseAccount => featureAccount.baseAccount;

  Account get effectiveAccount => featureAccount.effectiveAccount;

  Account? get overrideAccount => featureAccount.overrideAccount;

  bool get hasOverride => featureAccount.hasOverride;

  FeatureAccountOverrideStatus get overrideStatus => featureAccount.overrideStatus;

  FeatureAccountState copyWith({FeatureAccount? featureAccount}) {
    return FeatureAccountState(featureAccount: featureAccount ?? this.featureAccount);
  }

  @override
  List<Object?> get props => [featureAccount, baseAccount, effectiveAccount, overrideAccount, hasOverride, overrideStatus];
}
