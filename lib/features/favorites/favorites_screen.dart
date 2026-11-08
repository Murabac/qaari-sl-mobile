import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/features/reciters/reciter_detail_screen.dart';
import 'package:qaari_sl_mobile/shared/widgets/reciter_portrait.dart';
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
          title: 'Favorites',
          subtitle: auth.isAuthenticated
              ? '${favorites.tracks.length} saved items'
              : 'Sign in to sync favorites',
          trailing: auth.isAuthenticated
              ? TextButton.icon(
                  onPressed: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .refresh(),
                  icon: const Icon(Icons.cloud_outlined, size: 16),
                  label: const Text('Sync'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB88E2D),
                  ),
                )
              : null,
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
                    isEmpty: false,
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
                      child: _FavoriteLists(
                        tracks: favorites.tracks,
                        languageCode: languageCode,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _FavoriteLists extends ConsumerStatefulWidget {
  const _FavoriteLists({required this.tracks, required this.languageCode});

  final List<Recitation> tracks;
  final String languageCode;

  @override
  ConsumerState<_FavoriteLists> createState() => _FavoriteListsState();
}

class _FavoriteListsState extends ConsumerState<_FavoriteLists> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final languageCode = widget.languageCode;
    final followed = ref.watch(recitersProvider('')).maybeWhen(
          data: (reciters) => reciters.where((reciter) => reciter.followed).toList(),
          orElse: () => const <Reciter>[],
        );
    final showReciters = _filter != 'surahs';
    final showSurahs = _filter != 'reciters';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Row(
          children: [
            _Chip(
              label: 'All (${widget.tracks.length + followed.length})',
              selected: _filter == 'all',
              onTap: () => setState(() => _filter = 'all'),
            ),
            _Chip(
              label: 'Reciters (${followed.length})',
              selected: _filter == 'reciters',
              onTap: () => setState(() => _filter = 'reciters'),
            ),
            _Chip(
              label: 'Surahs (${widget.tracks.length})',
              selected: _filter == 'surahs',
              onTap: () => setState(() => _filter = 'surahs'),
            ),
          ],
        ),
        if (showReciters && followed.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'FAVORITE RECITERS',
            style: AppTheme.sans(
              fontSize: 11,
              color: AppColors.muted,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final reciter in followed) ...[
            _ReciterFavorite(reciter: reciter, languageCode: languageCode),
            const SizedBox(height: 10),
          ],
        ],
        if (showSurahs) ...[
          const SizedBox(height: 8),
          Text(
            'SAVED SURAHS & RECITATIONS',
            style: AppTheme.sans(
              fontSize: 11,
              color: AppColors.muted,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final track in widget.tracks) ...[
            Builder(builder: (context) {
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
                                        queue: widget.tracks,
                                      ),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
            }),
            const SizedBox(height: 10),
          ],
        ],
        if (widget.tracks.isEmpty && followed.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Text(
              'No favorites yet.\nTap the heart on a reciter or a surah.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? const Color(0xFF0D3B2E) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? const Color(0xFF0D3B2E) : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: AppTheme.sans(
                fontSize: 12,
                color: selected ? Colors.white : const Color(0xFF0D3B2E),
                weight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReciterFavorite extends StatelessWidget {
  const _ReciterFavorite({required this.reciter, required this.languageCode});

  final Reciter reciter;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final name = reciter.localizedName(languageCode);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReciterDetailScreen(reciterId: reciter.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ReciterFace(reciter: reciter, size: 48, nameForFallback: name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(fontSize: 14, weight: FontWeight.w800),
                    ),
                    Text(
                      '${reciter.region ?? ''} · ${reciter.approvedRecitationsCount} surahs',
                      style: AppTheme.sans(
                        fontSize: 12,
                        color: const Color(0xFFB88E2D),
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF0D3B2E)),
            ],
          ),
        ),
      ),
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
                  backgroundColor: const Color(0xFFC6A15B),
                  foregroundColor: AppColors.deep,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: const StadiumBorder(),
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
