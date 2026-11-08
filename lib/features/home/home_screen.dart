import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/features/player/open_player.dart';
import 'package:qaari_sl_mobile/features/reciters/reciter_detail_screen.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';
import 'package:qaari_sl_mobile/shared/widgets/reciter_portrait.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _allRecitersKey = GlobalKey();
  String _query = '';
  String _region = '';

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Reciter> _featured(List<Reciter> all) {
    final withPhoto =
        all.where((r) => (r.photoUrl ?? '').isNotEmpty).take(5).toList();
    if (withPhoto.isNotEmpty) return withPhoto;
    return all.take(5).toList();
  }

  List<Reciter> _matching(List<Reciter> reciters) {
    final query = _query.trim().toLowerCase();
    return reciters.where((reciter) {
      if (_region.isNotEmpty && (reciter.region ?? '') != _region) {
        return false;
      }
      if (query.isEmpty) return true;
      final haystack = '${reciter.nameSomali} ${reciter.nameArabic} '
              '${reciter.nameEnglish} ${reciter.bioSomali} ${reciter.bioEnglish} '
              '${reciter.region ?? ''}'
          .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  List<String> _regions(List<Reciter> reciters) {
    final names = <String>{
      for (final reciter in reciters)
        if ((reciter.region ?? '').trim().isNotEmpty) reciter.region!.trim(),
    };
    final list = names.toList()..sort();
    return list;
  }

  void _scrollToAllReciters() {
    final ctx = _allRecitersKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final asyncReciters = ref.watch(recitersProvider(''));
    final l10n = AppLocalizations.of(context);
    final searchHint = switch (languageCode) {
      'ar' => 'ابحث عن قارئ أو سورة…',
      'so' => 'Raadi quraa, suurad, gobol...',
      _ => 'Search reciters, surahs, region...',
    };

    return ColoredBox(
      color: AppColors.cream,
      child: asyncReciters.when(
        loading: () => Column(
          children: [
            HomeBrandHeader(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _query = value),
              searchHint: searchHint,
            ),
            const Expanded(child: QaariLoadingSkeleton()),
          ],
        ),
        error: (error, _) => Column(
          children: [
            HomeBrandHeader(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _query = value),
              searchHint: searchHint,
            ),
            Expanded(
              child: AsyncBody(
                isLoading: false,
                error:
                    '$error\n\n'
                    'API: ${AppConstants.apiBaseUrl}${AppConstants.apiPrefix}',
                isEmpty: false,
                onRetry: () => ref.invalidate(recitersProvider('')),
                child: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        data: (reciters) {
          final filtered = _matching(reciters);
          final featured = _featured(filtered);
          final regions = _regions(reciters);
          final saved = ref.watch(favoritesControllerProvider).tracks;

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => ref.invalidate(recitersProvider('')),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: HomeBrandHeader(
                    searchController: _searchController,
                    onSearchChanged: (value) => setState(() => _query = value),
                    searchHint: searchHint,
                  ),
                ),
                if (_query.isEmpty && regions.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        children: [
                          _RegionChip(
                            label: switch (languageCode) {
                              'ar' => 'الكل',
                              'so' => 'Dhammaan',
                              _ => 'All',
                            },
                            selected: _region.isEmpty,
                            onTap: () => setState(() => _region = ''),
                          ),
                          for (final region in regions)
                            _RegionChip(
                              label: region,
                              selected: _region == region,
                              onTap: () => setState(() => _region = region),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (_query.isEmpty && featured.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 16,
                                      color: Color(0xFFB88E2D),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        l10n.featuredReciters,
                                        style: AppTheme.sans(
                                          fontSize: 16,
                                          weight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _scrollToAllReciters,
                            child: Text(
                              l10n.seeAll,
                              style: AppTheme.sans(
                                fontSize: 12,
                                color: AppColors.gold,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 320,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: featured.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final reciter = featured[index];
                          return _FeaturedCard(
                            reciter: reciter,
                            languageCode: languageCode,
                            onTap: () => _open(reciter.id),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  key: _allRecitersKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.explore_outlined,
                                size: 16,
                                color: Color(0xFFB88E2D),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _query.isEmpty ? l10n.allReciters : l10n.results,
                                  style: AppTheme.sans(
                                    fontSize: 16,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${filtered.length} Available',
                          style: AppTheme.sans(
                            fontSize: 11,
                            color: AppColors.muted,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        _query.isEmpty
                            ? 'No reciters available yet'
                            : 'No reciters found for "$_query"',
                        style: AppTheme.sans(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final reciter = filtered[index];
                        return _ReciterRow(
                          reciter: reciter,
                          languageCode: languageCode,
                          onTap: () => _open(reciter.id),
                        );
                      },
                    ),
                  ),
                if (_query.isEmpty && saved.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            switch (languageCode) {
                              'ar' => 'السور المفضلة',
                              'so' => 'Suuradaha Loogu Jecelyahay',
                              _ => 'Favorite Surahs',
                            },
                            style: AppTheme.sans(
                              fontSize: 16,
                              weight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (final track in saved.take(8)) ...[
                            _SavedSurahRow(
                              track: track,
                              languageCode: languageCode,
                              onPlay: () => openPlayerAndPlay(
                                context,
                                ref,
                                track,
                                queue: saved,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _open(int id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReciterDetailScreen(reciterId: id),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.reciter,
    required this.languageCode,
    required this.onTap,
  });

  final Reciter reciter;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = reciter.localizedName(languageCode);
    final region = reciter.region ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 224,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppColors.featuredShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.forest),
            if (reciterPortraitAsset(reciter) != null)
              Image.asset(
                reciterPortraitAsset(reciter)!,
                fit: BoxFit.cover,
              )
            else if ((reciter.photoUrl ?? '').isNotEmpty)
              CachedNetworkImage(
                imageUrl: reciter.photoUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) =>
                    const ColoredBox(color: AppColors.forest),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0xD9000000)],
                  stops: [0.35, 1],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 16,
                  color: Color(0xFF0D3B2E),
                ),
              ),
            ),
            if (region.isNotEmpty)
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xE6DFB76C),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    region.toUpperCase(),
                    style: AppTheme.sans(
                      fontSize: 10,
                      color: const Color(0xFF07241C),
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sans(
                      fontSize: 16,
                      color: Colors.white,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    switch (languageCode) {
                      'ar' =>
                        '${reciter.approvedRecitationsCount} سور · تلاوة',
                      'so' =>
                        '${reciter.approvedRecitationsCount} suuradood · Tilawa',
                      _ => '${reciter.approvedRecitationsCount} surahs · Tilawa',
                    },
                    style: AppTheme.sans(
                      fontSize: 12,
                      color: AppColors.goldLight,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            switch (languageCode) {
                              'ar' => 'استمع الآن',
                              'so' => 'Dhageyso hadda',
                              _ => 'Listen now',
                            },
                            style: AppTheme.sans(
                              fontSize: 12,
                              color: Colors.white,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

class _ReciterRow extends StatelessWidget {
  const _ReciterRow({
    required this.reciter,
    required this.languageCode,
    required this.onTap,
  });

  final Reciter reciter;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = reciter.localizedName(languageCode);
    final bio = reciter.localizedBio(languageCode);

    return Material(
      color: AppColors.creamCard,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ReciterFace(
                reciter: reciter,
                size: 58,
                borderRadius: BorderRadius.circular(18),
                nameForFallback: name,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        fontSize: 15,
                        weight: FontWeight.w800,
                      ),
                    ),
                    if (bio.isNotEmpty)
                      Text(
                        bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.sans(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    Text(
                      '${reciter.approvedRecitationsCount} Surahs'
                      '${(reciter.region ?? '').isNotEmpty ? ' · ${reciter.region}' : ''}',
                      style: AppTheme.sans(
                        fontSize: 12,
                        color: const Color(0xFFB88E2D),
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 22, color: Color(0xFFCBD5D1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedSurahRow extends StatelessWidget {
  const _SavedSurahRow({
    required this.track,
    required this.languageCode,
    required this.onPlay,
  });

  final Recitation track;
  final String languageCode;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final name = track.surah?.localizedName(languageCode) ??
        'Surah ${track.surahId}';
    final arabic = track.surah?.nameArabic ?? '';
    final number = track.surah?.number ?? track.surahId;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPlay,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$number',
                  style: AppTheme.sans(
                    fontSize: 13,
                    weight: FontWeight.w800,
                    color: const Color(0xFF0D3B2E),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        fontSize: 14,
                        weight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      [
                        if (arabic.isNotEmpty) arabic,
                        track.durationLabel,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D3B2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFFE8C882),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
