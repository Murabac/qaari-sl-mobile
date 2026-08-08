import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/core/models/recitation.dart';
import 'package:qaari_sl_mobile/core/theme/app_colors.dart';
import 'package:qaari_sl_mobile/features/downloads/offline_download_service.dart';
import 'package:qaari_sl_mobile/l10n/app_localizations.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final downloads = ref.watch(offlineDownloadsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.cream,
        title: Text(l10n.offlineDownloads),
        actions: [
          if (downloads.isNotEmpty)
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.clearAllDownloads),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.clearAllDownloads),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(offlineDownloadsProvider.notifier).clearAll();
                }
              },
              child: Text(
                l10n.clearAllDownloads,
                style: const TextStyle(color: AppColors.gold, fontSize: 12),
              ),
            ),
        ],
      ),
      body: downloads.isEmpty
          ? Center(
              child: Text(
                l10n.noDownloadsYet,
                style: const TextStyle(color: AppColors.muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              itemCount: downloads.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final track = downloads[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.creamCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.download_done_rounded,
                          color: AppColors.gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              track.reciterName,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _sizeLabel(track.fileSize),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.removeDownload,
                        onPressed: () => ref
                            .read(offlineDownloadsProvider.notifier)
                            .remove(track.recitationId),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _sizeLabel(int bytes) {
    if (bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
}

class DownloadActionButton extends ConsumerStatefulWidget {
  const DownloadActionButton({super.key, required this.recitation});

  final Recitation recitation;

  @override
  ConsumerState<DownloadActionButton> createState() =>
      _DownloadActionButtonState();
}

class _DownloadActionButtonState extends ConsumerState<DownloadActionButton> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final downloads = ref.watch(offlineDownloadsProvider);
    final saved =
        downloads.any((t) => t.recitationId == widget.recitation.id);

    if (_busy) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.gold,
          ),
        ),
      );
    }

    return IconButton(
      tooltip: saved ? l10n.removeDownload : l10n.download,
      visualDensity: VisualDensity.compact,
      onPressed: () async {
        setState(() => _busy = true);
        try {
          final controller = ref.read(offlineDownloadsProvider.notifier);
          if (saved) {
            await controller.remove(widget.recitation.id);
          } else {
            await controller.download(widget.recitation);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.downloaded)),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$e')),
            );
          }
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      },
      icon: Icon(
        saved ? Icons.download_done_rounded : Icons.download_rounded,
        color: AppColors.gold,
        size: 20,
      ),
    );
  }
}
