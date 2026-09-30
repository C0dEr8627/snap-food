import 'package:flutter_test/flutter_test.dart';
import 'package:snap_foodd_admin_web/main.dart';

void main() {
  testWidgets('shows the admin setup scaffold', (tester) async {
    await tester.pumpWidget(const SnapFooddAdminApp());

    expect(find.text('Snap Foodd Admin'), findsOneWidget);
    expect(find.textContaining('Admin Web setup scaffold'), findsOneWidget);
  });
}
