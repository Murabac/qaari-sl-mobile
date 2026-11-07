import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/follow_along/ayah_index.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class FollowAlongScreen extends ConsumerStatefulWidget {
  const FollowAlongScreen({super.key, required this.recitationId});

  final int recitationId;

  @override
  ConsumerState<FollowAlongScreen> createState() => _FollowAlongScreenState();
}

class _FollowAlongScreenState extends ConsumerState<FollowAlongScreen> {
  final _itemKeys = <int, GlobalKey>{};
  int? _lastScrolledIndex;

  void _scrollToAyah(int index) {
    if (index < 0 || index == _lastScrolledIndex) return;
    _lastScrolledIndex = index;
    final ctx = _itemKeys[index]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncPayload = ref.watch(followAlongProvider(widget.recitationId));
    final player = ref.watch(playerControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: asyncPayload.when(
        loading: () => const QaariLoadingSkeleton(),
        error: (error, _) => AsyncBody(
          isLoading: false,
          error: error,
          isEmpty: false,
          onRetry: () =>
              ref.invalidate(followAlongProvider(widget.recitationId)),
          child: const SizedBox.shrink(),
        ),
        data: (payload) {
          final durationSeconds = player.duration.inMilliseconds > 0
              ? player.duration.inMilliseconds / 1000.0
              : payload.recitation.duration.toDouble();
          final verseCount = payload.ayahs.isNotEmpty
              ? payload.ayahs.length
              : (payload.recitation.surah?.verseCount ?? 0);
          final currentIndex = ayahIndexFromStarts(
            positionSeconds: player.position.inMilliseconds / 1000.0,
            ayahStarts: payload.ayahStarts,
            verseCount: verseCount,
            durationSeconds: durationSeconds,
          );
          final progress = durationSeconds <= 0
              ? 0.0
              : (player.position.inMilliseconds / 1000.0 / durationSeconds)
                  .clamp(0.0, 1.0);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToAyah(currentIndex);
          });

          final nameEn = payload.recitation.surah?.nameEnglish ??
              'Surah ${payload.recitation.surahId}';
          final nameAr = payload.recitation.surah?.nameArabic ?? '';
          final artist = payload.recitation.reciterName ?? AppConstants.appName;

          return Column(
            children: [
              Container(
                color: AppColors.forest,
                padding: EdgeInsets.fromLTRB(
                  12,
                  MediaQuery.paddingOf(context).top + 8,
                  12,
                  16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.cream,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          if (nameAr.isNotEmpty)
                            Text(
                              nameAr,
                              style: AppTheme.amiri(
                                fontSize: 22,
                                color: AppColors.gold,
                                height: 1,
                              ),
                            ),
                          const SizedBox(height: 3),
                          Text(
                            '$nameEn · $artist',
                            style: TextStyle(
                              color: AppColors.cream.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: const BoxDecoration(
                  color: AppColors.creamCard,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.amiri(
                    fontSize: 22,
                    color: AppColors.ink,
                    height: 1.6,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  itemCount: payload.ayahs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final ayah = payload.ayahs[index];
                    final active = index == currentIndex;
                    _itemKeys.putIfAbsent(index, GlobalKey.new);
                    return KeyedSubtree(
                      key: _itemKeys[index],
                      child: Material(
                        color: active ? AppColors.forest : AppColors.creamCard,
                        borderRadius: BorderRadius.circular(18),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            final starts = payload.ayahStarts;
                            Duration target;
                            if (starts.isNotEmpty && index < starts.length) {
                              target = Duration(
                                milliseconds: (starts[index] * 1000).round(),
                              );
                            } else if (durationSeconds > 0 && verseCount > 0) {
                              target = Duration(
                                milliseconds: ((index / verseCount) *
                                        durationSeconds *
                                        1000)
                                    .round(),
                              );
                            } else {
                              return;
                            }
                            ref
                                .read(playerControllerProvider.notifier)
                                .seek(target);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: active
                                  ? null
                                  : Border.all(color: AppColors.border),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: AppColors.forest
                                            .withValues(alpha: 0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    ayah.textUthmani,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    style: AppTheme.amiri(
                                      fontSize: 24,
                                      height: 1.9,
                                      color: active
                                          ? AppColors.gold
                                          : AppColors.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: active
                                        ? AppColors.gold.withValues(alpha: 0.25)
                                        : AppColors.cream,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${ayah.number}',
                                    style: TextStyle(
                                      color: active
                                          ? AppColors.gold
                                          : AppColors.ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: AppColors.forest,
                padding: EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  MediaQuery.paddingOf(context).bottom + 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameEn,
                            style: const TextStyle(
                              color: AppColors.cream,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            artist,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor:
                              AppColors.cream.withValues(alpha: 0.2),
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(playerControllerProvider.notifier).toggle(),
                      icon: Icon(
                        player.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
