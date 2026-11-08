import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/features/follow_along/follow_along_screen.dart';
import 'package:qaari_sl_mobile/features/player/now_playing_screen.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/shared/widgets/reciter_portrait.dart';

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
    final arabic = track.surah?.nameArabic ?? '';
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPlayer(context),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppRadius.card),
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
                      ReciterFace(
                        reciter: face,
                        size: 44,
                        borderRadius: BorderRadius.circular(12),
                        nameForFallback: artist,
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
                                fontSize: 14,
                                color: AppColors.cream,
                                weight: FontWeight.w600,
                              ),
                            ),
                            if (arabic.isNotEmpty)
                              Text(
                                arabic,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                style: AppTheme.displayFont(
                                  fontSize: 12,
                                  color: AppColors.goldLight,
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
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  FollowAlongScreen(recitationId: track.id),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.goldLight,
                          side: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.55),
                          ),
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(0, 32),
                        ),
                        child: Text(
                          switch (languageCode) {
                            'ar' => 'تابع',
                            'so' => 'La soco',
                            _ => 'Follow',
                          },
                          style: AppTheme.sans(
                            fontSize: 11,
                            color: AppColors.goldLight,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size(36, 36),
                          fixedSize: const Size(36, 36),
                        ),
                      ),
                      const SizedBox(width: 6),
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
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const Size(32, 36),
                          padding: EdgeInsets.zero,
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
