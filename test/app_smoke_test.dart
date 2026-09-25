import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snap_food/app/app.dart';

void main() {
  testWidgets('Snap Food splash and welcome screen boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SnapFoodApp()));
    await tester.pumpAndSettle();

    expect(find.text('4.9 Rating by 1,20,000+ Mumbai foodies'), findsOneWidget);
    expect(find.text('SNAP FOOD'), findsOneWidget);
    expect(find.text('Lightning Fast Delivery'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.textContaining('Already have an account?'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Good afternoon, Alex! 🍕'), findsOneWidget);
    expect(find.text('Explore Cravings'), findsOneWidget);
    expect(find.text('Featured Champions'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
