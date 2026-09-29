import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/features/customer/data/catalogue_models.dart';
import '../../../lib/features/customer/presentation/catalogue_state_message.dart';

void main() {
  testWidgets('shows loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CatalogueStateMessage(
          value: const AsyncLoading<CatalogueSnapshot>(),
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('Loading the latest catalogue…'), findsOneWidget);
  });

  testWidgets('shows empty state', (tester) async {
    const snapshot = CatalogueSnapshot(categories: [], products: []);

    await tester.pumpWidget(
      MaterialApp(
        home: CatalogueStateMessage(
          value: const AsyncData(snapshot),
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('No catalogue items yet'), findsOneWidget);
  });

  testWidgets('shows error state and retries', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CatalogueStateMessage(
          value: AsyncValue.error(
            StateError('network failure'),
            StackTrace.empty,
          ),
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('Catalogue unavailable'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
