import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';
import 'package:qaari_sl_mobile/core/theme/app_palette.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/player/now_playing_screen.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/shared/widgets/reciter_portrait.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final track = player.current;
    if (track == null) return const SizedBox.shrink();

    final palette = context.palette;
    final languageCode = Localizations.localeOf(context).languageCode;
    final title =
        track.surah?.localizedName(languageCode) ?? 'Surah ${track.surahId}';
    final artist = track.reciterName ?? AppConstants.appName;
    final face = Reciter(
      id: track.reciterId,
      nameSomali: track.reciterName ?? '',
      nameArabic: '',
      nameEnglish: track.reciterName ?? '',
      bioSomali: '',
      bioArabic: '',
      bioEnglish: '',
      photoUrl: track.reciterPhotoUrl,
      region: null,
      approvedRecitationsCount: 0,
    );
    final progress = player.duration.inMilliseconds == 0
        ? 0.0
        : (player.position.inMilliseconds / player.duration.inMilliseconds)
              .clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: palette.navGlass,
            child: InkWell(
              onTap: () => _openPlayer(context),
              child: SizedBox(
                height: ShellMetrics.playerHeight,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
                      child: Row(
                        children: [
                          ArchPortrait(
                            reciter: face,
                            width: 44,
                            height: 46,
                            bottomRadius: 12,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.sans(
                                    fontSize: 14,
                                    color: palette.text,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.sans(
                                    fontSize: 12,
                                    color: palette.muted,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _CircleButton(
                            size: 42,
                            color: palette.primary,
                            iconColor: palette.onPrimary,
                            icon: player.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            onPressed: () => ref
                                .read(playerControllerProvider.notifier)
                                .toggle(),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => ref
                                .read(playerControllerProvider.notifier)
                                .playNext(),
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: palette.muted,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(height: 3, color: palette.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openPlayer(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NowPlayingScreen()));
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.size,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.onPressed,
  });

  final double size;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}
