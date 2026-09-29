import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../data/invoice_models.dart';
import 'invoice_controller.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(invoiceControllerProvider.notifier).load(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceControllerProvider);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      appBar: AppBar(title: const Text('Invoice'), backgroundColor: SnapFoodColors.surface, surfaceTintColor: Colors.transparent),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => ref.read(invoiceControllerProvider.notifier).load(widget.orderId), child: const Text('Retry')),
          ]),
        )),
        data: (invoice) => invoice == null ? const Center(child: Text('Invoice is not available.')) : _InvoiceBody(invoice: invoice),
      ),
    );
  }
}

class _InvoiceBody extends StatelessWidget {
  const _InvoiceBody({required this.invoice});
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: SnapFoodColors.primaryContainer, borderRadius: BorderRadius.circular(SnapFoodRadii.lg)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Invoice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(invoice.invoiceNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Order #' + invoice.orderId.toString(), style: const TextStyle(fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 12),
        _Section(title: 'Customer', child: Text(
          [invoice.customerName, if (invoice.customerEmail != null && invoice.customerEmail!.isNotEmpty) invoice.customerEmail!].join('\n'),
          style: const TextStyle(fontSize: 12, height: 1.45),
        )),
        if (invoice.deliveryAddress != null) ...[
          const SizedBox(height: 12),
          _Section(title: 'Delivery address', child: Text(_addressText(invoice.deliveryAddress!), style: const TextStyle(fontSize: 11, height: 1.45))),
        ],
        const SizedBox(height: 12),
        _Section(title: 'Items', child: Column(
          children: invoice.items.map((item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.productName.isEmpty ? 'Product ' + item.productId.toString() : item.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            subtitle: Text(item.quantity.toString() + ' × ₹' + item.unitPrice, style: const TextStyle(fontSize: 10)),
            trailing: Text('₹' + item.lineTotal, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          )).toList(growable: false),
        )),
        const SizedBox(height: 12),
        _Section(title: 'Payment', child: Column(children: [
          _Row('Method', invoice.paymentMethod),
          const SizedBox(height: 7),
          _Row('Status', invoice.paymentStatus),
          const Divider(height: 18),
          _Row('Subtotal', '₹' + invoice.subtotal),
          const SizedBox(height: 7),
          _Row('Delivery', '₹' + invoice.deliveryFee),
          const Divider(height: 18),
          _Row('Total', '₹' + invoice.total, strong: true),
        ])),
      ],
    );
  }

  static String _addressText(DeliveryAddress address) => [
    address.label, address.recipientName, address.addressLine1,
    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) address.addressLine2!,
    address.city, address.state, address.postalCode, address.country,
  ].where((part) => part.trim().isNotEmpty).join(', ');
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg), border: Border.all(color: SnapFoodColors.softBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      child,
    ]),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: TextStyle(fontSize: strong ? 13 : 11, fontWeight: strong ? FontWeight.w800 : FontWeight.w600, color: strong ? SnapFoodColors.onSurface : SnapFoodColors.onSurfaceVariant))),
    Text(value.isEmpty ? '—' : value, style: TextStyle(fontSize: strong ? 14 : 11, fontWeight: FontWeight.w800)),
  ]);
}
