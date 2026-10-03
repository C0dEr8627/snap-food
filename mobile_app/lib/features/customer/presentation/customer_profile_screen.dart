import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
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
                                  Expanded(child: _ProfileIdentity(name: displayName, email: email, phone: phone, orderCount: orderCount, favoriteCount: favoriteCount, addressCount: addressCount, selectedAddress: selectedAddress, onEdit: () => _editProfile(context, ref, displayName, phone))),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _ProfileSections(
                                      selectedAddress: selectedAddress,
                                      onLogout: () => _confirmLogout(context, ref),
                                      onEdit: () => _editProfile(context, ref, displayName, phone),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _ProfileIdentity(name: displayName, email: email, phone: phone, orderCount: orderCount, favoriteCount: favoriteCount, addressCount: addressCount, selectedAddress: selectedAddress, onEdit: () => _editProfile(context, ref, displayName, phone)),
                                  const SizedBox(height: 20),
                                  _ProfileSections(
                                    selectedAddress: selectedAddress,
                                    onLogout: () => _confirmLogout(context, ref),
                                    onEdit: () => _editProfile(context, ref, displayName, phone),
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

  Future<void> _editProfile(BuildContext context, WidgetRef ref, String name, String phone) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) => value == null || value.trim().length < 2
                    ? 'Enter at least 2 characters'
                    : value.trim().length > 120 ? 'Name must be 120 characters or less' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone number', hintText: '+919876543210'),
                validator: (value) {
                  final input = value?.trim() ?? '';
                  if (input.isEmpty || RegExp(r'^\+91[6-9][0-9]{9}$').hasMatch(input)) return null;
                  return 'Use +91 followed by a valid 10-digit number';
                },
              ),
              const SizedBox(height: 8),
              Text('Email address cannot be changed here.', style: SnapFoodTypography.bodySmall.copyWith(color: SnapFoodColors.onSurfaceVariant)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
    if (shouldSave == true) {
      try {
        await ref.read(authControllerProvider.notifier).updateProfile(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully.')));
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update profile: $error')));
        }
      }
    }
    nameController.dispose();
    phoneController.dispose();
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
        color: SnapFoodColors.surface,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              SnapIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back to home',
                semanticLabel: 'Back to home',
                onPressed: () => context.go('/home'),
              ),
              Expanded(
                child: Text(
                  'My profile',
                  style: SnapFoodTypography.titleMedium,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.name, required this.email, required this.phone, required this.orderCount, required this.favoriteCount, required this.addressCount, required this.selectedAddress, required this.onEdit});
  final String name;
  final String email;
  final String phone;
  final int orderCount;
  final int favoriteCount;
  final int addressCount;
  final SavedAddress? selectedAddress;
  final VoidCallback onEdit;

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
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Edit profile',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, color: Colors.white, size: 14),
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
        subtitle: 'Your saved dishes',
        onTap: () => context.go('/favorites'),
      ),
    ],
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
            padding: const EdgeInsets.all(SnapFoodSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: SnapFoodColors.softYellow,
                    borderRadius: BorderRadius.circular(SnapFoodRadii.md),
                  ),
                  child: Icon(icon, size: 20, color: SnapFoodColors.warmBlack),
                ),
                const SizedBox(width: SnapFoodSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: SnapFoodTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: SnapFoodTypography.bodySmall.copyWith(
                          color: SnapFoodColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: SnapFoodColors.outline),
              ],
            ),
          ),
        ),
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
  const _ProfileSections({
    required this.selectedAddress,
    required this.onLogout,
    required this.onEdit,
  });

  final SavedAddress? selectedAddress;
  final VoidCallback onLogout;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final addressSubtitle = selectedAddress == null
        ? 'Add or manage your delivery addresses'
        : selectedAddress!.label + ' · ' + selectedAddress!.displayLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SnapSectionHeader(
          title: 'Your account',
          subtitle: 'Quick access to orders, favorites and delivery addresses.',
        ),
        const SizedBox(height: 8),
        _AccountRow(
          icon: Icons.receipt_long_outlined,
          title: 'My orders',
          subtitle: 'Track current and previous orders',
          onTap: () => context.go('/orders'),
        ),
        _AccountRow(
          icon: Icons.favorite_rounded,
          title: 'Favorites',
          subtitle: 'Your saved dishes',
          onTap: () => context.go('/favorites'),
        ),
        _AccountRow(
          icon: Icons.location_on_outlined,
          title: 'Saved addresses',
          subtitle: addressSubtitle,
          onTap: () => context.go('/addresses'),
        ),
        const SizedBox(height: 24),
        const SnapSectionHeader(
          title: 'Account',
          subtitle: 'Your signed-in customer account.',
        ),
        const SizedBox(height: 8),
        _AccountRow(
          icon: Icons.person_outline_rounded,
          title: 'Account details',
          subtitle: 'Edit your name and phone number',
          onTap: onEdit,
        ),
        const _AccountRow(
          icon: Icons.info_outline_rounded,
          title: 'About Snap Foodd',
          subtitle: 'Customer food commerce experience',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: SnapSecondaryButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            onPressed: onLogout,
          ),
        ),
      ],
    );
  }
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

