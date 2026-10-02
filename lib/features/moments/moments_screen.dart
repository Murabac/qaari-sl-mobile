import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/data/moments_repository.dart';
import 'package:qaari_sl_mobile/core/models/moment.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
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
  final _pageController = PageController();
  var _page = 0;
  var _muted = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

    try {
      final repo = ref.read(momentsRepositoryProvider);
      if (moment.liked) {
        await repo.unlike(moment.id);
      } else {
        await repo.like(moment.id);
      }
      ref.invalidate(momentsFeedProvider);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update like')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(momentsFeedProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.deep,
      body: async.when(
        loading: () => SafeArea(
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ),
        error: (error, _) => SafeArea(
          child: AsyncBody(
            isLoading: false,
            error: error,
            isEmpty: false,
            onRetry: () => ref.invalidate(momentsFeedProvider),
            child: const SizedBox.shrink(),
          ),
        ),
        data: (moments) {
          if (moments.isEmpty) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.momentsEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: moments.length,
                      onPageChanged: (index) {
                        setState(() => _page = index);
                        ref.read(playerControllerProvider.notifier).pause();
                      },
                      itemBuilder: (context, index) {
                        final moment = moments[index];
                        return _MomentPage(
                          moment: moment,
                          active: widget.isActive && index == _page,
                          muted: _muted,
                          languageCode: languageCode,
                          onToggleMute: () =>
                              setState(() => _muted = !_muted),
                          onToggleLike: () => _toggleLike(moment),
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
                                        recitationId:
                                            moment.linkedRecitationId!,
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                    Positioned(
                      left: 16,
                      top: 8,
                      right: 16,
                      child: Text(
                        l10n.navMoments,
                        style: AppTheme.displayFont(
                          fontSize: 22,
                          color: AppColors.cream,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
          );
        },
      ),
    );
  }
}

class _MomentPage extends StatefulWidget {
  const _MomentPage({
    required this.moment,
    required this.active,
    required this.muted,
    required this.languageCode,
    required this.onToggleMute,
    required this.onToggleLike,
    required this.onOpenReciter,
    required this.onOpenFollowAlong,
  });

  final Moment moment;
  final bool active;
  final bool muted;
  final String languageCode;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLike;
  final VoidCallback? onOpenReciter;
  final VoidCallback? onOpenFollowAlong;

  @override
  State<_MomentPage> createState() => _MomentPageState();
}

class _MomentPageState extends State<_MomentPage> {
  VideoPlayerController? _controller;
  var _ready = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _MomentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active || oldWidget.muted != widget.muted) {
      _syncPlayback();
    }
    if (oldWidget.moment.videoUrl != widget.moment.videoUrl) {
      _disposeController();
      _init();
    }
  }

  Future<void> _init() async {
    final url = widget.moment.videoUrl;
    if (url == null || url.isEmpty) {
      setState(() => _failed = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.muted ? 0 : 1);
      if (!mounted) return;
      setState(() => _ready = true);
      _syncPlayback();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !_ready) return;
    await controller.setVolume(widget.muted ? 0 : 1);
    if (widget.active) {
      await controller.play();
    } else {
      await controller.pause();
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _ready = false;
    _failed = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moment = widget.moment;
    final reciterName =
        moment.reciter?.localizedName(widget.languageCode) ?? '';
    final headline = reciterName.isNotEmpty
        ? reciterName
        : (moment.title ?? '').trim();
    final surahLabel = moment.surah == null
        ? null
        : moment.ayahNumber == null
            ? moment.surah!.localizedName(widget.languageCode)
            : '${moment.surah!.localizedName(widget.languageCode)} · ${moment.ayahNumber}';

    return GestureDetector(
      onTap: () {
        if (!widget.active) return;
        final c = _controller;
        if (c == null || !_ready) return;
        if (c.value.isPlaying) {
          c.pause();
        } else {
          c.play();
        }
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.deep),
          if (_ready && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else if (moment.posterUrl != null)
            CachedNetworkImage(
              imageUrl: moment.posterUrl!,
              fit: BoxFit.cover,
            ),
          if (!_ready && !_failed)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          if (_failed)
            const Center(
              child: Icon(Icons.error_outline, color: AppColors.cream, size: 40),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x99062423),
                  Color(0xE0062423),
                ],
                stops: [0.45, 0.75, 1],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 72,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (headline.isNotEmpty)
                  InkWell(
                    onTap: widget.onOpenReciter,
                    child: Text(
                      headline,
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                if ((moment.title ?? '').isNotEmpty &&
                    headline != moment.title) ...[
                  const SizedBox(height: 6),
                  Text(
                    moment.title!,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
                if ((moment.caption ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    moment.caption!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.cream.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
                if (surahLabel != null) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: widget.onOpenFollowAlong ?? widget.onOpenReciter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        surahLabel,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 36,
            child: Column(
              children: [
                _SideAction(
                  icon: moment.liked ? Icons.favorite : Icons.favorite_border,
                  color: moment.liked ? Colors.redAccent : AppColors.cream,
                  label: '${moment.likesCount}',
                  onTap: widget.onToggleLike,
                ),
                const SizedBox(height: 18),
                _SideAction(
                  icon: widget.muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: AppColors.cream,
                  label: widget.muted ? 'Muted' : 'Sound',
                  onTap: widget.onToggleMute,
                ),
                if (widget.onOpenFollowAlong != null) ...[
                  const SizedBox(height: 18),
                  _SideAction(
                    icon: Icons.menu_book_rounded,
                    color: AppColors.gold,
                    label: 'Text',
                    onTap: widget.onOpenFollowAlong!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
