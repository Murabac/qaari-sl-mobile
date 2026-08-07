class StoryPerson {
  const StoryPerson({
    required this.id,
    required this.name,
    required this.title,
    this.photoUrl,
    this.tier,
    this.tierLabel,
    this.description,
  });

  final int id;
  final String name;
  final String title;
  final String? photoUrl;
  final String? tier;
  final String? tierLabel;
  final String? description;

  factory StoryPerson.leader(Map<String, dynamic> json) {
    return StoryPerson(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      tier: json['tier'] as String?,
      tierLabel: json['tier_label'] as String?,
    );
  }

  factory StoryPerson.team(Map<String, dynamic> json) {
    return StoryPerson(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      title: (json['role'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      description: json['description'] as String?,
    );
  }
}

class StoryPayload {
  const StoryPayload({
    required this.heroMission,
    required this.closingNote,
    required this.president,
    required this.ministers,
    required this.board,
    required this.team,
  });

  final String heroMission;
  final String closingNote;
  final List<StoryPerson> president;
  final List<StoryPerson> ministers;
  final List<StoryPerson> board;
  final List<StoryPerson> team;

  factory StoryPayload.fromJson(Map<String, dynamic> json) {
    List<StoryPerson> leaders(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(StoryPerson.leader)
          .toList();
    }

    final teamRaw = json['team'];
    return StoryPayload(
      heroMission: (json['hero_mission'] as String?) ?? '',
      closingNote: (json['closing_note'] as String?) ?? '',
      president: leaders('president'),
      ministers: leaders('ministers'),
      board: leaders('board'),
      team: teamRaw is List
          ? teamRaw
              .whereType<Map<String, dynamic>>()
              .map(StoryPerson.team)
              .toList()
          : const [],
    );
  }
}
