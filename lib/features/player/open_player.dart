import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/features/player/now_playing_screen.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';

List<Recitation> readyRecitations(Reciter reciter) => reciter.recitations
    .where((track) => track.audioUrl.isNotEmpty)
    .toList();

/// Uses tracks already on [reciter], or loads the profile when the list is empty.
Future<List<Recitation>> resolveListenQueue(
  Reciter reciter,
  CatalogRepository catalog,
) async {
  final ready = readyRecitations(reciter);
  if (ready.isNotEmpty) return ready;
  return readyRecitations(await catalog.fetchReciter(reciter.id));
}

/// Opens Now Playing immediately while audio starts in the background.
void openPlayerAndPlay(
  BuildContext context,
  WidgetRef ref,
  Recitation track, {
  List<Recitation>? queue,
}) {
  final playing = ref.read(playerControllerProvider.notifier).playRecitation(
        track,
        queue: queue,
      );
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const NowPlayingScreen()),
  );
  unawaited(playing);
}
