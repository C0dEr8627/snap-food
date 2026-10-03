import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_foodd/design_system/components/snap_food_commerce.dart';
import 'package:snap_foodd/design_system/components/snap_food_inputs.dart';

void main() {
  group('SnapFilterChip', () {
    testWidgets('reports the inverse selected state when tapped', (tester) async {
      bool? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SnapFilterChip(
              label: 'Vegetarian',
              selected: false,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Vegetarian'));
      expect(selectedValue, isTrue);
    });

    testWidgets('keeps a minimum 48px touch target', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SnapFilterChip(
              label: 'Popular',
              selected: true,
              onSelected: _ignoreSelection,
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SnapFilterChip)).height, greaterThanOrEqualTo(48));
    });
  });

  testWidgets('SnapCategoryChip invokes selection callback', (tester) async {
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SnapCategoryChip(
            label: 'Desserts',
            selected: false,
            onSelected: () => selected = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Desserts'));
    expect(selected, isTrue);
  });

  group('SnapQuantityStepper', () {
    testWidgets('increments and decrements within the configured bounds', (tester) async {
      var quantity = 2;

      Future<void> render() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SnapQuantityStepper(
                quantity: quantity,
                min: 1,
                max: 3,
                onDecrement: () => quantity -= 1,
                onIncrement: () => quantity += 1,
              ),
            ),
          ),
        );
      }

      await render();
      await tester.tap(find.byTooltip('Increase quantity'));
      expect(quantity, 3);
      await render();
      await tester.tap(find.byTooltip('Increase quantity'));
      expect(quantity, 3);
      await tester.tap(find.byTooltip('Decrease quantity'));
      expect(quantity, 2);
    });

    testWidgets('keeps both stepper actions at least 48px high', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SnapQuantityStepper(
              quantity: 2,
              onDecrement: () {},
              onIncrement: () {},
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byTooltip('Decrease quantity')).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byTooltip('Increase quantity')).height, greaterThanOrEqualTo(48));
    });
  });
}

void _ignoreSelection(bool _) {}
