import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/delivery_models.dart';
import '../data/delivery_repository.dart';
import 'delivery_controller.dart';

class DeliveryRequestsScreen extends ConsumerStatefulWidget {
  const DeliveryRequestsScreen({super.key});

  @override
  ConsumerState<DeliveryRequestsScreen> createState() => _DeliveryRequestsScreenState();
}

class _DeliveryRequestsScreenState extends ConsumerState<DeliveryRequestsScreen> {
  String filter = 'All';



  @override
  Widget build(BuildContext context) {
    final assignments = ref.watch(deliveryAssignmentsProvider);

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final desktop = c.maxWidth >= 900;
            final visible = assignments.when(
              loading: () => const <List<String>>[],
              error: (_, __) => const <List<String>>[],
              data: (page) => page.items.map((r) => [r.id.toString(), r.orderId?.toString() ?? 'Order', r.pickupAddress ?? 'Pickup', r.dropoffAddress ?? 'Dropoff', '—', '—', '—', r.status]).toList(),
            );
            return Row(
              children: [
                if (desktop) const _Sidebar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 32 : 16,
                      vertical: desktop ? 28 : 18,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!desktop) const _MobileHeader(),
                            if (!desktop) const SizedBox(height: 18),
                            const Text(
                              'Delivery requests',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Choose a trip that works for you.',
                              style: TextStyle(fontSize: 14, color: SnapFoodColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 20),
                            assignments.when(
                              loading: () => const _OnlineBanner(),
                              error: (_, __) => const _OnlineBanner(),
                              data: (_) => const _OnlineBanner(),
                            ),
                            const SizedBox(height: 18),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final f in ['All', 'Priority', 'Quick', 'Standard'])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(f),
                                        selected: filter == f,
                                        onSelected: (_) => setState(() => filter = f),
                                        selectedColor: SnapFoodColors.primaryContainer,
                                        side: BorderSide(color: filter == f ? SnapFoodColors.primary : SnapFoodColors.softBorder),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (visible.isEmpty)
                              const _EmptyState()
                            else
                              LayoutBuilder(
                                builder: (context, inner) {
                                  final columns = inner.maxWidth >= 1000 ? 3 : inner.maxWidth >= 650 ? 2 : 1;
                                  final width = (inner.maxWidth - (columns - 1) * 14) / columns;
                                  return Wrap(
                                    spacing: 14,
                                    runSpacing: 14,
                                    children: [
                                      for (final r in visible)
                                        SizedBox(width: width, child: _RequestCard(data: r, onStatus: (status) async {
                                          try {
                                            await ref.read(deliveryRepositoryProvider).updateStatus(int.parse(r[0]), status);
                                            ref.invalidate(deliveryAssignmentsProvider);
                                          } catch (error) {
                                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                                          }
                                        })),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.data, required this.onStatus});
  final List<String> data;
  final Future<void> Function(String status) onStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(data[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: SnapFoodColors.onSurfaceVariant))),
            _Tag(data[7]),
          ]),
          const SizedBox(height: 14),
          Text(data[1], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _Route(Icons.storefront_outlined, 'Pickup', data[2]),
          const SizedBox(height: 10),
          _Route(Icons.location_on_outlined, 'Drop', data[3]),
          const SizedBox(height: 14),
          const Divider(color: SnapFoodColors.softBorder),
          const SizedBox(height: 12),
          Row(children: [
            _Metric(Icons.route_outlined, data[4]),
            const SizedBox(width: 14),
            _Metric(Icons.schedule_outlined, data[5]),
            const Spacer(),
            Text(data[6], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: SnapFoodColors.secondary)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => onStatus(switch (data[7]) {
                'PICKED_UP' => 'OUT_FOR_DELIVERY',
                'OUT_FOR_DELIVERY' => 'DELIVERED',
                _ => 'PICKED_UP',
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: SnapFoodColors.secondary,
                foregroundColor: SnapFoodColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
              ),
              child: Text(switch (data[7]) {
                'PICKED_UP' => 'Start delivery',
                'OUT_FOR_DELIVERY' => 'Mark delivered',
                'DELIVERED' => 'Completed',
                _ => 'Pick up order',
              }, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Route extends StatelessWidget {
  const _Route(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: SnapFoodColors.secondary),
    const SizedBox(width: 10),
    SizedBox(width: 48, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: SnapFoodColors.onSurfaceVariant))),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
  ]);
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.value);
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: SnapFoodColors.onSurfaceVariant),
    const SizedBox(width: 5),
    Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
  ]);
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: label == 'Priority' ? SnapFoodColors.softRed : SnapFoodColors.softYellow,
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
    ),
    child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
  );
}

class _OnlineBanner extends StatelessWidget {
  const _OnlineBanner();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: SnapFoodColors.softYellow,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: const Row(children: [
      CircleAvatar(
        radius: 23,
        backgroundColor: SnapFoodColors.primaryContainer,
        child: Icon(Icons.delivery_dining_rounded, color: SnapFoodColors.warmBlack),
      ),
      SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('You are online', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        SizedBox(height: 4),
        Text('New delivery requests are ready to accept.', style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
      ])),
      Icon(Icons.circle, size: 9, color: SnapFoodColors.primary),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 24),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: const Column(children: [
      Icon(Icons.route_outlined, size: 48, color: SnapFoodColors.onSurfaceVariant),
      SizedBox(height: 14),
      Text('No requests in this filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      SizedBox(height: 6),
      Text('Try another request type or stay online for new trips.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
    ]),
  );
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();
  @override
  Widget build(BuildContext context) => Row(children: [
    const CircleAvatar(
      radius: 19,
      backgroundColor: SnapFoodColors.primaryContainer,
      child: Icon(Icons.delivery_dining_rounded, color: SnapFoodColors.warmBlack),
    ),
    const SizedBox(width: 10),
    const Expanded(child: Text('SNAP FOODDD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: SnapFoodColors.softYellow, borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
      child: const Text('ONLINE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
    ),
  ]);
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();
  @override
  Widget build(BuildContext context) => Container(
    width: 224,
    height: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 24, 14, 18),
    decoration: const BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      border: Border(right: BorderSide(color: SnapFoodColors.softBorder)),
    ),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        CircleAvatar(radius: 19, backgroundColor: SnapFoodColors.primaryContainer, child: Icon(Icons.delivery_dining_rounded, color: SnapFoodColors.warmBlack)),
        SizedBox(width: 9),
        Text('SNAP FOODDD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
      ]),
      SizedBox(height: 34),
      Text('PARTNER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: SnapFoodColors.onSurfaceVariant)),
      SizedBox(height: 10),
      _NavRow(Icons.inbox_outlined, 'Requests', true),
      _NavRow(Icons.map_outlined, 'Duty map', false),
      _NavRow(Icons.route_outlined, 'Trips', false),
      _NavRow(Icons.account_balance_wallet_outlined, 'Earnings', false),
      Spacer(),
      Text('ONLINE • ACCEPTING REQUESTS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: SnapFoodColors.primary)),
    ]),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow(this.icon, this.label, this.selected);
  final IconData icon;
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 5),
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
    decoration: BoxDecoration(
      color: selected ? SnapFoodColors.primaryContainer : null,
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
    ),
    child: Row(children: [
      Icon(icon, size: 18, color: SnapFoodColors.warmBlack),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
    ]),
  );
}

final deliveryApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final deliverySessionStoreProvider = Provider<SessionStore>((ref) => SecureSessionStore());

final deliveryAssignmentsProvider = FutureProvider.autoDispose<DeliveryAssignmentPage>((ref) {
  final repository = ref.watch(deliveryRepositoryProvider);
  return repository.fetchAssignments();
});
