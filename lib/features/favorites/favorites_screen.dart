import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';
import 'package:qaari_sl_mobile/features/player/open_player.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        ForestPageHeader(
          eyebrow: 'Personal Sanctuary',
          title: 'Favorites',
          subtitle: auth.isAuthenticated
              ? '${favorites.tracks.length} saved '
                  '${favorites.tracks.length == 1 ? 'track' : 'tracks'}'
              : 'Sign in to sync favorites',
        ),
        Expanded(
          child: ColoredBox(
            color: AppColors.cream,
            child: !auth.isAuthenticated
                ? _EmptyState(
                    icon: Icons.favorite_border_rounded,
                    message:
                        'Log in to sync your favorites.\nTap the heart on any track to save it.',
                    actionLabel: 'Log in',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  )
                : AsyncBody(
                    isLoading:
                        favorites.isLoading && favorites.tracks.isEmpty,
                    error: favorites.error,
                    isEmpty: favorites.tracks.isEmpty,
                    emptyWidget: const _EmptyState(
                      icon: Icons.favorite_border_rounded,
                      message:
                          'No favorites yet.\nTap the heart icon on any track to save it here.',
                    ),
                    onRetry: () => ref
                        .read(favoritesControllerProvider.notifier)
                        .refresh(),
                    child: RefreshIndicator(
                      color: AppColors.gold,
                      onRefresh: () => ref
                          .read(favoritesControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        itemCount: favorites.tracks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final track = favorites.tracks[index];
                          final nameEn = track.surah?.localizedName(languageCode) ??
                              'Surah ${track.surahId}';
                          final nameAr = track.surah?.nameArabic ?? '';
                          final number =
                              track.surah?.number ?? track.surahId;

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.creamCard,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              boxShadow: AppColors.cardShadow,
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.forest,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$number',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nameEn,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (nameAr.isNotEmpty)
                                            Text(
                                              nameAr,
                                              style: AppTheme.amiri(
                                                fontSize: 15,
                                                color: AppColors.muted,
                                                height: 1.2,
                                              ),
                                            ),
                                          Text(
                                            ' · ${track.durationLabel}',
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => ref
                                      .read(favoritesControllerProvider.notifier)
                                      .toggle(track.id),
                                  icon: const Icon(
                                    Icons.favorite_rounded,
                                    color: AppColors.gold,
                                  ),
                                ),
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.forest,
                                    foregroundColor: AppColors.gold,
                                  ),
                                  onPressed: () => openPlayerAndPlay(
                                        context,
                                        ref,
                                        track,
                                        queue: favorites.tracks,
                                      ),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.gold.withValues(alpha: 0.35)),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.forest,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
