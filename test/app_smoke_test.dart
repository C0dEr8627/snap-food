import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snap_foodd/app/app.dart';

void main() {
  testWidgets('Snap Foodd splash and welcome screen boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SnapFoodApp()));
    await tester.pumpAndSettle();

    expect(find.text('SNAP FOODD'), findsOneWidget);
    expect(find.text('GOOD FOOD.\nFAST DELIVERY.'), findsOneWidget);
    expect(find.text('Explore food'), findsOneWidget);
    expect(find.textContaining('Already have an account?'), findsOneWidget);
    expect(find.text('Made for Mumbai'), findsOneWidget);

    await tester.tap(find.text('Explore food'));
    await tester.pumpAndSettle();

    expect(find.text('GOOD FOOD.\nFAST DELIVERY.'), findsOneWidget);
  });
}
