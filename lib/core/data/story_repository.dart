import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/models/story.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository(ref.watch(dioProvider));
});

class StoryRepository {
  StoryRepository(this._dio);

  final Dio _dio;

  Future<StoryPayload> fetchStory() async {
    final response = await _dio.get<Map<String, dynamic>>('/story');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid /story response');
    }
    return StoryPayload.fromJson(data);
  }
}

final storyProvider = FutureProvider.autoDispose<StoryPayload>((ref) async {
  return ref.watch(storyRepositoryProvider).fetchStory();
});
