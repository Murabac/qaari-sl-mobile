import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/token_store.dart';
import 'package:qaari_sl_mobile/core/models/user.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

class AuthRepository {
  AuthRepository({
    required Dio dio,
    required TokenStore tokenStore,
  })  : _dio = dio,
        _tokenStore = tokenStore;

  final Dio _dio;
  final TokenStore _tokenStore;

  Future<String?> readToken() => _tokenStore.read();

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email.trim(),
        'password': password,
        'device_name': 'qaari-sl-mobile',
      },
    );
    return _persistSession(response.data);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': 'qaari-sl-mobile',
      },
    );
    return _persistSession(response.data);
  }

  Future<User> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid /auth/me response');
    }
    return User.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await _dio.post<Map<String, dynamic>>('/auth/logout');
    } on DioException {
      // Still clear local session if the token was already revoked.
    } finally {
      await _tokenStore.clear();
    }
  }

  Future<void> clearLocalSession() => _tokenStore.clear();

  Future<AuthSession> _persistSession(Map<String, dynamic>? body) async {
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid auth response');
    }
    final token = data['token'] as String?;
    final userJson = data['user'];
    if (token == null || token.isEmpty || userJson is! Map<String, dynamic>) {
      throw StateError('Auth response missing token or user');
    }
    await _tokenStore.write(token);
    return AuthSession(token: token, user: User.fromJson(userJson));
  }
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}
