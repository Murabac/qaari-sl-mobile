import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/constants/app_constants.dart';
import 'package:qaari_sl_mobile/core/data/library_repository.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/core/theme/app_theme.dart';
import 'package:qaari_sl_mobile/features/player/open_player.dart';
import 'package:qaari_sl_mobile/shared/widgets/widgets.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final int playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPlaylist = ref.watch(playlistDetailProvider(playlistId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: asyncPlaylist.maybeWhen(
          data: (playlist) => Text(playlist.name),
          orElse: () => const Text('Playlist'),
        ),
      ),
      body: asyncPlaylist.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (error, _) => AsyncBody(
          isLoading: false,
          error: error,
          isEmpty: false,
          onRetry: () => ref.invalidate(playlistDetailProvider(playlistId)),
          child: const SizedBox.shrink(),
        ),
        data: (playlist) {
          final items = playlist.items
              .where((item) => item.recitation != null)
              .toList();
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No tracks in this playlist',
                style: TextStyle(color: AppColors.muted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final track = item.recitation!;
              final title = track.surah == null
                  ? 'Surah ${track.surahId}'
                  : track.surah!.localizedName(languageCode);
              final nameAr = track.surah?.nameArabic ?? '';
              final number = track.surah?.number ?? track.surahId;

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.creamCard,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppColors.cardShadow,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: nameAr.isEmpty
                      ? Text(track.reciterName ?? AppConstants.appName)
                      : Text(
                          nameAr,
                          style: AppTheme.amiri(
                            fontSize: 15,
                            color: AppColors.muted,
                            height: 1.2,
                          ),
                        ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () async {
                      await ref
                          .read(libraryRepositoryProvider)
                          .removePlaylistItem(
                            playlistId: playlistId,
                            itemId: item.id,
                          );
                      ref.invalidate(playlistDetailProvider(playlistId));
                      ref.invalidate(playlistsProvider);
                    },
                  ),
                  onTap: () => openPlayerAndPlay(
                        context,
                        ref,
                        track,
                        queue: items
                            .map((item) => item.recitation!)
                            .toList(),
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
