import 'package:flutter_test/flutter_test.dart';
import 'package:qaari_sl_mobile/core/theme/app_metrics.dart';

void main() {
  test('moment frames keep portrait and landscape shape', () {
    expect(momentFrameAspect(null, null), 4 / 5);
    expect(momentFrameAspect(0, 1920), 4 / 5);
    expect(momentFrameAspect(1080, 1920), closeTo(9 / 16, 0.0001));
    expect(momentFrameAspect(1920, 1080), closeTo(16 / 9, 0.0001));
    expect(momentFrameAspect(100, 4000), closeTo(9 / 16, 0.0001));
    expect(momentFrameAspect(4000, 100), closeTo(16 / 9, 0.0001));
  });
}
