import 'package:flutter/material.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/features/favorites/favorites_screen.dart';
import 'package:qaari_sl_mobile/features/home/home_screen.dart';
import 'package:qaari_sl_mobile/features/player/mini_player_bar.dart';
import 'package:qaari_sl_mobile/features/playlists/playlists_screen.dart';
import 'package:qaari_sl_mobile/features/settings/settings_screen.dart';

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
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.favorite_rounded, 'Favorites'),
    (Icons.queue_music_rounded, 'Playlists'),
    (Icons.settings_rounded, 'Settings'),
  ];

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
          for (var i = 0; i < _items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 13),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _items[i].$1,
                        size: 21,
                        color: i == index
                            ? AppColors.forest
                            : AppColors.mutedSoft,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _items[i].$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              i == index ? FontWeight.w800 : FontWeight.w500,
                          color: i == index
                              ? AppColors.forest
                              : AppColors.mutedSoft,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: i == index ? 18 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(2),
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
