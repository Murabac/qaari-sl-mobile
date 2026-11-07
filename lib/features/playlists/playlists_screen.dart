import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/auth/auth_controller.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/models/playlist.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';
import 'package:qaari_sl_mobile/features/playlists/playlist_detail_screen.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final asyncPlaylists = ref.watch(playlistsProvider);

    return Column(
      children: [
        ForestPageHeader(
          eyebrow: 'Your Collections',
          title: 'Playlists',
          subtitle: auth.isAuthenticated
              ? asyncPlaylists.maybeWhen(
                  data: (list) =>
                      '${list.length} collection${list.length == 1 ? '' : 's'}',
                  orElse: () => 'Your collections',
                )
              : 'Sign in to create playlists',
          trailing: auth.isAuthenticated
              ? FilledButton.icon(
                  onPressed: () => _createPlaylist(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.forest,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'New',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                )
              : null,
        ),
        Expanded(
          child: ColoredBox(
            color: AppColors.cream,
            child: !auth.isAuthenticated
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.queue_music_outlined,
                          size: 52,
                          color: AppColors.gold.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Log in to create playlists',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.forest,
                          ),
                          child: const Text('Log in'),
                        ),
                      ],
                    ),
                  )
                : asyncPlaylists.when(
                    loading: () => const QaariLoadingSkeleton(),
                    error: (error, _) => AsyncBody(
                      isLoading: false,
                      error: error,
                      isEmpty: false,
                      onRetry: () => ref.invalidate(playlistsProvider),
                      child: const SizedBox.shrink(),
                    ),
                    data: (playlists) {
                      if (playlists.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'No playlists yet',
                                style: TextStyle(color: AppColors.muted),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () => _createPlaylist(context, ref),
                                icon: const Icon(Icons.add),
                                label: const Text('Create playlist'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: AppColors.forest,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.gold,
                        onRefresh: () async =>
                            ref.invalidate(playlistsProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                          itemCount: playlists.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final playlist = playlists[index];
                            return _PlaylistCard(
                              playlist: playlist,
                              onOpen: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PlaylistDetailScreen(
                                      playlistId: playlist.id,
                                    ),
                                  ),
                                );
                              },
                              onRename: () =>
                                  _renamePlaylist(context, ref, playlist),
                              onDelete: () =>
                                  _deletePlaylist(context, ref, playlist),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.playlist,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final Playlist playlist;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final preview = playlist.items
        .where((item) => item.recitation?.surah != null)
        .take(3)
        .toList();

    return Material(
      color: AppColors.creamCard,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.forest.withValues(alpha: 0.09),
                blurRadius: 16,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                color: AppColors.forest,
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.queue_music_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: const TextStyle(
                              color: AppColors.cream,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${playlist.itemsCount} tracks',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.cream,
                      ),
                      onSelected: (value) {
                        if (value == 'rename') onRename();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ),
              for (final item in preview)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.cream)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${item.recitation!.surah!.number}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.recitation!.surah!.nameEnglish,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        item.recitation!.surah!.nameArabic,
                        style: AppTheme.amiri(
                          fontSize: 14,
                          color: AppColors.muted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              if (playlist.itemsCount > preview.length)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.cream)),
                  ),
                  child: Text(
                    '+${playlist.itemsCount - preview.length} more tracks',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
  final name = await _promptName(context, title: 'New playlist');
  if (name == null || name.trim().isEmpty) return;
  await ref.read(libraryRepositoryProvider).createPlaylist(name);
  ref.invalidate(playlistsProvider);
}

Future<void> _renamePlaylist(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  final name = await _promptName(
    context,
    title: 'Rename playlist',
    initial: playlist.name,
  );
  if (name == null || name.trim().isEmpty) return;
  await ref.read(libraryRepositoryProvider).renamePlaylist(playlist.id, name);
  ref.invalidate(playlistsProvider);
}

Future<void> _deletePlaylist(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete playlist?'),
      content: Text('Remove "${playlist.name}" permanently?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(libraryRepositoryProvider).deletePlaylist(playlist.id);
  ref.invalidate(playlistsProvider);
}

Future<String?> _promptName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
