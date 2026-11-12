import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';
import 'package:qaari_sl_mobile/core/theme/app_palette.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/favorites/favorites_screen.dart';
import 'package:qaari_sl_mobile/features/home/home_screen.dart';
import 'package:qaari_sl_mobile/features/moments/moments_screen.dart';
import 'package:qaari_sl_mobile/features/player/mini_player_bar.dart';
import 'package:qaari_sl_mobile/features/player/player_controller.dart';
import 'package:qaari_sl_mobile/features/playlists/playlists_screen.dart';
import 'package:qaari_sl_mobile/features/settings/settings_screen.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  List<Widget> get _pages => [
    const HomeScreen(),
    if (AppFeatures.moments) MomentsScreen(isActive: _index == 1),
    const FavoritesScreen(),
    const PlaylistsScreen(),
    const SettingsScreen(),
  ];

  void _onTabChanged(int value) {
    if (AppFeatures.moments && value == 1) {
      ref.read(playerControllerProvider.notifier).pause();
    }
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final player = ref.watch(playerControllerProvider);
    final showPlayer = player.current != null;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final navBottom = ShellMetrics.navBottom(safeBottom);
    final items = [
      (Icons.home_outlined, l10n.navHome),
      if (AppFeatures.moments) (Icons.auto_awesome_outlined, l10n.navMoments),
      (Icons.favorite_border_rounded, l10n.navFavorites),
      (Icons.queue_music_outlined, l10n.navPlaylists),
      (Icons.tune_rounded, l10n.navSettings),
    ];

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _pages),
          Positioned(
            left: ShellMetrics.side,
            right: ShellMetrics.side,
            bottom: navBottom,
            child: _FloatingNav(
              index: _index,
              items: items,
              onChanged: _onTabChanged,
            ),
          ),
          if (showPlayer)
            Positioned(
              left: ShellMetrics.side,
              right: ShellMetrics.side,
              bottom: navBottom + ShellMetrics.navHeight + ShellMetrics.gap,
              child: const MiniPlayerBar(),
            ),
        ],
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.index,
    required this.items,
    required this.onChanged,
  });

  final int index;
  final List<(IconData, String)> items;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.navGlass,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: palette.line),
            ),
            child: SizedBox(
              height: ShellMetrics.navHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      i == index
                          ? Flexible(
                              child: _NavItem(
                                icon: items[i].$1,
                                label: items[i].$2,
                                active: true,
                                onTap: () => onChanged(i),
                              ),
                            )
                          : _NavItem(
                              icon: items[i].$1,
                              label: items[i].$2,
                              active: false,
                              onTap: () => onChanged(i),
                            ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = active ? palette.onPrimary : palette.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: active ? null : 56,
        height: 48,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: active ? 14 : 0),
        decoration: BoxDecoration(
          color: active ? palette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            if (active) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sans(
                    fontSize: 13,
                    color: color,
                    weight: FontWeight.w600,
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
