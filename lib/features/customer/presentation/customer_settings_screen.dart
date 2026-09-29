import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  bool orderUpdates = true;
  bool offers = true;
  bool sound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      appBar: AppBar(
        backgroundColor: SnapFoodColors.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to profile',
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _SettingsIntro(),
            const SizedBox(height: 18),
            _SettingsSection(
              title: 'Notifications',
              children: [
                _SettingsSwitchRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order updates',
                  subtitle: 'Get notified about your delivery status',
                  value: orderUpdates,
                  onChanged: (value) => setState(() => orderUpdates = value),
                ),
                _SettingsSwitchRow(
                  icon: Icons.local_offer_outlined,
                  title: 'Offers & recommendations',
                  subtitle: 'Receive deals from local food spots',
                  value: offers,
                  onChanged: (value) => setState(() => offers = value),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsSection(
              title: 'App experience',
              children: [
                _SettingsSwitchRow(
                  icon: Icons.volume_up_outlined,
                  title: 'Sounds',
                  subtitle: 'Play sounds for important order updates',
                  value: sound,
                  onChanged: (value) => setState(() => sound = value),
                ),
                const _SettingsRow(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  showChevron: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SettingsSection(
              title: 'Privacy & account',
              children: const [
                _SettingsRow(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  subtitle: 'Manage how your account information is used',
                  showChevron: true,
                ),
                _SettingsRow(
                  icon: Icons.security_outlined,
                  title: 'Security',
                  subtitle: 'Account and sign-in preferences',
                  showChevron: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Snap Foodd • Version 1.0.0',
                style: TextStyle(
                  fontSize: 11,
                  color: SnapFoodColors.onSurfaceVariant.withAlpha(180),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsIntro extends StatelessWidget {
  const _SettingsIntro();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: SnapFoodColors.primaryContainer,
      borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
    ),
    child: const Row(
      children: [
        Icon(Icons.tune_rounded, size: 30, color: SnapFoodColors.warmBlack),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make Snap Foodd yours',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 4),
              Text(
                'Control notifications and your app experience.',
                style: TextStyle(
                  fontSize: 11,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
        ...children,
      ],
    ),
  );
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => _SettingsRow(
    icon: icon,
    title: title,
    subtitle: subtitle,
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeTrackColor: SnapFoodColors.primaryContainer,
      activeThumbColor: SnapFoodColors.secondary,
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.showChevron = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: showChevron ? () {} : null,
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
                  maxLines: 2,
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
              (showChevron
                  ? const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: SnapFoodColors.outline,
                    )
                  : const SizedBox.shrink()),
        ],
      ),
    ),
  );
}
