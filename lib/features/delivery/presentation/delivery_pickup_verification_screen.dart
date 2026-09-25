import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class DeliveryPickupVerificationScreen extends StatefulWidget {
  const DeliveryPickupVerificationScreen({super.key});

  @override
  State<DeliveryPickupVerificationScreen> createState() => _DeliveryPickupVerificationScreenState();
}

class _DeliveryPickupVerificationScreenState extends State<DeliveryPickupVerificationScreen> {
  bool verified = false;
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final desktop = c.maxWidth >= 900;
            return Row(
              children: [
                if (desktop) const _Sidebar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: desktop ? 32 : 16, vertical: 18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: SnapFoodSpacing.desktopMaxContentWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!desktop) const _MobileHeader(),
                            if (!desktop) const SizedBox(height: 18),
                            _Header(verified: verified),
                            const SizedBox(height: 18),
                            LayoutBuilder(
                              builder: (context, inner) {
                                final wide = inner.maxWidth >= 820;
                                if (wide) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: _VerificationCard(verified: verified, onVerify: _verify)),
                                      const SizedBox(width: 18),
                                      Expanded(child: _OrderCard(verified: verified)),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _VerificationCard(verified: verified, onVerify: _verify),
                                    const SizedBox(height: 18),
                                    _OrderCard(verified: verified),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 18),
                            _SafetyNote(),
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

  void _verify() {
    setState(() {
      verified = true;
      expanded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pickup verified. Ready for customer navigation.')),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pickup confirmation', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('TRP-1842 · Mumbai Spice Kitchen', style: TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant)),
              ],
            ),
          ),
          _StatusPill(label: verified ? 'VERIFIED' : 'AT RESTAURANT'),
        ],
      );
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.verified, required this.onVerify});
  final bool verified;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: verified ? SnapFoodColors.primaryContainer : SnapFoodColors.softYellow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    verified ? Icons.check_rounded : Icons.qr_code_scanner_rounded,
                    color: SnapFoodColors.warmBlack,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verify pickup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('Confirm that the restaurant handover matches this trip.', style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _CheckRow(
              icon: Icons.receipt_long_outlined,
              title: 'Order number',
              value: '#SF10248',
              done: verified,
            ),
            _CheckRow(
              icon: Icons.restaurant_outlined,
              title: 'Restaurant',
              value: 'Mumbai Spice Kitchen',
              done: verified,
            ),
            _CheckRow(
              icon: Icons.shopping_bag_outlined,
              title: 'Items',
              value: '3 items',
              done: verified,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: verified ? null : onVerify,
                icon: Icon(verified ? Icons.verified_rounded : Icons.verified_outlined),
                label: Text(verified ? 'Pickup verified' : 'Confirm pickup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SnapFoodColors.secondary,
                  foregroundColor: SnapFoodColors.onPrimary,
                  disabledBackgroundColor: SnapFoodColors.primaryContainer,
                  disabledForegroundColor: SnapFoodColors.warmBlack,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      );
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.icon, required this.title, required this.value, required this.done});
  final IconData icon;
  final String title;
  final String value;
  final bool done;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainer,
          borderRadius: BorderRadius.circular(SnapFoodRadii.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: SnapFoodColors.secondary),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: SnapFoodColors.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 19,
              color: done ? SnapFoodColors.secondary : SnapFoodColors.softBorder,
            ),
          ],
        ),
      );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pickup ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SnapFoodColors.cream,
                borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                border: Border.all(color: SnapFoodColors.softBorder),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: SnapFoodColors.primaryContainer,
                        child: Icon(Icons.restaurant_rounded, color: SnapFoodColors.warmBlack),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Mumbai Spice Kitchen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                      ),
                      Text('#SF10248', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: SnapFoodColors.softBorder),
                  const SizedBox(height: 12),
                  const _TicketLine(name: 'Chicken Biryani', qty: '1', price: '₹320'),
                  const _TicketLine(name: 'Butter Chicken Combo', qty: '1', price: '₹280'),
                  const _TicketLine(name: 'Paneer Tikka', qty: '1', price: '₹210'),
                  const SizedBox(height: 8),
                  const Divider(color: SnapFoodColors.softBorder),
                  const SizedBox(height: 9),
                  const _TicketLine(name: 'Total', qty: '', price: '₹661.50', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  verified ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                  size: 17,
                  color: SnapFoodColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    verified
                        ? 'Pickup handover recorded. Customer navigation can begin.'
                        : 'Confirm the pickup before leaving the restaurant.',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: SnapFoodColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _TicketLine extends StatelessWidget {
  const _TicketLine({required this.name, required this.qty, required this.price, this.bold = false});
  final String name;
  final String qty;
  final String price;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            if (qty.isNotEmpty) SizedBox(width: 22, child: Text('$qty×', style: const TextStyle(fontSize: 10, color: SnapFoodColors.onSurfaceVariant))),
            Expanded(child: Text(name, style: TextStyle(fontSize: 10, fontWeight: bold ? FontWeight.w900 : FontWeight.w600))),
            Text(price, style: TextStyle(fontSize: 10, fontWeight: bold ? FontWeight.w900 : FontWeight.w700)),
          ],
        ),
      );
}

class _SafetyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SnapFoodColors.softYellow,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_user_outlined, size: 21, color: SnapFoodColors.secondary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Only leave the pickup point after the order has been verified and handed over securely.',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.4),
              ),
            ),
          ],
        ),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: label == 'VERIFIED' ? SnapFoodColors.primaryContainer : SnapFoodColors.softYellow,
          borderRadius: BorderRadius.circular(SnapFoodRadii.full),
        ),
        child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
      );
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded)),
          const Expanded(child: Text('SNAP FOOD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
          const _StatusPill(label: 'AT RESTAURANT'),
        ],
      );
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: SnapFoodColors.primaryContainer,
                  child: Icon(Icons.delivery_dining_rounded, color: SnapFoodColors.warmBlack),
                ),
                SizedBox(width: 9),
                Text('SNAP FOOD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              ],
            ),
            SizedBox(height: 34),
            Text('PARTNER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: SnapFoodColors.onSurfaceVariant)),
            SizedBox(height: 10),
            _NavRow(Icons.inbox_outlined, 'Requests', false),
            _NavRow(Icons.map_outlined, 'Duty map', false),
            _NavRow(Icons.route_outlined, 'Trips', true),
            _NavRow(Icons.account_balance_wallet_outlined, 'Earnings', false),
            Spacer(),
            Text('TRP-1842 • PICKUP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: SnapFoodColors.primary)),
          ],
        ),
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
        child: Row(
          children: [
            Icon(icon, size: 18, color: SnapFoodColors.warmBlack),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
