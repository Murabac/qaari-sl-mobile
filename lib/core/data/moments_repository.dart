import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/models/moment.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';

final momentsRepositoryProvider = Provider<MomentsRepository>((ref) {
  return MomentsRepository(ref.watch(dioProvider));
});

class MomentsRepository {
  MomentsRepository(this._dio);

  final Dio _dio;

  Future<List<Moment>> fetchFeed({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/moments',
      queryParameters: {
        'page': page,
        'per_page': 20,
      },
    );

    final data = response.data?['data'];
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Moment.fromJson)
        .toList();
  }

  Future<Moment> like(int id) async {
    final response = await _dio.post<Map<String, dynamic>>('/moments/$id/like');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Like failed');
    }
    return Moment.fromJson(data);
  }

  Future<Moment> unlike(int id) async {
    final response =
        await _dio.delete<Map<String, dynamic>>('/moments/$id/like');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unlike failed');
    }
    return Moment.fromJson(data);
  }
}

final momentsFeedProvider =
    FutureProvider.autoDispose<List<Moment>>((ref) async {
  return ref.watch(momentsRepositoryProvider).fetchFeed();
});
