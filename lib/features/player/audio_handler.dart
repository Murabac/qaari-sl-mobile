import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';

/// A finished track stays at the end until playback is rewound.
bool playbackNeedsRestart(ProcessingState state) =>
    state == ProcessingState.completed;

Future<QaariAudioHandler> initAudioService() {
  return AudioService.init(
    builder: QaariAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.xulkaquraada.mobile.audio',
      androidNotificationChannelName: 'Xulka Quraada Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class QaariAudioHandler extends BaseAudioHandler with SeekHandler {
  QaariAudioHandler() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformState());
    });
  }

  final AudioPlayer _player = AudioPlayer();
  Recitation? _current;

  Recitation? get current => _current;
  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  Future<void> playRecitation(Recitation track) async {
    final same = _current?.id == track.id && _player.audioSource != null;
    _current = track;

    mediaItem.add(
      MediaItem(
        id: '${track.id}',
        title: track.surah?.titleLine ?? 'Surah ${track.surahId}',
        artist: track.reciterName ?? AppConstants.appName,
        duration: Duration(seconds: track.duration),
        artUri: (track.reciterPhotoUrl ?? '').isNotEmpty
            ? Uri.tryParse(track.reciterPhotoUrl!)
            : null,
      ),
    );

    if (!same) {
      await _setSource(track.audioUrl);
    }

    await play();
  }

  Future<void> _setSource(String url) async {
    final isFile = url.startsWith('file:') ||
        (url.isNotEmpty && !url.contains('://') && (url.startsWith('/') || url.contains(r'\')));
    if (isFile) {
      final path = url.startsWith('file:') ? Uri.parse(url).toFilePath() : url;
      await _player.setFilePath(path);
    } else {
      await _player.setUrl(url);
    }
  }

  Future<void> replaceUrlAndResume(String url, {Duration? position}) async {
    final wasPlaying = _player.playing;
    await _setSource(url);
    if (position != null) {
      await _player.seek(position);
    }
    if (wasPlaying) {
      await play();
    }
  }

  @override
  Future<void> play() async {
    if (playbackNeedsRestart(_player.processingState)) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  PlaybackState _transformState() {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    );
  }
}
