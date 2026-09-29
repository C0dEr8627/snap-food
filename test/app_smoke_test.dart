import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snap_foodd/app/app.dart';

void main() {
  testWidgets('Snap Foodd splash and welcome screen boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SnapFoodApp()));

    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.textContaining('GOOD FOOD.'), findsOneWidget);
    expect(find.textContaining('FAST DELIVERY.'), findsOneWidget);
    expect(find.text('Explore food'), findsOneWidget);
    expect(find.textContaining('Already have an account?'), findsOneWidget);
    expect(find.text('Made for Mumbai'), findsOneWidget);

    await tester.tap(find.text('Explore food'));
    await tester.pumpAndSettle();

    expect(find.textContaining('GOOD FOOD.'), findsOneWidget);
    expect(find.textContaining('FAST DELIVERY.'), findsOneWidget);
  });
}
