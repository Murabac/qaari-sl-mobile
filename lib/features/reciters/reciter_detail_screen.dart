import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/share/share_recitation.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';
import 'package:qaari_sl_mobile/features/downloads/downloads_screen.dart';
import 'package:qaari_sl_mobile/features/player/open_player.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/features/playlists/add_to_playlist_sheet.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class ReciterDetailScreen extends ConsumerWidget {
  const ReciterDetailScreen({super.key, required this.reciterId});

  final int reciterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final asyncReciter = ref.watch(reciterDetailProvider(reciterId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: asyncReciter.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (error, _) => AsyncBody(
          isLoading: false,
          error: error,
          isEmpty: false,
          onRetry: () => ref.invalidate(reciterDetailProvider(reciterId)),
          child: const SizedBox.shrink(),
        ),
        data: (reciter) {
          final name = reciter.localizedName(languageCode);
          final bio = reciter.localizedBio(languageCode);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if ((reciter.photoUrl ?? '').isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: reciter.photoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) =>
                              const ColoredBox(color: AppColors.forest),
                        )
                      else
                        const ColoredBox(color: AppColors.forest),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x73062423),
                              Color(0xC7062423),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 8,
                        left: 16,
                        child: QaariForestIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 18,
                        child: Row(
                          children: [
                            NetworkAvatar(
                              url: reciter.photoUrl,
                              size: 58,
                              nameForFallback: name,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: AppColors.cream,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if ((reciter.region ?? '').isNotEmpty)
                                    Text(
                                      reciter.region!,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.creamCard,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      _StatCell(
                        value: '${reciter.approvedRecitationsCount}',
                        label: 'Surahs',
                      ),
                      Container(width: 1, height: 36, color: AppColors.border),
                      _StatCell(
                        value: (reciter.region ?? '—').split(' ').first,
                        label: 'Region',
                      ),
                      Container(width: 1, height: 36, color: AppColors.border),
                      const _StatCell(value: 'Tilawa', label: 'Style'),
                    ],
                  ),
                ),
              ),
              if (bio.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ABOUT',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bio,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Text(
                    'Surahs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                  ),
                ),
              ),
              if (reciter.recitations.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No approved recitations yet')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: Builder(
                    builder: (context) {
                      final queue = reciter.recitations
                          .map(
                            (track) => track.copyWith(
                              reciterName: name,
                              reciterPhotoUrl: reciter.photoUrl,
                            ),
                          )
                          .toList();

                      return SliverList.separated(
                        itemCount: queue.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _SurahRow(
                            track: queue[index],
                            queue: queue,
                            languageCode: languageCode,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahRow extends ConsumerWidget {
  const _SurahRow({
    required this.track,
    required this.queue,
    required this.languageCode,
  });

  final Recitation track;
  final List<Recitation> queue;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final isCurrent = player.current?.id == track.id;
    final surah = track.surah;
    final nameEn = surah?.localizedName('en') ?? 'Surah ${track.surahId}';
    final nameAr = surah?.nameArabic ?? '';
    final number = surah?.number ?? track.surahId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
        border: isCurrent
            ? Border.all(color: AppColors.forest.withValues(alpha: 0.35))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => openPlayerAndPlay(context, ref, track, queue: queue),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameEn,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.ink,
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
                DownloadActionButton(recitation: track),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.muted,
                  ),
                  onSelected: (value) async {
                    if (value == 'playlist') {
                      await showAddToPlaylistSheet(
                        context,
                        ref,
                        recitationId: track.id,
                      );
                    } else if (value == 'share') {
                      await shareRecitation(track);
                    } else if (value == 'favorite') {
                      final ok = await ensureLoggedIn(context, ref);
                      if (!ok) return;
                      await ref
                          .read(favoritesControllerProvider.notifier)
                          .toggle(track.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'favorite', child: Text('Favorite')),
                    PopupMenuItem(
                      value: 'playlist',
                      child: Text('Add to playlist'),
                    ),
                    PopupMenuItem(value: 'share', child: Text('Share')),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    if (isCurrent && player.isPlaying) {
                      ref.read(playerControllerProvider.notifier).toggle();
                      return;
                    }
                    openPlayerAndPlay(context, ref, track, queue: queue);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.gold,
                  ),
                  icon: Icon(
                    isCurrent && player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
