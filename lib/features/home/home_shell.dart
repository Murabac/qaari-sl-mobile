import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
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

  bool get _onMoments => _index == 1;

  List<Widget> get _pages => [
        const HomeScreen(),
        MomentsScreen(isActive: _onMoments),
        const FavoritesScreen(),
        const PlaylistsScreen(),
        const SettingsScreen(),
      ];

  void _onTabChanged(int value) {
    if (value == 1) {
      ref.read(playerControllerProvider.notifier).pause();
    }
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (Icons.home_outlined, l10n.navHome),
      (Icons.auto_awesome_outlined, l10n.navMoments),
      (Icons.favorite_border_rounded, l10n.navFavorites),
      (Icons.queue_music_outlined, l10n.navPlaylists),
      (Icons.settings_outlined, l10n.navSettings),
    ];

    return Scaffold(
      backgroundColor: _onMoments ? AppColors.deep : AppColors.cream,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_onMoments) const MiniPlayerBar(),
          _QaariBottomNav(
            index: _index,
            items: items,
            dark: _onMoments,
            onChanged: _onTabChanged,
          ),
        ],
      ),
    );
  }
}

class _QaariBottomNav extends StatelessWidget {
  const _QaariBottomNav({
    required this.index,
    required this.items,
    required this.dark,
    required this.onChanged,
  });

  final int index;
  final List<(IconData, String)> items;
  final bool dark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: dark
                ? AppColors.deep.withValues(alpha: 0.94)
                : AppColors.creamCard.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: dark
                    ? AppColors.forestSoft.withValues(alpha: 0.55)
                    : AppColors.border,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onChanged(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: i == 1 ? 42 : 36,
                            height: 28,
                            decoration: BoxDecoration(
                              color: i == index && i == 1
                                  ? const Color(0xFFE5B54F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              items[i].$1,
                              size: 18,
                              color: i == index
                                  ? (i == 1
                                      ? AppColors.deep
                                      : (dark
                                          ? AppColors.goldLight
                                          : AppColors.ink))
                                  : (dark
                                      ? AppColors.mutedOnDark
                                      : AppColors.muted),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.sans(
                              fontSize: 10,
                              weight:
                                  i == index ? FontWeight.w700 : FontWeight.w600,
                              color: i == index
                                  ? (dark ? AppColors.goldLight : AppColors.ink)
                                  : (dark
                                      ? AppColors.mutedOnDark
                                      : AppColors.muted),
                            ),
                          ),
                          if (i == index && i != 1)
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              width: 18,
                              height: 2,
                              decoration: BoxDecoration(
                                color: dark ? AppColors.goldLight : const Color(0xFFB88E2D),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
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
