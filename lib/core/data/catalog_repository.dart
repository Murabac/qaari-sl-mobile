import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(dioProvider));
});

class CatalogRepository {
  CatalogRepository(this._dio);

  final Dio _dio;

  Future<List<Reciter>> fetchReciters({String? query}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reciters',
      queryParameters: {
        'per_page': 50,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );

    final data = response.data?['data'];
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Reciter.fromJson)
        .toList();
  }

  Future<Reciter> fetchReciter(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/reciters/$id');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Reciter $id not found');
    }
    return Reciter.fromJson(data);
  }

  Future<Reciter> followReciter(int id) async {
    final response = await _dio.post<Map<String, dynamic>>('/reciters/$id/follow');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Follow failed');
    }
    return Reciter.fromJson(data);
  }

  Future<Reciter> unfollowReciter(int id) async {
    final response =
        await _dio.delete<Map<String, dynamic>>('/reciters/$id/follow');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unfollow failed');
    }
    return Reciter.fromJson(data);
  }

  Future<Recitation> fetchRecitation(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/recitations/$id');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Recitation $id not found');
    }
    return Recitation.fromJson(data);
  }
}

final recitersProvider = FutureProvider.autoDispose
    .family<List<Reciter>, String>((ref, query) async {
  return ref.watch(catalogRepositoryProvider).fetchReciters(query: query);
});

final reciterDetailProvider =
    FutureProvider.autoDispose.family<Reciter, int>((ref, id) async {
  return ref.watch(catalogRepositoryProvider).fetchReciter(id);
});
