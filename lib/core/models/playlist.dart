import 'package:qaari_sl_mobile/core/models/recitation.dart';

class PlaylistItem {
  const PlaylistItem({
    required this.id,
    required this.sortOrder,
    this.recitation,
  });

  final int id;
  final int sortOrder;
  final Recitation? recitation;

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: (json['id'] as num).toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      recitation: json['recitation'] is Map<String, dynamic>
          ? Recitation.fromJson(json['recitation'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    this.itemsCount = 0,
    this.items = const [],
  });

  final int id;
  final String name;
  final int itemsCount;
  final List<PlaylistItem> items;

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return Playlist(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      itemsCount: (json['items_count'] as num?)?.toInt() ??
          (rawItems is List ? rawItems.length : 0),
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(PlaylistItem.fromJson)
              .toList()
          : const [],
    );
  }

  Playlist copyWith({
    String? name,
    int? itemsCount,
    List<PlaylistItem>? items,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      itemsCount: itemsCount ?? this.itemsCount,
      items: items ?? this.items,
    );
  }
}
