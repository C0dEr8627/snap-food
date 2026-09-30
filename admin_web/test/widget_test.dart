import 'package:flutter_test/flutter_test.dart';
import 'package:snap_foodd_admin_web/main.dart';

void main() {
  testWidgets('renders branded admin dashboard and navigation', (tester) async {
    await tester.setViewportSize(const Size(1440, 1000));
    await tester.pumpWidget(const SnapFooddAdminApp());

    expect(find.text('Snap Foodd'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Orders today'), findsOneWidget);
    expect(find.text('Sales overview'), findsOneWidget);
    expect(find.text('Preview mode'), findsOneWidget);

    await tester.tap(find.text('Orders').first);
    await tester.pumpAndSettle();
    expect(find.text('Track every order from checkout to delivery.'), findsOneWidget);
    expect(find.text('#SF-1048'), findsOneWidget);
  });

  testWidgets('catalogue section displays products and category filter', (tester) async {
    await tester.setViewportSize(const Size(1440, 1000));
    await tester.pumpWidget(const SnapFooddAdminApp());

    await tester.tap(find.text('Catalogue').first);
    await tester.pumpAndSettle();
    expect(find.text('Classic Veg Burger'), findsOneWidget);
    expect(find.text('Chocolate Brownie'), findsOneWidget);
  });
}
