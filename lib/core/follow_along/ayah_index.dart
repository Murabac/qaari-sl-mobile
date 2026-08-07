/// Mirrors the web Alpine `syncAyah` logic.
///
/// Returns the 0-based ayah index for [positionSeconds], or `-1` when
/// timed starts exist and playback is still before the first ayah.
int ayahIndexFromStarts({
  required double positionSeconds,
  required List<double> ayahStarts,
  required int verseCount,
  required double durationSeconds,
}) {
  if (ayahStarts.isNotEmpty && durationSeconds > 0) {
    final t = positionSeconds + 0.01;
    if (t < ayahStarts.first) {
      return -1;
    }
    var index = 0;
    for (var i = 0; i < ayahStarts.length; i++) {
      if (t >= ayahStarts[i]) {
        index = i;
      }
    }
    return index;
  }

  final count = verseCount > 0 ? verseCount : 0;
  if (count == 0 || durationSeconds <= 0) {
    return 0;
  }

  final index = (positionSeconds / durationSeconds * count).floor();
  return index.clamp(0, count - 1);
}
