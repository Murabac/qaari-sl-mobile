import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/features/player/audio_handler.dart';

final audioHandlerProvider = Provider<QaariAudioHandler>((ref) {
  throw UnimplementedError('Audio handler must be overridden in main()');
});

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerViewState>((ref) {
  return PlayerController(
    handler: ref.watch(audioHandlerProvider),
    catalog: ref.watch(catalogRepositoryProvider),
  );
});

class PlayerViewState {
  const PlayerViewState({
    this.current,
    this.queue = const [],
    this.queueIndex = -1,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
  });

  final Recitation? current;
  final List<Recitation> queue;
  final int queueIndex;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? error;

  bool get hasTrack => current != null;
  bool get hasPrevious => queueIndex > 0;
  bool get hasNext => queueIndex >= 0 && queueIndex < queue.length - 1;

  PlayerViewState copyWith({
    Recitation? current,
    List<Recitation>? queue,
    int? queueIndex,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? error,
    bool clearError = false,
  }) {
    return PlayerViewState(
      current: current ?? this.current,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PlayerController extends StateNotifier<PlayerViewState> {
  PlayerController({
    required QaariAudioHandler handler,
    required CatalogRepository catalog,
  })  : _handler = handler,
        _catalog = catalog,
        super(const PlayerViewState()) {
    _subs.add(
      _handler.playerStateStream.listen((playerState) {
        state = state.copyWith(
          isPlaying: playerState.playing,
          current: _handler.current ?? state.current,
        );
      }),
    );
    _subs.add(
      _handler.positionStream.listen((position) {
        state = state.copyWith(position: position);
      }),
    );
    _subs.add(
      _handler.durationStream.listen((duration) {
        if (duration != null) {
          state = state.copyWith(duration: duration);
        }
      }),
    );
    _subs.add(
      _handler.processingStateStream.listen((processingState) {
        if (processingState == ProcessingState.completed) {
          unawaited(playNext(auto: true));
        }
      }),
    );
  }

  final QaariAudioHandler _handler;
  final CatalogRepository _catalog;
  final List<StreamSubscription<dynamic>> _subs = [];

  Future<void> playRecitation(
    Recitation track, {
    List<Recitation>? queue,
  }) async {
    final resolvedQueue = (queue == null || queue.isEmpty)
        ? <Recitation>[track]
        : List<Recitation>.from(queue);
    final index = resolvedQueue.indexWhere((item) => item.id == track.id);

    try {
      if (state.current?.id == track.id && state.isPlaying && queue == null) {
        await pause();
        return;
      }
      state = state.copyWith(
        current: track,
        queue: resolvedQueue,
        queueIndex: index >= 0 ? index : 0,
        isPlaying: true,
        duration: Duration(seconds: track.duration),
        clearError: true,
      );
      await _handler.playRecitation(track);
      state = state.copyWith(
        current: track,
        isPlaying: true,
        duration: Duration(seconds: track.duration),
        clearError: true,
      );
    } catch (error) {
      final recovered = await _retryWithFreshUrl(track);
      if (!recovered) {
        state = state.copyWith(error: _friendlyError(error));
      }
    }
  }

  Future<void> playPrevious() async {
    if (!state.hasPrevious) return;
    final previous = state.queue[state.queueIndex - 1];
    await playRecitation(previous, queue: state.queue);
  }

  Future<void> playNext({bool auto = false}) async {
    if (!state.hasNext) {
      if (auto) {
        await _handler.seek(Duration.zero);
        await pause();
      }
      return;
    }
    final next = state.queue[state.queueIndex + 1];
    await playRecitation(next, queue: state.queue);
  }

  Future<bool> _retryWithFreshUrl(Recitation track) async {
    try {
      final fresh = await _catalog.fetchRecitation(track.id);
      final merged = fresh.copyWith(
        reciterName: track.reciterName ?? fresh.reciterName,
        reciterPhotoUrl: track.reciterPhotoUrl ?? fresh.reciterPhotoUrl,
        surah: track.surah ?? fresh.surah,
      );
      await _handler.playRecitation(merged);
      state = state.copyWith(
        current: merged,
        isPlaying: true,
        duration: Duration(seconds: merged.duration),
        clearError: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggle() async {
    if (!state.hasTrack) return;
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    await _handler.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    try {
      await _handler.play();
      state = state.copyWith(isPlaying: true, clearError: true);
    } catch (error) {
      final track = state.current;
      if (track == null) {
        state = state.copyWith(error: _friendlyError(error));
        return;
      }
      final recovered = await _retryWithFreshUrl(track);
      if (!recovered) {
        state = state.copyWith(error: _friendlyError(error));
      }
    }
  }

  Future<void> seek(Duration position) async {
    await _handler.seek(position);
    state = state.copyWith(position: position);
  }

  Future<void> stop() async {
    await _handler.stop();
    state = const PlayerViewState();
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      return 'Could not stream audio. Check your connection and API URL.';
    }
    return 'Playback failed. The audio link may have expired — try again.';
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      unawaited(sub.cancel());
    }
    super.dispose();
  }
}
