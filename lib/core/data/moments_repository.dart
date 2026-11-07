import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/models/moment.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';

final momentsRepositoryProvider = Provider<MomentsRepository>((ref) {
  return MomentsRepository(ref.watch(dioProvider));
});

class MomentsPage {
  const MomentsPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<Moment> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

class MomentsRepository {
  MomentsRepository(this._dio);

  final Dio _dio;

  Future<MomentsPage> fetchPage({
    int page = 1,
    String filter = 'latest',
    String? query,
    String? tag,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/moments',
      queryParameters: {
        'page': page,
        'per_page': 20,
        'filter': filter,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (tag != null && tag.trim().isNotEmpty) 'tag': tag.trim(),
      },
    );

    final body = response.data;
    final data = body?['data'];
    final meta = body?['meta'];
    final items = data is List
        ? data.whereType<Map<String, dynamic>>().map(Moment.fromJson).toList()
        : const <Moment>[];
    final current = meta is Map
        ? (meta['current_page'] as num?)?.toInt() ?? page
        : page;
    final last = meta is Map ? (meta['last_page'] as num?)?.toInt() ?? page : page;
    return MomentsPage(items: items, currentPage: current, lastPage: last);
  }

  Future<List<Moment>> fetchFeed({int page = 1}) async {
    final result = await fetchPage(page: page);
    return result.items;
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

  Future<Moment> save(int id) => _mutate('/moments/$id/save', post: true);

  Future<Moment> unsave(int id) => _mutate('/moments/$id/save', post: false);

  Future<Reciter> followReciter(int id) async {
    final response = await _dio.post<Map<String, dynamic>>('/reciters/$id/follow');
    return _reciter(response.data);
  }

  Future<Reciter> unfollowReciter(int id) async {
    final response =
        await _dio.delete<Map<String, dynamic>>('/reciters/$id/follow');
    return _reciter(response.data);
  }

  Future<List<MomentComment>> comments(int id) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/moments/$id/comments');
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(MomentComment.fromJson).toList();
  }

  Future<MomentComment> addComment(int id, String body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/moments/$id/comments',
      data: {'body': body},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Comment failed');
    }
    return MomentComment.fromJson(data);
  }

  Future<void> deleteComment(int momentId, int commentId) async {
    await _dio.delete<void>('/moments/$momentId/comments/$commentId');
  }

  Future<Moment> _mutate(String path, {required bool post}) async {
    final response = post
        ? await _dio.post<Map<String, dynamic>>(path)
        : await _dio.delete<Map<String, dynamic>>(path);
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Update failed');
    }
    return Moment.fromJson(data);
  }

  Reciter _reciter(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Follow failed');
    }
    return Reciter.fromJson(data);
  }
}

final momentsFeedProvider =
    FutureProvider.autoDispose<List<Moment>>((ref) async {
  return ref.watch(momentsRepositoryProvider).fetchFeed();
});
