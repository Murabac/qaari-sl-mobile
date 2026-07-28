import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaari_sl_mobile/app/app.dart';

void main() {
  testWidgets('Qaari SL app boots to splash', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QaariSlApp()));
    expect(find.text('Qaari SL'), findsOneWidget);

    // Complete splash navigation timer so no pending timers remain.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Reciters will appear here'), findsOneWidget);
  });
}
