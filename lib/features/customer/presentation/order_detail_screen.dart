import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../data/order_models.dart';
import 'order_controller.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(orderHistoryControllerProvider.notifier).loadDetail(widget.orderId)); }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderHistoryControllerProvider);
    final order = state.value?.selectedOrder;
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      appBar: AppBar(title: Text('Order #' + widget.orderId), backgroundColor: SnapFoodColors.surface, surfaceTintColor: Colors.transparent),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: FilledButton(onPressed: () => ref.read(orderHistoryControllerProvider.notifier).loadDetail(widget.orderId), child: const Text('Retry'))),
        data: (_) {
          if (order == null || order.id != widget.orderId) return const Center(child: CircularProgressIndicator());
          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
            _StatusCard(status: _statusLabel(order.status)),
            const SizedBox(height: 14),
            _Section(title: 'Items', child: Column(children: [for (final item in order.items) ListTile(contentPadding: EdgeInsets.zero, title: Text(item.productId.isEmpty ? 'Product' : 'Product ' + item.productId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), trailing: Text('×' + item.quantity.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)))])),
            const SizedBox(height: 12),
            _Section(title: 'Delivery address', child: order.deliveryAddress == null ? const Text('Address snapshot unavailable.', style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)) : Text(_addressText(order.deliveryAddress!), style: const TextStyle(fontSize: 11, height: 1.45, color: SnapFoodColors.onSurfaceVariant))),
            const SizedBox(height: 12),
            _Section(title: 'Payment', child: Column(children: [_Row('Method', order.paymentMethod), const SizedBox(height: 7), _Row('Status', order.paymentStatus), const Divider(height: 18), _Row('Subtotal', order.subtotal), const SizedBox(height: 7), _Row('Delivery', order.deliveryFee), const Divider(height: 18), _Row('Total', order.total, strong: true)])),
          ]);
        },
      ),
    );
  }
  static String _addressText(DeliveryAddress address) => [address.label, address.recipientName, address.addressLine1, if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) address.addressLine2!, address.city, address.state, address.postalCode, address.country].where((part) => part.trim().isNotEmpty).join(', ');
  static String _statusLabel(OrderStatus status) => switch (status) { OrderStatus.placed => 'Placed', OrderStatus.accepted => 'Accepted', OrderStatus.preparing => 'Preparing', OrderStatus.readyForPickup => 'Ready for pickup', OrderStatus.assigned => 'Assigned', OrderStatus.pickedUp => 'Picked up', OrderStatus.outForDelivery => 'Out for delivery', OrderStatus.delivered => 'Delivered', OrderStatus.cancelled => 'Cancelled', OrderStatus.unknown => 'Status unavailable' };
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status}); final String status;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: SnapFoodColors.primaryContainer, borderRadius: BorderRadius.circular(SnapFoodRadii.lg)), child: Row(children: [const Icon(Icons.receipt_long_outlined, color: SnapFoodColors.warmBlack), const SizedBox(width: 10), Expanded(child: Text(status, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))]));
}
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child}); final String title; final Widget child;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg), border: Border.all(color: SnapFoodColors.softBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)), const SizedBox(height: 10), child]));
}
class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false}); final String label; final String value; final bool strong;
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(label, style: TextStyle(fontSize: strong ? 13 : 11, fontWeight: strong ? FontWeight.w800 : FontWeight.w600, color: strong ? SnapFoodColors.onSurface : SnapFoodColors.onSurfaceVariant))), Text(value.isEmpty ? '—' : (label == 'Method' || label == 'Status' ? value : '₹' + value), style: TextStyle(fontSize: strong ? 14 : 11, fontWeight: FontWeight.w800))]);
}