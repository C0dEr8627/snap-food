import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snap_food/app/app.dart';

void main() {
  testWidgets('Snap Food app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SnapFoodApp()));
    await tester.pumpAndSettle();
    expect(find.text('Snap Food'), findsOneWidget);
    expect(find.text('Frontend foundation is ready.'), findsOneWidget);
  });
}
