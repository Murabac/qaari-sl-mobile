import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/data/catalog_repository.dart';
import 'package:qaari_sl_mobile/core/models/reciter.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
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
    final asyncReciters = ref.watch(recitersProvider(_query));
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _HomeHeader(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          onClear: () {
            _searchController.clear();
            setState(() => _query = '');
          },
        ),
        Expanded(
          child: ColoredBox(
            color: AppColors.cream,
            child: asyncReciters.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (error, _) => AsyncBody(
                isLoading: false,
                error:
                    '$error\n\n'
                    'API: ${AppConstants.apiBaseUrl}${AppConstants.apiPrefix}\n\n'
                    'On Samsung USB tethering:\n'
                    '• Use the PC Ethernet / Samsung USB NDIS IP from ipconfig\n'
                    '  (not Wi‑Fi). Example: http://10.172.77.244:8000\n'
                    '• Rebuild — hot reload does not change --dart-define\n'
                    '• PC: php artisan serve --host=0.0.0.0 --port=8000',
                isEmpty: false,
                onRetry: () => ref.invalidate(recitersProvider(_query)),
                child: const SizedBox.shrink(),
              ),
              data: (reciters) {
                final featured = _featured(reciters);
                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async =>
                      ref.invalidate(recitersProvider(_query)),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if (_query.isEmpty && featured.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.featuredReciters,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _scrollToAllReciters,
                                  child: Text(
                                    l10n.seeAll,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 188,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: featured.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 14),
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
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                          child: Text(
                            _query.isEmpty ? l10n.allReciters : l10n.results,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      if (reciters.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              _query.isEmpty
                                  ? 'No reciters available yet'
                                  : 'No reciters found for "$_query"',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          sliver: SliverList.separated(
                            itemCount: reciters.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final reciter = reciters[index];
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
          ),
        ),
      ],
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.forest,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 12,
        20,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: QaariLogo(size: 64),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.gold,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(color: AppColors.cream, fontSize: 14),
                    cursorColor: AppColors.gold,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).searchReciters,
                      hintStyle: const TextStyle(
                        color: AppColors.mutedSoft,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.gold,
                      size: 16,
                    ),
                  ),
              ],
            ),
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
        width: 155,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.featuredShadow,
        ),
        clipBehavior: Clip.antiAlias,
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
                child: Center(child: ReciterInitialsAvatar(name: name, size: 64)),
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
                  stops: [0.25, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (region.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        region.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.forest,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${reciter.approvedRecitationsCount} surahs',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
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
    final subtitle = bio.isNotEmpty
        ? (bio.length > 42 ? '${bio.substring(0, 42)}…' : bio)
        : (reciter.region ?? AppConstants.appName);

    return Material(
      color: AppColors.creamCard,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: AppColors.forest.withValues(alpha: 0.07),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.cardShadow,
            color: AppColors.creamCard,
          ),
          child: Row(
            children: [
              NetworkAvatar(
                url: reciter.photoUrl,
                size: 52,
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
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reciter.approvedRecitationsCount} Surahs'
                      '${(reciter.region ?? '').isNotEmpty ? ' · ${reciter.region}' : ''}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
