import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
<<<<<<< HEAD
import 'package:lemmy/lemmy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
=======
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/account/models/account.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
<<<<<<< HEAD
    on<ClearAuth>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.remove('jwt');
      prefs.remove('instance');
      prefs.remove('username');

      await Future.delayed(const Duration(milliseconds: 500), () {
=======
    on<RemoveAccount>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false));

      await Account.deleteAccount(event.accountId);

      await Future.delayed(const Duration(seconds: 1), () {
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: false));
      });
    });

<<<<<<< HEAD
    on<CheckAuth>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');
      String? instance = prefs.getString('instance');
      String? defaultInstance = prefs.getString('setting_instance_default_instance');

      if (jwt == null && defaultInstance != null) {
        LemmyClient lemmyClient = LemmyClient.instance;
        lemmyClient.changeBaseUrl(defaultInstance);
        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: false));
      }

      if (instance != null) {
        LemmyClient lemmyClient = LemmyClient.instance;
        lemmyClient.changeBaseUrl(instance);
      }

      if (jwt == null) {
        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: false));
      } else {
        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: true));
      }
    });

=======
    on<SwitchAccount>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false));

      Account? account = await Account.fetchAccount(event.accountId);
      if (account == null) return emit(state.copyWith(status: AuthStatus.success, account: null, isLoggedIn: false));

      // Set this account as the active account
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('active_profile_id', event.accountId);

      await Future.delayed(const Duration(seconds: 1), () {
        return emit(state.copyWith(status: AuthStatus.success, account: account, isLoggedIn: true));
      });
    });

    // This event should be triggered during the start of the app, or when there is a change in the active account
    on<CheckAuth>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, account: null, isLoggedIn: false));

      // Check to see what the current active account/profile is
      // The profile will match an account in the database (through the account's id)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? activeProfileId = prefs.getString('active_profile_id');

      // If there is an existing jwt, remove it from the prefs
      String? jwt = prefs.getString('jwt');

      if (jwt != null) {
        prefs.remove('jwt');
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: 'You have been logged out. Please log in again!'));
      }

      if (activeProfileId == null) {
        return emit(state.copyWith(status: AuthStatus.success, account: null, isLoggedIn: false));
      }

      List<Account> accounts = await Account.accounts();

      if (accounts.isEmpty) {
        return emit(state.copyWith(status: AuthStatus.success, account: null, isLoggedIn: false));
      }

      Account? activeAccount = accounts.firstWhereOrNull((Account account) => account.id == activeProfileId);

      if (activeAccount == null) {
        return emit(state.copyWith(status: AuthStatus.success, account: null, isLoggedIn: false));
      }

      if (activeAccount.username != null && activeAccount.jwt != null && activeAccount.instance != null) {
        // Set lemmy client to use the instance
        LemmyClient.instance.changeBaseUrl(activeAccount.instance!);
        return emit(state.copyWith(status: AuthStatus.success, account: activeAccount, isLoggedIn: true));
      }
    });

    // This event should be triggered when the user logs in with a username/password
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    on<LoginAttempt>((event, emit) async {
      LemmyClient lemmyClient = LemmyClient.instance;
      String originalBaseUrl = lemmyClient.lemmy.baseUrl;

      try {
<<<<<<< HEAD
        emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false));

        String instance = event.instance;

        if (!instance.contains('https://')) {
          instance = 'https://$instance';
        }
=======
        emit(state.copyWith(status: AuthStatus.loading, account: null, isLoggedIn: false));

        String instance = event.instance;
        if (!instance.startsWith('https://')) instance = 'https://$instance';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

        lemmyClient.changeBaseUrl(instance);

        Lemmy lemmy = lemmyClient.lemmy;

        LoginResponse loginResponse = await lemmy.login(
          Login(
            usernameOrEmail: event.username,
            password: event.password,
          ),
        );

        if (loginResponse.jwt == null) {
<<<<<<< HEAD
          return emit(state.copyWith(status: AuthStatus.failure, isLoggedIn: false));
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', loginResponse.jwt!);
        await prefs.setString('instance', instance);
        await prefs.setString('username', event.username);

        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: true));
      } on DioException catch (e, s) {
        // Change the instance back to the previous one
        lemmyClient.changeBaseUrl(originalBaseUrl);

        String? errorMessage;

        if (e.response?.data != null) {
=======
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false));
        }

        // Create a new account in the database
        Uuid uuid = const Uuid();
        String accountId = uuid.v4().replaceAll('-', '').substring(0, 13);

        Account account = Account(
          id: accountId,
          username: event.username,
          jwt: loginResponse.jwt,
          instance: instance,
        );

        await Account.insertAccount(account);

        // Set this account as the active account
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('active_profile_id', accountId);

        return emit(state.copyWith(status: AuthStatus.success, account: account, isLoggedIn: true));
      } on DioException catch (e, s) {
        // Change the instance back to the previous one
        try {
          lemmyClient.changeBaseUrl(originalBaseUrl);
        } catch (e, s) {
          await Sentry.captureException(e, stackTrace: s);
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: s.toString()));
        }

        String? errorMessage;

        if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
          Map<String, dynamic> data = e.response?.data as Map<String, dynamic>;

          errorMessage = data.containsKey('error') ? data['error'] : e.message;
          errorMessage = errorMessage?.replaceAll('_', ' ');
        } else if (e.response?.statusCode != null) {
          errorMessage = e.message;
        } else {
          errorMessage = e.error.toString();
        }

        await Sentry.captureException(e, stackTrace: s);
<<<<<<< HEAD
        return emit(state.copyWith(status: AuthStatus.failure, isLoggedIn: false, errorMessage: errorMessage.toString()));
      } catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);
        return emit(state.copyWith(status: AuthStatus.failure, isLoggedIn: false, errorMessage: e.toString()));
=======
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: errorMessage.toString()));
      } catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString()));
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      }
    });
  }
}
