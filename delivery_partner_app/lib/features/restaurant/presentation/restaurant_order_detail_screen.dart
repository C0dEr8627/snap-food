import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class RestaurantOrderDetailScreen extends StatefulWidget {
  const RestaurantOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<RestaurantOrderDetailScreen> createState() =>
      _RestaurantOrderDetailScreenState();
}

class _RestaurantOrderDetailScreenState
    extends State<RestaurantOrderDetailScreen> {
  String _status = 'Preparing';

  static const _items = [
    _DetailItem(
      quantity: 1,
      name: 'Chicken Tikka Dum Biryani',
      note: 'Extra spicy',
      price: '₹320',
    ),
    _DetailItem(
      quantity: 1,
      name: 'Butter Chicken & 2 Naan',
      note: 'Less oil',
      price: '₹280',
    ),
    _DetailItem(quantity: 1, name: 'Masala Chaas', note: '', price: '₹30'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _OrderDetailHeader(
              wide: wide,
              orderId: widget.orderId,
              onBack: () => context.go('/restaurant/kds'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 24 : 16,
                  20,
                  wide ? 24 : 16,
                  32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
                    ),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildTicket()),
                              const SizedBox(width: 20),
                              SizedBox(width: 300, child: _buildSidePanel()),
                            ],
                          )
                        : Column(
                            children: [
                              _buildTicket(),
                              const SizedBox(height: 16),
                              _buildSidePanel(),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicket() {
    return Container(
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 17),
            color: _statusBackground(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#' + widget.orderId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Placed 2 min ago',
                        style: TextStyle(
                          fontSize: 11,
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: _status),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              'Order Items',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
          for (final item in _items) _OrderItemRow(item: item),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              children: [
                const _AmountRow(label: 'Subtotal', value: '₹630'),
                const SizedBox(height: 8),
                const _AmountRow(label: 'Delivery fee', value: '₹0'),
                const SizedBox(height: 8),
                const _AmountRow(label: 'Taxes', value: '₹31.50'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 10),
                const _AmountRow(
                  label: 'Total',
                  value: '₹661.50',
                  strong: true,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: SnapFoodColors.softYellow,
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 18,
                  color: SnapFoodColors.primary,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kitchen note',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Please pack the naan separately.',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
        const _InfoPanel(
          title: 'Customer',
          children: [
            _InfoLine(
              icon: Icons.person_outline,
              title: 'Aarav Mehta',
              subtitle: 'Customer',
            ),
            SizedBox(height: 12),
            _InfoLine(
              icon: Icons.phone_outlined,
              title: '+91 98765 43210',
              subtitle: 'Contact',
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _InfoPanel(
          title: 'Delivery',
          children: [
            _InfoLine(
              icon: Icons.location_on_outlined,
              title: 'Andheri East, Mumbai',
              subtitle: 'Delivery address',
            ),
            SizedBox(height: 12),
            _InfoLine(
              icon: Icons.directions_bike_outlined,
              title: 'Rahul · SF Rider 18',
              subtitle: 'Delivery partner',
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _InfoPanel(
          title: 'Payment',
          children: [
            _InfoLine(
              icon: Icons.credit_card_outlined,
              title: 'UPI',
              subtitle: 'Paid',
            ),
            SizedBox(height: 12),
            _InfoLine(
              icon: Icons.receipt_long_outlined,
              title: '₹661.50',
              subtitle: 'Order total',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ActionPanel(
          status: _status,
          onPrimary: () {
            if (_status == 'Preparing') {
              setState(() => _status = 'Ready');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order marked as ready.')),
              );
            } else {
              context.go('/restaurant/kds');
            }
          },
        ),
      ],
    );
  }

  Color _statusBackground() {
    return _status == 'Ready'
        ? SnapFoodColors.primaryContainer
        : SnapFoodColors.softRed;
  }
}

class _OrderDetailHeader extends StatelessWidget {
  const _OrderDetailHeader({
    required this.wide,
    required this.orderId,
    required this.onBack,
  });

  final bool wide;
  final String orderId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SnapFoodColors.surfaceContainerLowest,
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 12, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back to KDS',
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                'Order #' + orderId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (wide)
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('Print Ticket'),
              )
            else
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.print_outlined),
                tooltip: 'Print ticket',
              ),
            const SizedBox(width: 4),
            const CircleAvatar(
              radius: 18,
              backgroundColor: SnapFoodColors.primaryContainer,
              child: Icon(
                Icons.storefront,
                size: 19,
                color: SnapFoodColors.warmBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final ready = status == 'Ready';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.full),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: ready ? SnapFoodColors.primary : SnapFoodColors.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final _DetailItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SnapFoodColors.softYellow,
              borderRadius: BorderRadius.circular(SnapFoodRadii.sm),
            ),
            child: Text(
              item.quantity.toString() + '×',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.note,
                    style: const TextStyle(
                      fontSize: 10,
                      color: SnapFoodColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            item.price,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: strong ? 13 : 11,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
              color: strong
                  ? SnapFoodColors.warmBlack
                  : SnapFoodColors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: strong ? 14 : 11,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 13),
          ...children,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SnapFoodColors.onSurfaceVariant),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.status, required this.onPrimary});

  final String status;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final ready = status == 'Ready';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        border: Border.all(color: SnapFoodColors.softBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: ready
                    ? SnapFoodColors.primaryContainer
                    : SnapFoodColors.primary,
                foregroundColor: SnapFoodColors.warmBlack,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                ),
              ),
              child: Text(
                ready ? 'Back to KDS' : 'Mark Order Ready',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Contact customer',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  const _DetailItem({
    required this.quantity,
    required this.name,
    required this.note,
    required this.price,
  });

  final int quantity;
  final String name;
  final String note;
  final String price;
}
