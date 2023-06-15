import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy/lemmy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<ClearAuth>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false));

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.remove('jwt');
      prefs.remove('instance');
      prefs.remove('username');

      await Future.delayed(const Duration(milliseconds: 500), () {
        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: false));
      });
    });

    on<CheckAuth>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');
      String? instance = prefs.getString('instance');

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

    on<LoginAttempt>((event, emit) async {
      try {
        emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false));

        String instance = event.instance;

        if (!instance.contains('https://')) {
          instance = 'https://$instance';
        }

        LemmyClient lemmyClient = LemmyClient.instance;
        lemmyClient.changeBaseUrl(instance);

        Lemmy lemmy = lemmyClient.lemmy;

        LoginResponse loginResponse = await lemmy.login(
          Login(
            usernameOrEmail: event.username,
            password: event.password,
          ),
        );

        if (loginResponse.jwt == null) {
          return emit(state.copyWith(status: AuthStatus.failure, isLoggedIn: false));
        }

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', loginResponse.jwt!);
        await prefs.setString('instance', instance);
        await prefs.setString('username', event.username);

        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: true));
      } on DioException catch (e) {
        dynamic errorMessage;

        if (e.response?.data != null) {
          errorMessage = e.response?.data?['error'];
          errorMessage = errorMessage?.replaceAll('_', ' ');
        } else if (e.response?.statusCode != null) {
          errorMessage = e.message;
        } else {
          errorMessage = e.error.toString();
        }

        return emit(state.copyWith(status: AuthStatus.failure, isLoggedIn: false, errorMessage: errorMessage.toString()));
      } catch (e) {
        return emit(state.copyWith(status: AuthStatus.failure, isLoggedIn: false, errorMessage: e.toString()));
      }
    });
  }
}
