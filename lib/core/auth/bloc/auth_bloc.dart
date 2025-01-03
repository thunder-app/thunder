import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:collection/collection.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

part 'auth_event.dart';
part 'auth_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<RemoveAccount>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false));

      await Account.deleteAccount(event.accountId);

      await Future.delayed(const Duration(seconds: 1), () {
        return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: false));
      });
    });

    /// This event occurs whenever you switch to a different authenticated account
    on<SwitchAccount>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: false, reload: event.reload));

      Account? account = await Account.fetchAccount(event.accountId);
      if (account == null) return emit(state.copyWith(status: AuthStatus.success, account: null, isLoggedIn: false));

      // Set this account as the active account
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      prefs.setString('active_profile_id', event.accountId);

      // Check to see the instance settings (for checking if downvotes are enabled)
      LemmyClient.instance.changeBaseUrl(account.instance.replaceAll('https://', ''));
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: account.jwt));
      bool downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes ?? false;

      return emit(state.copyWith(
        status: AuthStatus.success,
        account: account,
        isLoggedIn: true,
        downvotesEnabled: downvotesEnabled,
        getSiteResponse: getSiteResponse,
        reload: event.reload,
      ));
    });

    // This event should be triggered during the start of the app, or when there is a change in the active account
    on<CheckAuth>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, account: null, isLoggedIn: false));

      // Check to see what the current active account/profile is
      // The profile will match an account in the database (through the account's id)
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
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

      if (activeAccount.username != null && activeAccount.jwt != null) {
        // Set lemmy client to use the instance
        LemmyClient.instance.changeBaseUrl(activeAccount.instance.replaceAll('https://', ''));

        // Check to see the instance settings (for checking if downvotes are enabled)
        LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

        bool downvotesEnabled = true;
        GetSiteResponse? getSiteResponse;
        try {
          getSiteResponse = await lemmy.run(GetSite(auth: activeAccount.jwt)).timeout(const Duration(seconds: 15));

          downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes ?? false;
        } catch (e) {
          return emit(state.copyWith(status: AuthStatus.failureCheckingInstance, errorMessage: getExceptionErrorMessage(e)));
        }

        return emit(state.copyWith(status: AuthStatus.success, account: activeAccount, isLoggedIn: true, downvotesEnabled: downvotesEnabled, getSiteResponse: getSiteResponse));
      }
    }, transformer: throttleDroppable(throttleDuration));

    /// This event should be triggered when the user logs in with a username/password
    on<LoginAttempt>((event, emit) async {
      LemmyClient lemmyClient = LemmyClient.instance;
      String originalBaseUrl = lemmyClient.lemmyApiV3.host;

      try {
        emit(state.copyWith(status: AuthStatus.loading, account: null, isLoggedIn: false));

        String instance = event.instance;
        if (instance.startsWith('https://')) instance = instance.replaceAll('https://', '');

        lemmyClient.changeBaseUrl(instance);
        LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

        LoginResponse loginResponse = await lemmy.run(Login(
          usernameOrEmail: event.username,
          password: event.password,
          totp2faToken: event.totp,
        ));

        if (loginResponse.jwt == null) {
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false));
        }

        GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: loginResponse.jwt));

        if (event.showContentWarning && getSiteResponse.siteView.site.contentWarning?.isNotEmpty == true) {
          return emit(state.copyWith(status: AuthStatus.contentWarning, contentWarning: getSiteResponse.siteView.site.contentWarning));
        }

        // Create a new account in the database
        Account? account = Account(
          id: '',
          username: getSiteResponse.myUser?.localUserView.person.name,
          jwt: loginResponse.jwt,
          instance: instance,
          userId: getSiteResponse.myUser?.localUserView.person.id,
          index: -1,
        );

        account = await Account.insertAccount(account);

        if (account == null) {
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false));
        }

        // Set this account as the active account
        SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
        prefs.setString('active_profile_id', account.id);

        bool downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes ?? false;

        return emit(state.copyWith(status: AuthStatus.success, account: account, isLoggedIn: true, downvotesEnabled: downvotesEnabled, getSiteResponse: getSiteResponse));
      } on LemmyApiException catch (e) {
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString()));
      } catch (e) {
        try {
          // Restore the original baseUrl
          lemmyClient.changeBaseUrl(originalBaseUrl);
        } catch (e, s) {
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: s.toString()));
        }
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString()));
      }
    });

    /// This event should be triggered when the user logs in with oauth.
    on<OAuthLoginAttemptPart1>((event, emit) async {
      LemmyClient lemmyClient = LemmyClient.instance;
      String originalBaseUrl = lemmyClient.lemmyApiV3.host;

      try {
        emit(state.copyWith(status: AuthStatus.loading, account: null, isLoggedIn: false));

        String instance = event.instance;
        if (instance.startsWith('https://')) instance = instance.replaceAll('https://', '');

        lemmyClient.changeBaseUrl(instance);
        LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

        ProviderView provider = event.provider;
        debugPrint(provider.toString());
        var authorizationEndpoint = Uri.parse(provider.authorizationEndpoint);
        var providerId = provider.id;

        // Build oauth provider url.
        String redirectUri = "https://thunderapp.dev/oauth/callback"; // This must end in /oauth/callback.
        String oauthState = const Uuid().v4();
        final url = Uri.https(authorizationEndpoint.host, authorizationEndpoint.path, {
          'response_type': 'code',
          'client_id': provider.clientId,
          'redirect_uri': redirectUri,
          'scope': provider.scopes,
          'state': oauthState,
        });

        debugPrint("URL $url");

        // Present the login dialog to the user.
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }

        return emit(state.copyWith(oauthState: oauthState, oauthInstance: instance, oauthProviderId: provider.id));
      } on LemmyApiException catch (e) {
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString(), oauthState: null, oauthInstance: null, oauthProviderId: null));
      } catch (e) {
        try {
          // Restore the original baseUrl
          lemmyClient.changeBaseUrl(originalBaseUrl);
        } catch (e, s) {
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: s.toString(), oauthState: null, oauthInstance: null, oauthProviderId: null));
        }
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString(), oauthState: null, oauthInstance: null, oauthProviderId: null));
      }
    });

    on<OAuthLoginAttemptPart2>((event, emit) async {
      LemmyClient lemmyClient = LemmyClient.instance;
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
      String originalBaseUrl = lemmyClient.lemmyApiV3.host;

      try {
        debugPrint("PART2 ${event.link}");

        LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
        String redirectUri = "https://thunderapp.dev/oauth/callback";
        String providerResponse = event.link;

        if (state.oauthState == null) {
          throw Exception("OAuth login failed: oauthState is null.");
        }

        if (state.oauthInstance == null) {
          throw Exception("OAuth login failed: oauthInstance is null.");
        }

        if (state.oauthProviderId == null) {
          throw Exception("OAuth login failed: oauthProviderId is null.");
        }

        debugPrint("RESULT $providerResponse");

        // oauthProviderState must match oauthClientState to ensure the response came from the Provider.
        String oauthProviderState = Uri.parse(providerResponse).queryParameters['state'] ?? "failed";
        if (oauthProviderState == "failed" || state.oauthState != oauthProviderState) {
          throw Exception("OAuth state-check failed: oauthProviderState ${state.oauthState} must match oauthClientState ${state.oauthState} to ensure the response came from the Provider.");
        }

        // Extract the code from the response.
        String code = Uri.parse(providerResponse).queryParameters['code'] ?? "failed";
        debugPrint("CODE $code");

        if (code == "failed") {
          throw Exception("OAuth login failed: no code received from provider.");
        }

        // TODO: dynamic provider_id.
        // Authenthicate to lemmy and get a jwt.
        // Durring this step lemmy connects to the Provider to get the user info.
        LoginResponse loginResponse = await lemmy.run(AuthenticateWithOAuth(code: code, oauth_provider_id: state.oauthProviderId ?? -1, redirect_uri: redirectUri));

        // TODO: Need to add a step to set the account username.

        final accessToken = loginResponse.jwt as String;

        debugPrint("JWT $accessToken");

        GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: accessToken));

        // TODO: Login fails when this is uncommented. Have to get this working.
        //if (event.showContentWarning && getSiteResponse.siteView.site.contentWarning?.isNotEmpty == true) {
        //  return emit(state.copyWith(status: AuthStatus.contentWarning, contentWarning: getSiteResponse.siteView.site.contentWarning));
        //}

        // Create a new account in the database
        Account? account = Account(
          id: '',
          username: getSiteResponse.myUser?.localUserView.person.name,
          jwt: accessToken,
          instance: state.oauthInstance ?? "",
          userId: getSiteResponse.myUser?.localUserView.person.id,
          index: -1,
        );

        account = await Account.insertAccount(account);

        if (account == null) {
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false));
        }

        // Set this account as the active account
        SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
        prefs.setString('active_profile_id', account.id);

        bool downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes ?? false;

        return emit(state.copyWith(
            status: AuthStatus.success,
            account: account,
            isLoggedIn: true,
            downvotesEnabled: downvotesEnabled,
            getSiteResponse: getSiteResponse,
            oauthState: null,
            oauthInstance: null,
            oauthProviderId: null));
      } on LemmyApiException catch (e) {
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString(), oauthState: null, oauthInstance: null, oauthProviderId: null));
      } catch (e) {
        try {
          // Restore the original baseUrl
          lemmyClient.changeBaseUrl(originalBaseUrl);
        } catch (e, s) {
          return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: s.toString(), oauthState: null, oauthInstance: null, oauthProviderId: null));
        }
        return emit(state.copyWith(status: AuthStatus.failure, account: null, isLoggedIn: false, errorMessage: e.toString(), oauthState: null, oauthInstance: null, oauthProviderId: null));
      }
    });

    on<CancelLoginAttempt>((event, emit) async {
      return emit(state.copyWith(status: AuthStatus.failure, errorMessage: AppLocalizations.of(GlobalContext.context)!.loginAttemptCanceled));
    });

    /// When we log out of all accounts, clear the instance information
    on<LogOutOfAllAccounts>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.initial));
      final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      prefs.setString('active_profile_id', '');
      return emit(state.copyWith(status: AuthStatus.success, isLoggedIn: false, getSiteResponse: null));
    });

    /// When the given instance changes, re-fetch the instance information and preferences.
    on<InstanceChanged>((event, emit) async {
      // Copy everything from the state as is during loading
      emit(state.copyWith(status: AuthStatus.loading, isLoggedIn: state.isLoggedIn, account: state.account));

      // When the instance changes, update the fullSiteView
      LemmyClient.instance.changeBaseUrl(event.instance.replaceAll('https://', ''));
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      // Check to see if there is an active, non-anonymous account
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      String? activeProfileId = prefs.getString('active_profile_id');
      Account? account = (activeProfileId != null) ? await Account.fetchAccount(activeProfileId) : null;

      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: account?.jwt));
      bool downvotesEnabled = getSiteResponse.siteView.localSite.enableDownvotes ?? false;

      return emit(state.copyWith(status: AuthStatus.success, account: account, isLoggedIn: activeProfileId?.isNotEmpty == true, downvotesEnabled: downvotesEnabled, getSiteResponse: getSiteResponse));
    });

    /// When any account setting synced with Lemmy is updated, re-fetch the instance information and preferences.
    on<LemmyAccountSettingUpdated>((event, emit) async {
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      // Check to see if there is an active, non-anonymous account
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      String? activeProfileId = prefs.getString('active_profile_id');
      Account? account = (activeProfileId != null) ? await Account.fetchAccount(activeProfileId) : null;

      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: account?.jwt));
      return emit(state.copyWith(
        status: AuthStatus.success,
        account: account,
        isLoggedIn: activeProfileId?.isNotEmpty == true,
        getSiteResponse: getSiteResponse,
        reload: false,
      ));
    });
  }
}
