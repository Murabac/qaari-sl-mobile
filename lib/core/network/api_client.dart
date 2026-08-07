import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/token_store.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';

/// Bumped when a 401 clears the stored token so [AuthController] can drop UI session.
final sessionInvalidatedProvider = StateProvider<int>((ref) => 0);

final dioProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return createApiClient(
    tokenStore: store,
    onUnauthorized: () {
      ref.read(sessionInvalidatedProvider.notifier).state++;
    },
  );
});

Dio createApiClient({
  String? baseUrl,
  TokenStore? tokenStore,
  void Function()? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${baseUrl ?? AppConstants.apiBaseUrl}${AppConstants.apiPrefix}',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStore?.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await tokenStore?.clear();
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}
