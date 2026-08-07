import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/data/auth_repository.dart';
import 'package:qaari_sl_mobile/core/models/user.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';

enum AuthStatus { unknown, guest, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final User? user;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(ref.watch(authRepositoryProvider));
  ref.listen<int>(sessionInvalidatedProvider, (previous, next) {
    if (previous != null && previous != next) {
      controller.handleUnauthorized();
    }
  });
  return controller;
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState()) {
    restoreSession();
  }

  final AuthRepository _repo;

  Future<void> restoreSession() async {
    try {
      final token = await _repo.readToken();
      if (token == null || token.isEmpty) {
        state = const AuthState(status: AuthStatus.guest);
        return;
      }
      final user = await _repo.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _repo.clearLocalSession();
      state = const AuthState(status: AuthStatus.guest);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final session = await _repo.login(email: email, password: password);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.guest,
        clearUser: true,
        error: _friendly(error),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final session = await _repo.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.guest,
        clearUser: true,
        error: _friendly(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.guest);
  }

  Future<bool> deleteAccount({required String password}) async {
    state = state.copyWith(clearError: true);
    try {
      await _repo.deleteAccount(password: password);
      state = const AuthState(status: AuthStatus.guest);
      return true;
    } catch (error) {
      state = state.copyWith(error: _friendlyDelete(error));
      return false;
    }
  }

  void handleUnauthorized() {
    state = const AuthState(status: AuthStatus.guest);
  }

  String _friendly(Object error) {
    return 'Could not sign in. Check your email and password.';
  }

  String _friendlyDelete(Object error) {
    return 'Could not delete account. Check your password and try again.';
  }
}
