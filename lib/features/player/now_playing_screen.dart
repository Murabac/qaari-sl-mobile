import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';
import 'package:qaari_sl_mobile/features/follow_along/follow_along_screen.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/features/playlists/add_to_playlist_sheet.dart';
import 'package:qaari_sl_mobile/core/share/share_recitation.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerControllerProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final track = player.current;

    if (player.isPlaying) {
      if (!_spin.isAnimating) _spin.repeat();
    } else {
      _spin.stop();
    }

    if (track == null) {
      return Scaffold(
        backgroundColor: AppColors.deep,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.cream,
        ),
        body: const Center(
          child: Text(
            'Nothing is playing',
            style: TextStyle(color: AppColors.cream),
          ),
        ),
      );
    }

    final nameEn = track.surah?.nameEnglish.isNotEmpty == true
        ? track.surah!.nameEnglish
        : 'Surah ${track.surahId}';
    final nameAr = track.surah?.nameArabic ?? '';
    final artist = track.reciterName ?? AppConstants.appName;
    final isFavorite = favorites.contains(track.id);
    final maxMs = player.duration.inMilliseconds <= 0
        ? 1.0
        : player.duration.inMilliseconds.toDouble();
    final progress = (player.position.inMilliseconds / maxMs).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if ((track.reciterPhotoUrl ?? '').isNotEmpty)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Transform.scale(
                scale: 1.15,
                child: CachedNetworkImage(
                  imageUrl: track.reciterPhotoUrl!,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.35),
                  colorBlendMode: BlendMode.darken,
                  errorWidget: (_, _, _) =>
                      const ColoredBox(color: AppColors.deep),
                ),
              ),
            )
          else
            const ColoredBox(color: AppColors.deep),
          Container(color: const Color(0xD1062423)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.cream,
                          size: 28,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'NOW PLAYING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => showAddToPlaylistSheet(
                          context,
                          ref,
                          recitationId: track.id,
                        ),
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.cream,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: _spin,
                        child: const QaariLogo(size: 180),
                      ),
                      const SizedBox(height: 24),
                      if (nameAr.isNotEmpty)
                        Text(
                          nameAr,
                          textDirection: TextDirection.rtl,
                          style: AppTheme.amiri(
                            fontSize: 30,
                            color: AppColors.gold,
                            height: 1,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        nameEn,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artist,
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final ok = await ensureLoggedIn(context, ref);
                              if (!ok) return;
                              await ref
                                  .read(favoritesControllerProvider.notifier)
                                  .toggle(track.id);
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? AppColors.gold
                                  : AppColors.cream,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FollowAlongScreen(
                                    recitationId: track.id,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gold,
                              side: BorderSide(
                                color: AppColors.gold.withValues(alpha: 0.45),
                              ),
                              backgroundColor:
                                  AppColors.gold.withValues(alpha: 0.18),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.align_horizontal_left, size: 14),
                            label: const Text(
                              'Follow Along',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => shareRecitation(track),
                            icon: const Icon(
                              Icons.ios_share_rounded,
                              color: AppColors.cream,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 5.5,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: AppColors.gold,
                          inactiveTrackColor:
                              AppColors.cream.withValues(alpha: 0.2),
                          thumbColor: AppColors.gold,
                        ),
                        child: Slider(
                          value: progress,
                          onChanged: (value) {
                            ref.read(playerControllerProvider.notifier).seek(
                                  Duration(
                                    milliseconds: (value * maxMs).round(),
                                  ),
                                );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _format(player.position),
                              style: TextStyle(
                                color: AppColors.cream.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              _format(player.duration),
                              style: TextStyle(
                                color: AppColors.cream.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RoundCtrl(
                            icon: Icons.replay_10_rounded,
                            onTap: () {
                              final next = player.position -
                                  const Duration(seconds: 10);
                              ref.read(playerControllerProvider.notifier).seek(
                                    next < Duration.zero
                                        ? Duration.zero
                                        : next,
                                  );
                            },
                          ),
                          _RoundCtrl(
                            icon: Icons.skip_previous_rounded,
                            dimmed: !player.hasPrevious,
                            onTap: player.hasPrevious
                                ? () => ref
                                    .read(playerControllerProvider.notifier)
                                    .playPrevious()
                                : null,
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(playerControllerProvider.notifier)
                                .toggle(),
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.45),
                                    blurRadius: 22,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                player.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.forest,
                                size: 34,
                              ),
                            ),
                          ),
                          _RoundCtrl(
                            icon: Icons.skip_next_rounded,
                            dimmed: !player.hasNext,
                            onTap: player.hasNext
                                ? () => ref
                                    .read(playerControllerProvider.notifier)
                                    .playNext()
                                : null,
                          ),
                          _RoundCtrl(
                            icon: Icons.forward_10_rounded,
                            onTap: () {
                              final next = player.position +
                                  const Duration(seconds: 10);
                              final max = player.duration;
                              ref.read(playerControllerProvider.notifier).seek(
                                    next > max ? max : next,
                                  );
                            },
                          ),
                        ],
                      ),
                      if (player.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          player.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }
}

class _RoundCtrl extends StatelessWidget {
  const _RoundCtrl({
    required this.icon,
    required this.onTap,
    this.dimmed = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.35 : 1,
      child: Material(
        color: AppColors.cream.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: AppColors.cream, size: 22),
          ),
        ),
      ),
    );
  }
}
