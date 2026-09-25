import 'package:flutter/material.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class DeliveryVerificationScreen extends StatefulWidget {
  const DeliveryVerificationScreen({super.key});

  @override
  State<DeliveryVerificationScreen> createState() => _DeliveryVerificationScreenState();
}

class _DeliveryVerificationScreenState extends State<DeliveryVerificationScreen> {
  final pinController = TextEditingController();
  bool verified = false;
  bool wrongPin = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    final pin = pinController.text.trim();
    setState(() {
      wrongPin = pin.isNotEmpty && pin != '4821';
      verified = pin == '4821';
    });
    if (verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery verified successfully.')),
      );
    }
  }

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
                                      Expanded(child: _VerificationCard(
                                        controller: pinController,
                                        verified: verified,
                                        wrongPin: wrongPin,
                                        onVerify: _verify,
                                      )),
                                      const SizedBox(width: 18),
                                      Expanded(child: _DeliverySummary(verified: verified)),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    _VerificationCard(
                                      controller: pinController,
                                      verified: verified,
                                      wrongPin: wrongPin,
                                      onVerify: _verify,
                                    ),
                                    const SizedBox(height: 18),
                                    _DeliverySummary(verified: verified),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 18),
                            _SecurityNote(),
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

class _Header extends StatelessWidget {
  const _Header({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_rounded)),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery verification', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('TRP-1842 · Order #SF10248', style: TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant)),
              ],
            ),
          ),
          _StatusPill(label: verified ? 'COMPLETED' : 'VERIFY'),
        ],
      );
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.controller,
    required this.verified,
    required this.wrongPin,
    required this.onVerify,
  });

  final TextEditingController controller;
  final bool verified;
  final bool wrongPin;
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
                    verified ? Icons.verified_rounded : Icons.pin_outlined,
                    color: SnapFoodColors.warmBlack,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text(
                        'Ask the customer for the 4-digit delivery PIN before handing over the order.',
                        style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Enter delivery PIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              enabled: !verified,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 12),
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                errorText: wrongPin ? 'Incorrect PIN. Try again.' : null,
                filled: true,
                fillColor: SnapFoodColors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                  borderSide: const BorderSide(color: SnapFoodColors.softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                  borderSide: const BorderSide(color: SnapFoodColors.softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                  borderSide: const BorderSide(color: SnapFoodColors.secondary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: verified ? null : onVerify,
                icon: Icon(verified ? Icons.check_circle_outline_rounded : Icons.lock_open_rounded),
                label: Text(verified ? 'Delivery verified' : 'Verify delivery'),
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
            const SizedBox(height: 12),
            const Text(
              'For the UI mock, use PIN 4821 to complete verification.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: SnapFoodColors.onSurfaceVariant),
            ),
          ],
        ),
      );
}

class _DeliverySummary extends StatelessWidget {
  const _DeliverySummary({required this.verified});
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
            const Text('Delivery summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            const _InfoRow(icon: Icons.person_outline_rounded, label: 'Customer', value: 'Aarav Mehta'),
            const SizedBox(height: 13),
            const _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: 'Andheri East, Mumbai'),
            const SizedBox(height: 13),
            const _InfoRow(icon: Icons.receipt_long_outlined, label: 'Order', value: '#SF10248'),
            const SizedBox(height: 13),
            const _InfoRow(icon: Icons.payments_outlined, label: 'Payment', value: 'UPI · ₹661.50'),
            const SizedBox(height: 18),
            const Divider(color: SnapFoodColors.softBorder),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  verified ? Icons.check_circle_rounded : Icons.pending_outlined,
                  size: 19,
                  color: verified ? SnapFoodColors.secondary : SnapFoodColors.foodRed,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    verified ? 'Customer PIN verified. Handover complete.' : 'Waiting for customer PIN verification.',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (verified) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SnapFoodColors.primaryContainer,
                  borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                ),
                child: const Text(
                  'Trip completed · Earnings ₹128',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: SnapFoodColors.secondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: SnapFoodColors.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
        ],
      );
}

class _SecurityNote extends StatelessWidget {
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
                'Never ask for or enter a customer PIN before reaching the delivery address.',
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
          color: label == 'COMPLETED' ? SnapFoodColors.primaryContainer : SnapFoodColors.softYellow,
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
          const _StatusPill(label: 'VERIFY'),
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
                CircleAvatar(radius: 19, backgroundColor: SnapFoodColors.primaryContainer, child: Icon(Icons.delivery_dining_rounded, color: SnapFoodColors.warmBlack)),
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
            Text('TRP-1842 • VERIFY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: SnapFoodColors.primary)),
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
        decoration: BoxDecoration(color: selected ? SnapFoodColors.primaryContainer : null, borderRadius: BorderRadius.circular(SnapFoodRadii.md)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: SnapFoodColors.warmBlack),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      );
}
