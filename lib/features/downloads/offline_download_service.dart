import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final offlineDownloadServiceProvider = Provider<OfflineDownloadService>((ref) {
  return OfflineDownloadService(Dio());
});

final offlineDownloadsProvider =
    StateNotifierProvider<OfflineDownloadsController, List<OfflineTrack>>(
  (ref) => OfflineDownloadsController(ref.watch(offlineDownloadServiceProvider)),
);

class OfflineTrack {
  const OfflineTrack({
    required this.recitationId,
    required this.reciterId,
    required this.title,
    required this.reciterName,
    required this.localPath,
    required this.fileSize,
    required this.downloadedAtMs,
  });

  final int recitationId;
  final int reciterId;
  final String title;
  final String reciterName;
  final String localPath;
  final int fileSize;
  final int downloadedAtMs;

  Map<String, dynamic> toJson() => {
        'recitationId': recitationId,
        'reciterId': reciterId,
        'title': title,
        'reciterName': reciterName,
        'localPath': localPath,
        'fileSize': fileSize,
        'downloadedAtMs': downloadedAtMs,
      };

  factory OfflineTrack.fromJson(Map<String, dynamic> json) {
    return OfflineTrack(
      recitationId: (json['recitationId'] as num).toInt(),
      reciterId: (json['reciterId'] as num).toInt(),
      title: json['title'] as String? ?? 'Surah',
      reciterName: json['reciterName'] as String? ?? '',
      localPath: json['localPath'] as String? ?? '',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      downloadedAtMs: (json['downloadedAtMs'] as num?)?.toInt() ?? 0,
    );
  }

  bool get fileExists => localPath.isNotEmpty && File(localPath).existsSync();
}

class OfflineDownloadService {
  OfflineDownloadService(this._dio);

  static const _prefsKey = 'offline_downloads_v1';

  final Dio _dio;

  Future<Directory> _dir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'offline_audio'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<OfflineTrack>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    final tracks = decoded
        .whereType<Map<String, dynamic>>()
        .map(OfflineTrack.fromJson)
        .where((t) => t.fileExists)
        .toList();
    await _persist(tracks);
    return tracks;
  }

  Future<OfflineTrack?> find(int recitationId) async {
    final all = await list();
    for (final track in all) {
      if (track.recitationId == recitationId) return track;
    }
    return null;
  }

  Future<String?> localPathFor(int recitationId) async {
    final track = await find(recitationId);
    return track?.localPath;
  }

  Future<OfflineTrack> download(Recitation recitation) async {
    if (recitation.audioUrl.isEmpty) {
      throw StateError('No audio URL for this recitation.');
    }

    final existing = await find(recitation.id);
    if (existing != null) return existing;

    final dir = await _dir();
    final ext = _guessExt(recitation.audioUrl);
    final file = File(p.join(dir.path, 'recitation_${recitation.id}$ext'));

    await _dio.download(
      recitation.audioUrl,
      file.path,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (code) => code != null && code >= 200 && code < 400,
      ),
    );

    final track = OfflineTrack(
      recitationId: recitation.id,
      reciterId: recitation.reciterId,
      title: recitation.surah?.titleLine ?? 'Surah ${recitation.surahId}',
      reciterName: recitation.reciterName ?? '',
      localPath: file.path,
      fileSize: await file.length(),
      downloadedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    final all = await list();
    all.removeWhere((item) => item.recitationId == track.recitationId);
    all.insert(0, track);
    await _persist(all);
    return track;
  }

  Future<void> remove(int recitationId) async {
    final all = await list();
    OfflineTrack? removed;
    all.removeWhere((item) {
      if (item.recitationId == recitationId) {
        removed = item;
        return true;
      }
      return false;
    });
    if (removed != null && removed!.localPath.isNotEmpty) {
      final file = File(removed!.localPath);
      if (await file.exists()) await file.delete();
    }
    await _persist(all);
  }

  Future<void> clearAll() async {
    final all = await list();
    for (final track in all) {
      final file = File(track.localPath);
      if (await file.exists()) await file.delete();
    }
    await _persist([]);
  }

  Future<void> _persist(List<OfflineTrack> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(tracks.map((t) => t.toJson()).toList()),
    );
  }

  String _guessExt(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.wav')) return '.wav';
    if (path.endsWith('.m4a')) return '.m4a';
    if (path.endsWith('.ogg')) return '.ogg';
    return '.mp3';
  }
}

class OfflineDownloadsController extends StateNotifier<List<OfflineTrack>> {
  OfflineDownloadsController(this._service) : super(const []) {
    refresh();
  }

  final OfflineDownloadService _service;
  final Set<int> _busy = {};

  bool isBusy(int recitationId) => _busy.contains(recitationId);

  bool isDownloaded(int recitationId) =>
      state.any((t) => t.recitationId == recitationId);

  Future<void> refresh() async {
    state = await _service.list();
  }

  Future<void> download(Recitation recitation) async {
    if (_busy.contains(recitation.id)) return;
    _busy.add(recitation.id);
    try {
      await _service.download(recitation);
      await refresh();
    } finally {
      _busy.remove(recitation.id);
    }
  }

  Future<void> remove(int recitationId) async {
    await _service.remove(recitationId);
    await refresh();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    await refresh();
  }
}
