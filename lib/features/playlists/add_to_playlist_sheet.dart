import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/features/auth/login_screen.dart';

Future<void> showAddToPlaylistSheet(
  BuildContext context,
  WidgetRef ref, {
  required int recitationId,
}) async {
  final loggedIn = await ensureLoggedIn(context, ref);
  if (!loggedIn || !context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final asyncPlaylists = ref.watch(playlistsProvider);
          return SafeArea(
            child: asyncPlaylists.when(
              loading: () => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load playlists: $error'),
              ),
              data: (playlists) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      title: Text(
                        'Add to playlist',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (playlists.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Create a playlist first'),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final playlist = playlists[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.queue_music_rounded,
                                color: AppColors.forest,
                              ),
                              title: Text(playlist.name),
                              subtitle: Text('${playlist.itemsCount} tracks'),
                              onTap: () async {
                                await ref
                                    .read(libraryRepositoryProvider)
                                    .addPlaylistItem(
                                      playlistId: playlist.id,
                                      recitationId: recitationId,
                                    );
                                ref.invalidate(playlistsProvider);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added to ${playlist.name}',
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}
