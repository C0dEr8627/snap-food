import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = 'upi';

  final int itemTotal = 600;
  final int deliveryFee = 0;
  final int taxes = 30;

  int get total => itemTotal + deliveryFee + taxes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1024;
            final horizontal = wide ? 24.0 : 16.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: SnapFoodColors.surface,
                      surfaceTintColor: Colors.transparent,
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      title: const Text(
                        'Checkout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 120),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(title: 'Deliver to', action: 'Change'),
                            const SizedBox(height: 9),
                            const _AddressCard(),
                            const SizedBox(height: 22),
                            const _SectionTitle(title: 'Delivery instructions'),
                            const SizedBox(height: 9),
                            const _InstructionSelector(),
                            const SizedBox(height: 22),
                            const _SectionTitle(title: 'Payment method'),
                            const SizedBox(height: 9),
                            _PaymentCard(
                              selected: paymentMethod == 'upi',
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'UPI',
                              subtitle: 'Pay securely with your UPI app',
                              onTap: () => setState(() => paymentMethod = 'upi'),
                            ),
                            const SizedBox(height: 8),
                            _PaymentCard(
                              selected: paymentMethod == 'card',
                              icon: Icons.credit_card_outlined,
                              title: 'Card',
                              subtitle: 'Credit or debit card',
                              onTap: () => setState(() => paymentMethod = 'card'),
                            ),
                            const SizedBox(height: 8),
                            _PaymentCard(
                              selected: paymentMethod == 'cod',
                              icon: Icons.payments_outlined,
                              title: 'Cash on delivery',
                              subtitle: 'Pay when your order arrives',
                              onTap: () => setState(() => paymentMethod = 'cod'),
                            ),
                            const SizedBox(height: 22),
                            const _SectionTitle(title: 'Order summary'),
                            const SizedBox(height: 9),
                            _OrderSummary(
                              itemTotal: itemTotal,
                              deliveryFee: deliveryFee,
                              taxes: taxes,
                              total: total,
                            ),
                            const SizedBox(height: 14),
                            const _SafetyNote(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: SnapFoodColors.secondary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Place Order  •  ₹$total',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: SnapFoodColors.secondary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: SnapFoodColors.softRed,
            borderRadius: BorderRadius.circular(SnapFoodRadii.md),
          ),
          child: const Icon(Icons.home_outlined, color: SnapFoodColors.secondary, size: 22),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Home', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  SizedBox(width: 7),
                  _AddressPill(),
                ],
              ),
              SizedBox(height: 5),
              Text(
                'Flat 402, Andheri West, Mumbai',
                style: TextStyle(fontSize: 11, height: 1.35, color: SnapFoodColors.onSurfaceVariant),
              ),
              SizedBox(height: 2),
              Text(
                'Near Andheri Metro Station',
                style: TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: SnapFoodColors.outline),
      ],
    ),
  );
}

class _AddressPill extends StatelessWidget {
  const _AddressPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: SnapFoodColors.primaryContainer,
      borderRadius: BorderRadius.circular(SnapFoodRadii.full),
    ),
    child: const Text(
      'DEFAULT',
      style: TextStyle(
        fontSize: 7,
        fontWeight: FontWeight.w800,
        color: SnapFoodColors.onPrimary,
      ),
    ),
  );
}

class _InstructionSelector extends StatelessWidget {
  const _InstructionSelector();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: const Row(
      children: [
        Icon(Icons.door_front_door_outlined, color: SnapFoodColors.secondary, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text('Leave at the door', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        Icon(Icons.radio_button_unchecked, color: SnapFoodColors.outline, size: 20),
      ],
    ),
  );
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? SnapFoodColors.primaryContainer : SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(
          color: selected ? SnapFoodColors.primary : SnapFoodColors.softBorder,
          width: selected ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SnapFoodColors.surface,
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
            ),
            child: Icon(icon, color: SnapFoodColors.secondary, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: selected ? SnapFoodColors.secondary : SnapFoodColors.outline,
            size: 21,
          ),
        ],
      ),
    ),
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.itemTotal,
    required this.deliveryFee,
    required this.taxes,
    required this.total,
  });

  final int itemTotal;
  final int deliveryFee;
  final int taxes;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      border: Border.all(color: SnapFoodColors.softBorder),
    ),
    child: Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text('2 items', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            Text(
              'Mumbai Spice Kitchen',
              style: TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: SnapFoodColors.softBorder, height: 1),
        ),
        _SummaryRow('Item total', '₹$itemTotal'),
        const SizedBox(height: 8),
        _SummaryRow(
          'Delivery fee',
          deliveryFee == 0 ? 'FREE' : '₹$deliveryFee',
          accent: deliveryFee == 0,
        ),
        const SizedBox(height: 8),
        _SummaryRow('Taxes & charges', '₹$taxes'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 11),
          child: Divider(color: SnapFoodColors.softBorder, height: 1),
        ),
        _SummaryRow('To pay', '₹$total', strong: true),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.accent = false, this.strong = false});

  final String label;
  final String value;
  final bool accent;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: strong ? 13 : 11,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            color: strong ? SnapFoodColors.onSurface : SnapFoodColors.onSurfaceVariant,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: strong ? 15 : 11,
          fontWeight: FontWeight.w800,
          color: accent ? Colors.green : SnapFoodColors.onSurface,
        ),
      ),
    ],
  );
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: SnapFoodColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(SnapFoodRadii.md),
    ),
    child: const Row(
      children: [
        Icon(Icons.lock_outline, color: SnapFoodColors.secondary, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Your payment details are protected. You will only be charged after confirming this order.',
            style: TextStyle(fontSize: 10, height: 1.4, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
