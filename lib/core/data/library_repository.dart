import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/models/follow_along.dart';
import 'package:qaari_sl_mobile/core/models/playlist.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/network/api_client.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(ref.watch(dioProvider));
});

class LibraryRepository {
  LibraryRepository(this._dio);

  final Dio _dio;

  Future<List<Recitation>> fetchFavorites() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/favorites',
      queryParameters: {'per_page': 100},
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Recitation.fromJson)
        .toList();
  }

  Future<void> addFavorite(int recitationId) async {
    await _dio.post<Map<String, dynamic>>(
      '/favorites',
      data: {'recitation_id': recitationId},
    );
  }

  Future<void> removeFavorite(int recitationId) async {
    await _dio.delete<Map<String, dynamic>>('/favorites/$recitationId');
  }

  Future<List<Playlist>> fetchPlaylists() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/playlists',
      queryParameters: {'per_page': 50},
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Playlist.fromJson)
        .toList();
  }

  Future<Playlist> fetchPlaylist(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/playlists/$id');
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Playlist $id not found');
    }
    return Playlist.fromJson(data);
  }

  Future<Playlist> createPlaylist(String name) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/playlists',
      data: {'name': name.trim()},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Could not create playlist');
    }
    return Playlist.fromJson(data);
  }

  Future<Playlist> renamePlaylist(int id, String name) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/playlists/$id',
      data: {'name': name.trim()},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Could not rename playlist');
    }
    return Playlist.fromJson(data);
  }

  Future<void> deletePlaylist(int id) async {
    await _dio.delete<Map<String, dynamic>>('/playlists/$id');
  }

  Future<void> addPlaylistItem({
    required int playlistId,
    required int recitationId,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/playlists/$playlistId/items',
      data: {'recitation_id': recitationId},
    );
  }

  Future<void> removePlaylistItem({
    required int playlistId,
    required int itemId,
  }) async {
    await _dio.delete<Map<String, dynamic>>(
      '/playlists/$playlistId/items/$itemId',
    );
  }

  Future<FollowAlongPayload> fetchFollowAlong(int recitationId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/recitations/$recitationId/follow-along',
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Follow-along payload missing');
    }
    return FollowAlongPayload.fromJson(data);
  }
}

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, FavoritesState>((ref) {
  final controller = FavoritesController(ref.watch(libraryRepositoryProvider));
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (next.isAuthenticated) {
      controller.refresh();
    } else if (next.isGuest) {
      controller.clear();
    }
  }, fireImmediately: true);
  return controller;
});

class FavoritesState {
  const FavoritesState({
    this.ids = const {},
    this.tracks = const [],
    this.isLoading = false,
    this.error,
  });

  final Set<int> ids;
  final List<Recitation> tracks;
  final bool isLoading;
  final String? error;

  bool contains(int id) => ids.contains(id);

  FavoritesState copyWith({
    Set<int>? ids,
    List<Recitation>? tracks,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      ids: ids ?? this.ids,
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FavoritesController extends StateNotifier<FavoritesState> {
  FavoritesController(this._repo) : super(const FavoritesState());

  final LibraryRepository _repo;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tracks = await _repo.fetchFavorites();
      state = FavoritesState(
        ids: tracks.map((t) => t.id).toSet(),
        tracks: tracks,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load favorites',
      );
    }
  }

  void clear() {
    state = const FavoritesState();
  }

  Future<bool> toggle(int recitationId) async {
    final wasFavorite = state.contains(recitationId);
    final nextIds = Set<int>.from(state.ids);
    if (wasFavorite) {
      nextIds.remove(recitationId);
    } else {
      nextIds.add(recitationId);
    }
    state = state.copyWith(
      ids: nextIds,
      tracks: wasFavorite
          ? state.tracks.where((t) => t.id != recitationId).toList()
          : state.tracks,
      clearError: true,
    );

    try {
      if (wasFavorite) {
        await _repo.removeFavorite(recitationId);
      } else {
        await _repo.addFavorite(recitationId);
        await refresh();
      }
      return true;
    } catch (_) {
      // Revert optimistic update.
      await refresh();
      return false;
    }
  }
}

final playlistsProvider =
    FutureProvider.autoDispose<List<Playlist>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (!auth.isAuthenticated) return const [];
  return ref.watch(libraryRepositoryProvider).fetchPlaylists();
});

final playlistDetailProvider =
    FutureProvider.autoDispose.family<Playlist, int>((ref, id) async {
  return ref.watch(libraryRepositoryProvider).fetchPlaylist(id);
});

final followAlongProvider = FutureProvider.autoDispose
    .family<FollowAlongPayload, int>((ref, recitationId) async {
  return ref.watch(libraryRepositoryProvider).fetchFollowAlong(recitationId);
});
