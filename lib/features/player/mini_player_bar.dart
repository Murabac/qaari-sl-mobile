import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/player/now_playing_screen.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';

class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final track = player.current;
    if (track == null) {
      return const SizedBox.shrink();
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    final title = track.surah?.localizedName(languageCode) ??
        'Surah ${track.surahId}';
    final artist = track.reciterName ?? AppConstants.appName;
    final surahNumber = track.surah?.number ?? track.surahId;
    final progress = player.duration.inMilliseconds == 0
        ? 0.0
        : (player.position.inMilliseconds / player.duration.inMilliseconds)
            .clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPlayer(context),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              boxShadow: AppColors.miniPlayerShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    backgroundColor: AppColors.forestSoft,
                    color: AppColors.goldLight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.deep,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.45),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$surahNumber',
                          style: AppTheme.displayFont(
                            fontSize: 16,
                            color: AppColors.goldLight,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.displayFont(
                                fontSize: 15,
                                color: AppColors.cream,
                                weight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.sans(
                                fontSize: 11,
                                color: AppColors.mutedOnDark,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => ref
                            .read(playerControllerProvider.notifier)
                            .toggle(),
                        icon: Icon(
                          player.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.deep,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => ref
                            .read(playerControllerProvider.notifier)
                            .playNext(),
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.mutedOnDark,
                          size: 22,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _openPlayer(context),
                        icon: const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: AppColors.mutedOnDark,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NowPlayingScreen()),
    );
  }
}
