import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

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

            return Column(
              children: [
                _ProfileHeader(onBack: () => context.pop()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      20,
                      horizontal,
                      112 + MediaQuery.paddingOf(context).bottom,
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
                                  const Expanded(child: _ProfileIdentity()),
                                  const SizedBox(width: 20),
                                  Expanded(child: _ProfileSections()),
                                ],
                              )
                            : const Column(
                                children: [
                                  _ProfileIdentity(),
                                  SizedBox(height: 20),
                                  _ProfileSections(),
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
      bottomNavigationBar: const _ProfileBottomNav(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Material(
        color: SnapFoodColors.surface.withAlpha(245),
        elevation: 1,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text(
                    'My Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SnapFoodColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
              border: Border.all(color: SnapFoodColors.softBorder),
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 46,
                      backgroundColor: SnapFoodColors.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 46,
                        color: SnapFoodColors.warmBlack,
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: SnapFoodColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SnapFoodColors.surfaceContainerLowest,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Alex Morgan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  '+91 98765 43210',
                  style: TextStyle(
                    fontSize: 12,
                    color: SnapFoodColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: SnapFoodColors.softYellow,
                    borderRadius:
                        BorderRadius.circular(SnapFoodRadii.full),
                  ),
                  child: const Text(
                    'SNAP FOODDD MEMBER',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(child: _Stat('18', 'Orders')),
                    _StatDivider(),
                    Expanded(child: _Stat('₹4.8k', 'Saved')),
                    _StatDivider(),
                    Expanded(child: _Stat('4.9', 'Rating')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ProfileAction(
            icon: Icons.receipt_long_outlined,
            title: 'My Orders',
            subtitle: 'Track current and previous orders',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _ProfileAction(
            icon: Icons.favorite_border,
            title: 'Favorites',
            subtitle: 'Your saved restaurants and dishes',
            onTap: () {},
          ),
        ],
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: SnapFoodColors.onSurfaceVariant,
            ),
          ),
        ],
      );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: SnapFoodColors.softBorder);
}

class _ProfileSections extends StatelessWidget {
  const _ProfileSections();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _SectionCard(
            title: 'Your account',
            children: [
              _AccountRow(
                icon: Icons.location_on_outlined,
                title: 'Saved addresses',
                subtitle: 'Home • Flat 402, Andheri West',
              ),
              _AccountRow(
                icon: Icons.credit_card_outlined,
                title: 'Payment methods',
                subtitle: 'UPI, cards and cash preferences',
              ),
              _AccountRow(
                icon: Icons.local_offer_outlined,
                title: 'Offers & coupons',
                subtitle: 'View available discounts',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Preferences',
            children: [
              _AccountRow(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Order updates and offers',
                trailing: Switch.adaptive(
                  value: true,
                  onChanged: (_) {},
                  activeTrackColor: SnapFoodColors.primaryContainer,
                  activeThumbColor: SnapFoodColors.secondary,
                ),
              ),
              _AccountRow(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
              ),
              _AccountRow(
                icon: Icons.help_outline,
                title: 'Help & support',
                subtitle: 'FAQs and contact support',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'More',
            children: [
              _AccountRow(
                icon: Icons.shield_outlined,
                title: 'Privacy & security',
                subtitle: 'Manage your account privacy',
              ),
              _AccountRow(
                icon: Icons.info_outline,
                title: 'About Snap Fooddd',
                subtitle: 'Version 1.0.0',
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SnapFoodColors.secondary,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: SnapFoodColors.softBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                ),
              ),
            ),
          ),
        ],
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
            ...children,
          ],
        ),
      );
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: SnapFoodColors.softRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: SnapFoodColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: SnapFoodColors.outline,
                  ),
            ],
          ),
        ),
      );
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: SnapFoodColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: SnapFoodColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: SnapFoodColors.warmBlack,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
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
                const Icon(Icons.chevron_right,
                    size: 20, color: SnapFoodColors.outline),
              ],
            ),
          ),
        ),
      );
}

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav();

  static const items = [
    (Icons.storefront, 'Home'),
    (Icons.search, 'Search'),
    (Icons.receipt_long, 'Orders'),
    (Icons.favorite, 'Favorites'),
    (Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) => Material(
        color: SnapFoodColors.surface.withAlpha(247),
        elevation: 12,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (i == 0) context.go('/home');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            items[i].$1,
                            size: 22,
                            color: i == 4
                                ? SnapFoodColors.secondary
                                : SnapFoodColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].$2,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: i == 4
                                  ? SnapFoodColors.secondary
                                  : SnapFoodColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
