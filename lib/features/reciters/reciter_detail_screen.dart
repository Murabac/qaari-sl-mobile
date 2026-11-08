import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/share/share_recitation.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';
import 'package:qaari_sl_mobile/features/downloads/downloads_screen.dart';
import 'package:qaari_sl_mobile/features/player/open_player.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/features/playlists/add_to_playlist_sheet.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';
import 'package:qaari_sl_mobile/shared/widgets/reciter_portrait.dart';
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
        loading: () => const QaariLoadingSkeleton(),
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
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: AppColors.forest),
                          if (reciterPortraitAsset(reciter) != null)
                            Image.asset(
                              reciterPortraitAsset(reciter)!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          else if ((reciter.photoUrl ?? '').isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: reciter.photoUrl!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x00F5F2EA),
                                  Color(0x00F5F2EA),
                                  Color(0xB3F5F2EA),
                                  AppColors.cream,
                                  AppColors.cream,
                                ],
                                stops: [0, 0.42, 0.62, 0.78, 1],
                              ),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.paddingOf(context).top + 8,
                            left: 12,
                            child: _RoundIconButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.paddingOf(context).top + 8,
                            right: 12,
                            child: Row(
                              children: [
                                if (reciter.recitations.isNotEmpty)
                                  _RoundIconButton(
                                    icon: Icons.ios_share_rounded,
                                    onTap: () => shareRecitation(
                                      reciter.recitations.first,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                _FollowReciterButton(
                                  reciter: reciter,
                                  heart: true,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 4,
                            child: Row(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.cream,
                                      width: 3,
                                    ),
                                  ),
                                  child: ReciterFace(
                                    reciter: reciter,
                                    size: 64,
                                    nameForFallback: name,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.sans(
                                          fontSize: 22,
                                          color: const Color(0xFF10241C),
                                          weight: FontWeight.w800,
                                          height: 1.15,
                                        ),
                                      ),
                                      if ((reciter.region ?? '').isNotEmpty)
                                        Text(
                                          reciter.region!,
                                          style: AppTheme.sans(
                                            fontSize: 13,
                                            color: const Color(0xFFB88E2D),
                                            weight: FontWeight.w700,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  _StatCell(
                                    value: '${reciter.approvedRecitationsCount}',
                                    label: switch (languageCode) {
                                      'ar' => 'سور',
                                      'so' => 'SUURADOOD',
                                      _ => 'SURAHS',
                                    },
                                  ),
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: AppColors.border,
                                  ),
                                  _StatCell(
                                    value: (reciter.region ?? '—')
                                        .split(' ')
                                        .first,
                                    label: switch (languageCode) {
                                      'ar' => 'المنطقة',
                                      'so' => 'GOBOLKA',
                                      _ => 'REGION',
                                    },
                                  ),
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: AppColors.border,
                                  ),
                                  _StatCell(
                                    value: 'Tilawa',
                                    label: switch (languageCode) {
                                      'ar' => 'الأسلوب',
                                      'so' => 'QAABKA',
                                      _ => 'STYLE',
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (bio.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          switch (languageCode) {
                            'ar' => 'نبذة',
                            'so' => 'KU SAABSAN',
                            _ => 'ABOUT',
                          },
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            bio,
                            style: const TextStyle(
                              color: Color(0xFF1C3A32),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    children: [
                      Text(
                        switch (languageCode) {
                          'ar' => 'السور',
                          'so' => 'Suuradood',
                          _ => 'Surahs',
                        },
                        style: AppTheme.sans(
                          fontSize: 18,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${reciter.approvedRecitationsCount} Recitations',
                        style: AppTheme.sans(
                          fontSize: 12,
                          color: const Color(0xFFB88E2D),
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                    backgroundColor: const Color(0xFF0D3B2E),
                    foregroundColor: const Color(0xFFE8C882),
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

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC0D3B2E),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _FollowReciterButton extends ConsumerStatefulWidget {
  const _FollowReciterButton({required this.reciter, this.heart = false});

  final Reciter reciter;
  final bool heart;

  @override
  ConsumerState<_FollowReciterButton> createState() =>
      _FollowReciterButtonState();
}

class _FollowReciterButtonState extends ConsumerState<_FollowReciterButton> {
  late bool _followed = widget.reciter.followed;
  var _busy = false;

  @override
  void didUpdateWidget(covariant _FollowReciterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reciter.followed != widget.reciter.followed) {
      _followed = widget.reciter.followed;
    }
  }

  Future<void> _toggle() async {
    if (_busy) return;
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      return;
    }
    final previous = _followed;
    setState(() {
      _busy = true;
      _followed = !previous;
    });
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final saved = previous
          ? await repo.unfollowReciter(widget.reciter.id)
          : await repo.followReciter(widget.reciter.id);
      if (!mounted) return;
      setState(() => _followed = saved.followed);
    } catch (_) {
      if (!mounted) return;
      setState(() => _followed = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).momentsFollowFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.heart) {
      return Material(
        color: _followed ? const Color(0xFFE5B54F) : const Color(0xCC0D3B2E),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _toggle,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              _followed ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _followed ? const Color(0xFF08281F) : Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }
    return TextButton(
      onPressed: _toggle,
      style: TextButton.styleFrom(
        backgroundColor: _followed ? AppColors.gold : Colors.transparent,
        foregroundColor: _followed ? AppColors.deep : AppColors.gold,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.gold),
        ),
      ),
      child: Text(
        _followed ? l10n.momentsFollowingLabel : l10n.momentsFollow,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
