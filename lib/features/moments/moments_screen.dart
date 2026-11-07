import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/data/moments_repository.dart';
import 'package:qaari_sl_mobile/core/models/moment.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';
import 'package:qaari_sl_mobile/features/follow_along/follow_along_screen.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/features/reciters/reciter_detail_screen.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

class MomentsScreen extends ConsumerStatefulWidget {
  const MomentsScreen({super.key, this.isActive = true});

  /// False when another bottom-nav tab is selected (IndexedStack keeps us alive).
  final bool isActive;

  @override
  ConsumerState<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends ConsumerState<MomentsScreen> {
  final _scroll = ScrollController();
  final _listKey = GlobalKey();
  final _cardKeys = <int, GlobalKey>{};

  List<Moment> _items = const [];
  var _page = 1;
  var _hasMore = true;
  var _loading = true;
  var _loadingMore = false;
  Object? _error;
  var _active = 0;
  var _muted = false;
  var _filter = 'latest';
  String? _tag;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant MomentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive && !widget.isActive) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int index) => _cardKeys.putIfAbsent(index, GlobalKey.new);

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final result = await ref
          .read(momentsRepositoryProvider)
          .fetchPage(
            page: reset ? 1 : _page + 1,
            filter: _filter,
            query: _search.text,
            tag: _tag,
          );
      if (!mounted) return;
      setState(() {
        _items = reset ? result.items : [..._items, ...result.items];
        _page = result.currentPage;
        _hasMore = result.hasMore;
        _loading = false;
        _loadingMore = false;
        _error = null;
        if (reset) _active = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncActive());
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = error;
      });
      if (error is DioException && error.response?.statusCode == 401) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  Future<void> _requireAuth() async {
    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _toggleSave(Moment moment) async {
    if (!ref.read(authControllerProvider).isAuthenticated) {
      await _requireAuth();
      return;
    }
    final index = _items.indexWhere((item) => item.id == moment.id);
    if (index < 0) return;
    final previous = _items[index];
    setState(() {
      _items[index] = previous.copyWith(
        saved: !previous.saved,
        savesCount: previous.saved
            ? (previous.savesCount - 1).clamp(0, 1 << 30)
            : previous.savesCount + 1,
      );
    });
    try {
      final repo = ref.read(momentsRepositoryProvider);
      final saved = previous.saved
          ? await repo.unsave(previous.id)
          : await repo.save(previous.id);
      if (!mounted) return;
      setState(() => _items[index] = saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _items[index] = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).momentsSaveFailed)),
      );
    }
  }

  Future<void> _toggleFollow(Moment moment) async {
    final reciterId = moment.reciterId;
    if (reciterId == null) return;
    if (!ref.read(authControllerProvider).isAuthenticated) {
      await _requireAuth();
      return;
    }
    final previous = [
      for (final item in _items) item,
    ];
    final next = !moment.followedReciter;
    setState(() {
      _items = [
        for (final item in _items)
          item.reciterId == reciterId
              ? item.copyWith(followedReciter: next)
              : item,
      ];
    });
    try {
      final repo = ref.read(momentsRepositoryProvider);
      if (moment.followedReciter) {
        await repo.unfollowReciter(reciterId);
      } else {
        await repo.followReciter(reciterId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).momentsFollowFailed),
        ),
      );
    }
  }

  Future<void> _openComments(Moment moment) async {
    final delta = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (context) => _CommentsSheet(momentId: moment.id),
    );
    if (!mounted || delta == null || delta == 0) return;
    final index = _items.indexWhere((item) => item.id == moment.id);
    if (index < 0) return;
    setState(() {
      _items[index] = _items[index].copyWith(
        commentsCount: (_items[index].commentsCount + delta).clamp(0, 1 << 30),
      );
    });
  }

  void _onScroll() {
    _syncActive();
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 480) {
      _load(reset: false);
    }
  }

  void _syncActive() {
    final listBox = _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (listBox == null || !listBox.hasSize || _items.isEmpty) return;
    final centerY = listBox.localToGlobal(Offset(0, listBox.size.height / 2)).dy;
    var best = _active;
    var bestDistance = double.infinity;
    for (var i = 0; i < _items.length; i++) {
      final box =
          _cardKeys[i]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final mid = box.localToGlobal(Offset(0, box.size.height / 2)).dy;
      final distance = (mid - centerY).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    if (best != _active && mounted) {
      ref.read(playerControllerProvider.notifier).pause();
      setState(() => _active = best);
    }
  }

  Future<void> _toggleLike(Moment moment) async {
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final index = _items.indexWhere((item) => item.id == moment.id);
    if (index < 0) return;
    final previous = _items[index];
    final optimistic = previous.copyWith(
      liked: !previous.liked,
      likesCount: previous.liked
          ? (previous.likesCount - 1).clamp(0, 1 << 30)
          : previous.likesCount + 1,
    );
    setState(() => _items[index] = optimistic);

    try {
      final repo = ref.read(momentsRepositoryProvider);
      final saved = previous.liked
          ? await repo.unlike(previous.id)
          : await repo.like(previous.id);
      if (!mounted) return;
      setState(() => _items[index] = saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _items[index] = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).momentsLikeFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.page, top + 12, AppSpacing.page, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.navMoments,
                  style: AppTheme.displayFont(
                    fontSize: 28,
                    color: AppColors.cream,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  style: AppTheme.sans(color: AppColors.cream),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _load(reset: true),
                  decoration: InputDecoration(
                    hintText: l10n.momentsSearch,
                    hintStyle: AppTheme.sans(color: AppColors.muted),
                    filled: true,
                    fillColor: AppColors.forest,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in <(String, String)>[
                        ('latest', l10n.momentsLatest),
                        ('trending', l10n.momentsTrending),
                        ('following', l10n.momentsFollowing),
                        ('saved', l10n.momentsSaved),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(entry.$2),
                            selected: _filter == entry.$1 && _tag == null,
                            selectedColor: AppColors.gold,
                            backgroundColor: AppColors.forest,
                            labelStyle: AppTheme.sans(
                              color: _filter == entry.$1 && _tag == null
                                  ? AppColors.deep
                                  : AppColors.cream,
                              weight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _filter = entry.$1;
                                _tag = null;
                              });
                              _load(reset: true);
                            },
                          ),
                        ),
                      if (_tag != null)
                        ChoiceChip(
                          label: Text('#$_tag'),
                          selected: true,
                          selectedColor: AppColors.gold,
                          labelStyle: AppTheme.sans(
                            color: AppColors.deep,
                            weight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          onSelected: (_) {
                            setState(() => _tag = null);
                            _load(reset: true);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _body(l10n, languageCode)),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n, String languageCode) {
    if (_loading && _items.isEmpty) {
      return const _MomentsSkeleton();
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.momentsLoadFailed,
                textAlign: TextAlign.center,
                style: AppTheme.sans(color: AppColors.cream, weight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _load(reset: true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.deep,
                  minimumSize: const Size(44, 44),
                ),
                child: Text(l10n.momentsRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Text(
            _filter == 'following'
                ? l10n.momentsFollowingEmpty
                : _filter == 'saved'
                    ? l10n.momentsSavedEmpty
                    : l10n.momentsEmpty,
            textAlign: TextAlign.center,
            style: AppTheme.sans(color: AppColors.cream, weight: FontWeight.w700),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.forest,
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        key: _listKey,
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, 4, AppSpacing.page, 28),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            );
          }
          final moment = _items[index];
          return _MomentCard(
            key: _keyFor(index),
            moment: moment,
            active: widget.isActive && index == _active,
            muted: _muted,
            languageCode: languageCode,
            ayahLabel: l10n.momentsAyah,
            soundLabel: _muted ? l10n.momentsMuted : l10n.momentsSound,
            onToggleMute: () => setState(() => _muted = !_muted),
            onToggleLike: () => _toggleLike(moment),
            onToggleSave: () => _toggleSave(moment),
            onToggleFollow: moment.reciterId == null
                ? null
                : () => _toggleFollow(moment),
            onOpenComments: () => _openComments(moment),
            onTag: (tag) {
              setState(() => _tag = tag);
              _load(reset: true);
            },
            saveLabel: moment.saved ? l10n.momentsSavedLabel : l10n.momentsSave,
            followLabel: moment.followedReciter
                ? l10n.momentsFollowingLabel
                : l10n.momentsFollow,
            onOpenReciter: moment.reciterId == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReciterDetailScreen(
                          reciterId: moment.reciterId!,
                        ),
                      ),
                    );
                  },
            onOpenFollowAlong: moment.linkedRecitationId == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FollowAlongScreen(
                          recitationId: moment.linkedRecitationId!,
                        ),
                      ),
                    );
                  },
          );
        },
      ),
    );
  }
}

class _MomentsSkeleton extends StatelessWidget {
  const _MomentsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      itemCount: 2,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => Container(
        height: 420,
        decoration: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
  }
}

class _MomentCard extends StatefulWidget {
  const _MomentCard({
    super.key,
    required this.moment,
    required this.active,
    required this.muted,
    required this.languageCode,
    required this.ayahLabel,
    required this.soundLabel,
    required this.onToggleMute,
    required this.onToggleLike,
    required this.onToggleSave,
    required this.onOpenComments,
    required this.saveLabel,
    required this.onOpenReciter,
    required this.onOpenFollowAlong,
    required this.onTag,
    this.onToggleFollow,
    this.followLabel,
  });

  final Moment moment;
  final bool active;
  final bool muted;
  final String languageCode;
  final String ayahLabel;
  final String soundLabel;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleSave;
  final VoidCallback onOpenComments;
  final String saveLabel;
  final VoidCallback? onToggleFollow;
  final String? followLabel;
  final ValueChanged<String> onTag;
  final VoidCallback? onOpenReciter;
  final VoidCallback? onOpenFollowAlong;

  @override
  State<_MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<_MomentCard> {
  VideoPlayerController? _controller;
  var _ready = false;
  var _failed = false;
  var _expanded = false;
  var _heart = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) _open();
  }

  @override
  void didUpdateWidget(covariant _MomentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moment.videoUrl != widget.moment.videoUrl) {
      _close();
      if (widget.active) _open();
      return;
    }
    if (oldWidget.active != widget.active) {
      if (widget.active) {
        _open();
      } else {
        _close();
      }
    } else if (oldWidget.muted != widget.muted) {
      _controller?.setVolume(widget.muted ? 0 : 1);
    }
  }

  Future<void> _open() async {
    if (_controller != null) {
      await _play();
      return;
    }
    final url = widget.moment.videoUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.muted ? 0 : 1);
      if (!mounted || !widget.active) {
        await controller.pause();
        return;
      }
      setState(() => _ready = true);
      await controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  Future<void> _play() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.setVolume(widget.muted ? 0 : 1);
    if (widget.active) {
      await controller.play();
    } else {
      await controller.pause();
    }
  }

  void _close() {
    _controller?.dispose();
    _controller = null;
    _ready = false;
    _failed = false;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  Future<void> _onDoubleTap() async {
    widget.onToggleLike();
    setState(() => _heart = true);
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (mounted) setState(() => _heart = false);
  }

  @override
  Widget build(BuildContext context) {
    final moment = widget.moment;
    final reciterName = moment.reciter?.localizedName(widget.languageCode) ?? '';
    final headline = reciterName.isNotEmpty ? reciterName : (moment.title ?? '').trim();
    final surahLabel = moment.surah == null
        ? null
        : moment.ayahNumber == null
            ? moment.surah!.localizedName(widget.languageCode)
            : '${moment.surah!.localizedName(widget.languageCode)} · ${moment.ayahNumber}';
    final aspect = momentFrameAspect(moment.width, moment.height);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.forestSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (headline.isNotEmpty)
              InkWell(
                onTap: widget.onOpenReciter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    headline,
                    style: AppTheme.sans(
                      fontSize: 15,
                      color: AppColors.cream,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: aspect,
                child: GestureDetector(
                  onTap: () {
                    final controller = _controller;
                    if (controller == null || !_ready) return;
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                    setState(() {});
                  },
                  onDoubleTap: _onDoubleTap,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: AppColors.deep),
                      if (_ready && _controller != null)
                        FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      else if (moment.posterUrl != null)
                        CachedNetworkImage(
                          imageUrl: moment.posterUrl!,
                          fit: BoxFit.contain,
                        ),
                      if (widget.active && !_ready && !_failed)
                        const Center(
                          child: CircularProgressIndicator(color: AppColors.gold),
                        ),
                      if (_failed)
                        const Center(
                          child: Icon(Icons.error_outline, color: AppColors.cream),
                        ),
                      if (_heart)
                        const Center(
                          child: Icon(Icons.favorite, color: AppColors.gold, size: 72),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Action(
                  icon: moment.liked ? Icons.favorite : Icons.favorite_border,
                  color: moment.liked ? AppColors.gold : AppColors.cream,
                  label: '${moment.likesCount}',
                  onTap: widget.onToggleLike,
                ),
                const SizedBox(width: 8),
                _Action(
                  icon: moment.saved ? Icons.bookmark : Icons.bookmark_border,
                  color: moment.saved ? AppColors.gold : AppColors.cream,
                  label: widget.saveLabel,
                  onTap: widget.onToggleSave,
                ),
                const SizedBox(width: 8),
                _Action(
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.cream,
                  label: '${moment.commentsCount}',
                  onTap: widget.onOpenComments,
                ),
                if (widget.onToggleFollow != null) ...[
                  const SizedBox(width: 8),
                  _Action(
                    icon: moment.followedReciter
                        ? Icons.person
                        : Icons.person_add_alt_1,
                    color: moment.followedReciter ? AppColors.gold : AppColors.cream,
                    label: widget.followLabel ?? '',
                    onTap: widget.onToggleFollow!,
                  ),
                ],
                const SizedBox(width: 8),
                _Action(
                  icon: widget.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: AppColors.cream,
                  label: widget.soundLabel,
                  onTap: widget.onToggleMute,
                ),
                if (widget.onOpenFollowAlong != null) ...[
                  const SizedBox(width: 8),
                  _Action(
                    icon: Icons.menu_book_rounded,
                    color: AppColors.gold,
                    label: widget.ayahLabel,
                    onTap: widget.onOpenFollowAlong!,
                  ),
                ],
              ],
            ),
            if ((moment.title ?? '').isNotEmpty && headline != moment.title) ...[
              const SizedBox(height: 8),
              Text(
                moment.title!,
                style: AppTheme.sans(
                  fontSize: 13,
                  color: AppColors.goldLight,
                  weight: FontWeight.w700,
                ),
              ),
            ],
            if ((moment.caption ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  moment.caption!,
                  maxLines: _expanded ? null : 3,
                  overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: AppTheme.sans(
                    color: AppColors.cream.withValues(alpha: 0.92),
                    weight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            if (moment.hashtags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final tag in moment.hashtags)
                    GestureDetector(
                      onTap: () => widget.onTag(tag),
                      child: Text(
                        '#$tag',
                        style: AppTheme.sans(
                          color: AppColors.gold,
                          weight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (surahLabel != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: widget.onOpenFollowAlong ?? widget.onOpenReciter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.deep.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    surahLabel,
                    style: AppTheme.sans(
                      fontSize: 12,
                      color: AppColors.cream,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTheme.sans(
                  fontSize: 11,
                  color: AppColors.cream,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.momentId});

  final int momentId;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _body = TextEditingController();
  List<MomentComment> _comments = const [];
  var _loading = true;
  var _delta = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items =
          await ref.read(momentsRepositoryProvider).comments(widget.momentId);
      if (!mounted) return;
      setState(() {
        _comments = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _body.text.trim();
    if (text.isEmpty) return;
    if (!ref.read(authControllerProvider).isAuthenticated) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      return;
    }
    try {
      final created = await ref
          .read(momentsRepositoryProvider)
          .addComment(widget.momentId, text);
      if (!mounted) return;
      setState(() {
        _comments = [created, ..._comments];
        _delta += 1;
        _body.clear();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).momentsCommentFailed),
        ),
      );
    }
  }

  Future<void> _delete(MomentComment comment) async {
    try {
      await ref
          .read(momentsRepositoryProvider)
          .deleteComment(widget.momentId, comment.id);
      if (!mounted) return;
      setState(() {
        _comments = _comments.where((item) => item.id != comment.id).toList();
        _delta -= 1;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).momentsCommentFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SizedBox(
          height: 420,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.momentsComment,
                        style: AppTheme.displayFont(fontSize: 22),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(_delta),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const QaariLoadingSkeleton()
                    : _comments.isEmpty
                        ? Center(child: Text(l10n.momentsCommentEmpty))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _comments.length,
                            separatorBuilder: (_, _) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: AppTheme.sans(weight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(comment.body),
                                      ],
                                    ),
                                  ),
                                  if (comment.mine)
                                    IconButton(
                                      onPressed: () => _delete(comment),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                ],
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _body,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: l10n.momentsCommentHint,
                          counterText: '',
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _send,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.deep,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(l10n.momentsSend),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
