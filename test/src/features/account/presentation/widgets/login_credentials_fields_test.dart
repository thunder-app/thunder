import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';
import 'package:thunder/src/features/account/presentation/widgets/login/login_credentials_fields.dart';
import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';
import 'package:thunder/src/core/domain/models/thunder_instance_info.dart';

import '../../../../../helpers/test_setup.dart';
import '../../../../../helpers/widget_test_harness.dart';

class _TestInstanceValidationCubit extends InstanceValidationCubit {
  _TestInstanceValidationCubit(InstanceValidationState initialState)
      : super(
          discoveryLookup: (_, {timeout}) async => null,
          metadataLookup: (_) async => const ThunderInstanceInfo(domain: '', name: '', success: false),
        ) {
    emit(initialState);
  }
}

void main() {
  setUpAll(setUpRepositoryTests);

  testWidgets('shows TOTP field for Lemmy instances', (tester) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final totpController = TextEditingController();
    final isSubmitting = ValueNotifier(false);

    addTearDown(usernameController.dispose);
    addTearDown(passwordController.dispose);
    addTearDown(totpController.dispose);
    addTearDown(isSubmitting.dispose);

    await pumpLocalizedWidget(
      tester,
      BlocProvider<InstanceValidationCubit>(
        create: (_) => _TestInstanceValidationCubit(
          const InstanceValidationState(platform: ThreadiversePlatform.lemmy),
        ),
        child: LoginCredentialsFields(
          usernameController: usernameController,
          passwordController: passwordController,
          totpController: totpController,
          usernameFocusNode: FocusNode(),
          isSubmitting: isSubmitting,
          onSubmit: () async {},
        ),
      ),
    );

    expect(find.byKey(const Key('login-totp-field')), findsOneWidget);
  });

  testWidgets('hides TOTP field for PieFed instances', (tester) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final totpController = TextEditingController();
    final isSubmitting = ValueNotifier(false);

    addTearDown(usernameController.dispose);
    addTearDown(passwordController.dispose);
    addTearDown(totpController.dispose);
    addTearDown(isSubmitting.dispose);

    await pumpLocalizedWidget(
      tester,
      BlocProvider<InstanceValidationCubit>(
        create: (_) => _TestInstanceValidationCubit(
          const InstanceValidationState(platform: ThreadiversePlatform.piefed),
        ),
        child: LoginCredentialsFields(
          usernameController: usernameController,
          passwordController: passwordController,
          totpController: totpController,
          usernameFocusNode: FocusNode(),
          isSubmitting: isSubmitting,
          onSubmit: () async {},
        ),
      ),
    );

    expect(find.byKey(const Key('login-totp-field')), findsNothing);
  });
}
