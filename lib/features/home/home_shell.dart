import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/features/favorites/favorites_screen.dart';
import 'package:qaari_sl_mobile/features/home/home_screen.dart';
import 'package:qaari_sl_mobile/features/player/mini_player_bar.dart';
import 'package:qaari_sl_mobile/features/playlists/playlists_screen.dart';
import 'package:qaari_sl_mobile/features/settings/settings_screen.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    FavoritesScreen(),
    PlaylistsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (Icons.home_rounded, l10n.navHome),
      (Icons.favorite_rounded, l10n.navFavorites),
      (Icons.queue_music_rounded, l10n.navPlaylists),
      (Icons.settings_rounded, l10n.navSettings),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          _QaariBottomNav(
            index: _index,
            items: items,
            onChanged: (value) => setState(() => _index = value),
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
    required this.onChanged,
  });

  final int index;
  final List<(IconData, String)> items;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.creamCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 13),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].$1,
                        color: i == index ? AppColors.forest : AppColors.muted,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              i == index ? FontWeight.w800 : FontWeight.w600,
                          color:
                              i == index ? AppColors.forest : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
