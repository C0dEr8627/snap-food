import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../auth/presentation/auth_controller.dart';
import 'address_book_controller.dart';
import 'favorite_controller.dart';
import 'order_controller.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.value?.user?.payload ?? const <String, dynamic>{};
    final displayName = (user['name'] ?? 'Snap Foodd Customer').toString();
    final email = (user['email'] ?? '').toString();
    final phone = (user['phone'] ?? user['phone_number'] ?? '').toString();
    final orders = ref.watch(orderHistoryControllerProvider);
    final favorites = ref.watch(favoriteControllerProvider);
    final addresses = ref.watch(addressBookControllerProvider);
    final orderCount = orders.asData?.value?.total ?? orders.asData?.value?.orders.length ?? 0;
    final favoriteCount = favorites.asData?.value?.products.length ?? 0;
    final addressCount = addresses.asData?.value?.addresses.length ?? 0;
    final selectedAddress = addresses.asData?.value?.selectedAddress;
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
                const _ProfileHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      20,
                      horizontal,
                      24 + MediaQuery.paddingOf(context).bottom,
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
                                  Expanded(child: _ProfileIdentity(name: displayName, email: email, phone: phone, orderCount: orderCount, favoriteCount: favoriteCount, addressCount: addressCount, selectedAddress: selectedAddress)),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _ProfileSections(
                                      selectedAddress: selectedAddress,
                                      onLogout: () => _confirmLogout(context, ref),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _ProfileIdentity(name: displayName, email: email, phone: phone, orderCount: orderCount, favoriteCount: favoriteCount, addressCount: addressCount, selectedAddress: selectedAddress),
                                  const SizedBox(height: 20),
                                  _ProfileSections(
                                    selectedAddress: selectedAddress,
                                    onLogout: () => _confirmLogout(context, ref),
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

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of Snap Foodd?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: SnapFoodColors.secondary, foregroundColor: Colors.white),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go('/welcome');
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
              tooltip: 'Back to home',
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Expanded(
              child: Text(
                'My Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.name, required this.email, required this.phone, required this.orderCount, required this.favoriteCount, required this.addressCount, required this.selectedAddress});
  final String name;
  final String email;
  final String phone;
  final int orderCount;
  final int favoriteCount;
  final int addressCount;
  final SavedAddress? selectedAddress;

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
            Text(
              name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              phone.isNotEmpty ? phone : email,
              style: TextStyle(
                fontSize: 12,
                color: SnapFoodColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: SnapFoodColors.softYellow,
                borderRadius: BorderRadius.circular(SnapFoodRadii.full),
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
            Row(
              children: [
                Expanded(child: _StatValue(orderCount, 'Orders')),
                const _StatDivider(),
                Expanded(child: _StatValue(favoriteCount, 'Favorites')),
                const _StatDivider(),
                Expanded(child: _StatValue(addressCount, 'Addresses')),
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
        onTap: () => context.go('/orders'),
      ),
      const SizedBox(height: 10),
      _ProfileAction(
        icon: Icons.favorite_border,
        title: 'Favorites',
        subtitle: 'Your saved restaurants and dishes',
        onTap: () => context.go('/favorites'),
      ),
    ],
  );
}

class _StatValue extends StatelessWidget {
  const _StatValue(this.value, this.label);

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value.toString(),
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
  const _ProfileSections({required this.selectedAddress, required this.onLogout});
  final SavedAddress? selectedAddress;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionCard(
        title: 'Your account',
        children: [
          _AccountRow(
            icon: Icons.location_on_outlined,
            title: 'Saved addresses',
            subtitle: selectedAddress == null
                ? 'Add or manage your delivery addresses'
                : '${selectedAddress?.label} · ${selectedAddress?.displayLine}',
            onTap: () => context.go('/addresses'),
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
      const _EmbeddedSettings(),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onLogout,
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
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
            child: Icon(icon, size: 19, color: SnapFoodColors.secondary),
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
              child: Icon(icon, color: SnapFoodColors.warmBlack, size: 21),
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
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: SnapFoodColors.outline,
            ),
          ],
        ),
      ),
    ),
  );
}



class _EmbeddedSettings extends StatefulWidget {
  const _EmbeddedSettings();

  @override
  State<_EmbeddedSettings> createState() => _EmbeddedSettingsState();
}

class _EmbeddedSettingsState extends State<_EmbeddedSettings> {
  bool orderUpdates = true;
  bool offers = true;
  bool sounds = true;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionCard(
        title: 'Settings · Notifications',
        children: [
          _AccountRow(
            icon: Icons.receipt_long_outlined,
            title: 'Order updates',
            subtitle: 'Get notified about your delivery status',
            trailing: Switch.adaptive(
              value: orderUpdates,
              onChanged: (value) => setState(() => orderUpdates = value),
              activeTrackColor: SnapFoodColors.primaryContainer,
              activeThumbColor: SnapFoodColors.secondary,
            ),
          ),
          _AccountRow(
            icon: Icons.local_offer_outlined,
            title: 'Offers & recommendations',
            subtitle: 'Receive deals from local food spots',
            trailing: Switch.adaptive(
              value: offers,
              onChanged: (value) => setState(() => offers = value),
              activeTrackColor: SnapFoodColors.primaryContainer,
              activeThumbColor: SnapFoodColors.secondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _SectionCard(
        title: 'App experience',
        children: [
          _AccountRow(
            icon: Icons.volume_up_outlined,
            title: 'Sounds',
            subtitle: 'Play sounds for important order updates',
            trailing: Switch.adaptive(
              value: sounds,
              onChanged: (value) => setState(() => sounds = value),
              activeTrackColor: SnapFoodColors.primaryContainer,
              activeThumbColor: SnapFoodColors.secondary,
            ),
          ),
          const _AccountRow(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
          ),
        ],
      ),
      const SizedBox(height: 14),
      _SectionCard(
        title: 'Privacy & account',
        children: const [
          _AccountRow(
            icon: Icons.lock_outline,
            title: 'Privacy',
            subtitle: 'Manage how your account information is used',
          ),
          _AccountRow(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Account and sign-in preferences',
          ),
          _AccountRow(
            icon: Icons.info_outline,
            title: 'About Snap Fooddd',
            subtitle: 'Version 1.0.0',
          ),
        ],
      ),
    ],
  );
}

