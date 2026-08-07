import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/features/player/now_playing_screen.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';

/// Opens Now Playing immediately while audio starts in the background.
void openPlayerAndPlay(
  BuildContext context,
  WidgetRef ref,
  Recitation track,
) {
  // Start play first so `current` is set before the route builds.
  final playing =
      ref.read(playerControllerProvider.notifier).playRecitation(track);
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const NowPlayingScreen()),
  );
  unawaited(playing);
}
