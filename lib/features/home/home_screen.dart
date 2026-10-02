import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/reciters/reciter_detail_screen.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';
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
  int _riwayahFilter = 0;

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

  List<Reciter> _applyRiwayahFilter(List<Reciter> reciters) {
    if (_riwayahFilter == 0) return reciters;
    final needle = _riwayahFilter == 1 ? 'hafs' : 'duri';
    return reciters.where((r) {
      final haystack =
          '${r.region ?? ''} ${r.nameEnglish} ${r.bioEnglish}'.toLowerCase();
      return haystack.contains(needle);
    }).toList();
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

  String _greetingSmall(String lang) {
    return switch (lang) {
      'ar' => 'السلام عليكم ورحمة الله',
      'so' => 'Assalaamu Calaykum',
      _ => 'Peace and Blessings',
    };
  }

  String _greetingTitle(String lang) {
    return switch (lang) {
      'ar' => 'طِبْتُمْ وَطَابَ مَمْشَاكُمْ',
      'so' => 'Kusoo Dhawoow Xulka Quraada',
      _ => 'Listen with Khushuu\'',
    };
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final asyncReciters = ref.watch(recitersProvider(_query));
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: AppColors.cream,
      child: asyncReciters.when(
        loading: () => Column(
          children: [
            HomeBrandHeader(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _query = value),
              searchHint: l10n.searchReciters,
              greetingSmall: _greetingSmall(languageCode),
              greetingTitle: _greetingTitle(languageCode),
            ),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
          ],
        ),
        error: (error, _) => Column(
          children: [
            HomeBrandHeader(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _query = value),
              searchHint: l10n.searchReciters,
              greetingSmall: _greetingSmall(languageCode),
              greetingTitle: _greetingTitle(languageCode),
            ),
            Expanded(
              child: AsyncBody(
                isLoading: false,
                error:
                    '$error\n\n'
                    'API: ${AppConstants.apiBaseUrl}${AppConstants.apiPrefix}',
                isEmpty: false,
                onRetry: () => ref.invalidate(recitersProvider(_query)),
                child: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        data: (reciters) {
          final featured = _featured(reciters);
          final filtered = _applyRiwayahFilter(reciters);

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async =>
                ref.invalidate(recitersProvider(_query)),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: HomeBrandHeader(
                    searchController: _searchController,
                    onSearchChanged: (value) => setState(() => _query = value),
                    searchHint: l10n.searchReciters,
                    greetingSmall: _greetingSmall(languageCode),
                    greetingTitle: _greetingTitle(languageCode),
                  ),
                ),
                if (_query.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _DailyReflectionCard(
                        languageCode: languageCode,
                        onExplore: featured.isNotEmpty
                            ? () => _open(featured.first.id)
                            : _scrollToAllReciters,
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
                                Text(
                                  l10n.featuredReciters,
                                  style: AppTheme.displayFont(fontSize: 20),
                                ),
                                Text(
                                  'Curated masters · Studio recordings',
                                  style: AppTheme.sans(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
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
                      height: 210,
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: QaariSegmentedBar(
                      labels: const ['All Riwayah', 'Hafs', 'Duri'],
                      selectedIndex: _riwayahFilter,
                      onSelected: (value) =>
                          setState(() => _riwayahFilter = value),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  key: _allRecitersKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _query.isEmpty ? l10n.allReciters : l10n.results,
                            style: AppTheme.displayFont(fontSize: 20),
                          ),
                        ),
                        Text(
                          '${filtered.length} Masters',
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
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

class _DailyReflectionCard extends StatelessWidget {
  const _DailyReflectionCard({
    required this.languageCode,
    required this.onExplore,
  });

  final String languageCode;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final label = switch (languageCode) {
      'ar' => 'تأمل يومي',
      'so' => 'Fikrad maalinle',
      _ => 'Daily Reflection',
    };
    final cta = switch (languageCode) {
      'ar' => 'استمع الآن',
      'so' => 'Dhageyso',
      _ => 'Listen now',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.deep],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: AppColors.featuredShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppTheme.sans(
                  fontSize: 10,
                  color: AppColors.gold,
                  weight: FontWeight.w700,
                ).copyWith(letterSpacing: 1.1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
            textAlign: TextAlign.center,
            style: AppTheme.amiri(
              fontSize: 20,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surah Al-Mulk',
                      style: AppTheme.displayFont(
                        fontSize: 16,
                        color: AppColors.cream,
                      ),
                    ),
                    Text(
                      'Safwat al-Qurra Collection',
                      style: AppTheme.sans(
                        fontSize: 11,
                        color: AppColors.mutedOnDark,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: onExplore,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.deep,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(
                  cta,
                  style: AppTheme.sans(
                    fontSize: 12,
                    weight: FontWeight.w700,
                    color: AppColors.deep,
                  ),
                ),
              ),
            ],
          ),
        ],
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
        width: 256,
        decoration: BoxDecoration(
          color: AppColors.creamCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                      ColoredBox(
                        color: AppColors.forestSoft,
                        child: Center(
                          child: ReciterInitialsAvatar(name: name, size: 64),
                        ),
                      ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xE0062423),
                          ],
                          stops: [0.35, 1],
                        ),
                      ),
                    ),
                    if (region.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.deep.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            region,
                            style: AppTheme.sans(
                              fontSize: 10,
                              color: AppColors.goldLight,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reciter.nameArabic.isNotEmpty)
                            Text(
                              reciter.nameArabic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                              style: AppTheme.amiri(
                                fontSize: 13,
                                color: AppColors.goldLight,
                              ),
                            ),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.displayFont(
                              fontSize: 16,
                              color: AppColors.cream,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${reciter.approvedRecitationsCount} surahs',
                    style: AppTheme.sans(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.creamSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 16,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
          ],
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

    return Material(
      color: AppColors.creamCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              NetworkAvatar(
                url: reciter.photoUrl,
                size: 48,
                borderRadius: BorderRadius.circular(12),
                nameForFallback: name,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTheme.displayFont(
                        fontSize: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                    if (reciter.nameArabic.isNotEmpty)
                      Text(
                        reciter.nameArabic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: AppTheme.amiri(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    Text(
                      '${reciter.approvedRecitationsCount} Surahs'
                      '${(reciter.region ?? '').isNotEmpty ? ' · ${reciter.region}' : ''}',
                      style: AppTheme.sans(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.creamSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
