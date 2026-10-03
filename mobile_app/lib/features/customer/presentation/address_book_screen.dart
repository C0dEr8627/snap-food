import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/components/snap_food_button.dart';
import '../../../design_system/components/snap_food_commerce.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import 'address_book_controller.dart';

class AddressBookScreen extends ConsumerStatefulWidget {
  const AddressBookScreen({super.key});

  @override
  ConsumerState<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends ConsumerState<AddressBookScreen> {
  bool adding = false;
  bool saving = false;
  String? formError;

  final formKey = GlobalKey<FormState>();
  final label = TextEditingController(text: 'Home');
  final recipient = TextEditingController();
  final line1 = TextEditingController();
  final line2 = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final postal = TextEditingController();
  final country = TextEditingController(text: 'India');

  @override
  void dispose() {
    for (final controller in [
      label,
      recipient,
      line1,
      line2,
      city,
      state,
      postal,
      country,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(addressBookControllerProvider);

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: book.when(
          loading: () => const SnapLoadingState(
            message: 'Loading saved addresses…',
          ),
          error: (error, _) => SnapErrorState(
            title: 'Addresses unavailable',
            message: error is ApiException
                ? error.message
                : 'Could not load your saved addresses.',
            onRetry: () => ref
                .read(addressBookControllerProvider.notifier)
                .refresh(),
          ),
          data: (data) => CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: SnapFoodColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: SnapFoodSpacing.sm),
                  child: SnapIconButton(
                    icon: Icons.arrow_back,
                    onPressed: saving ? null : () => context.pop(),
                    tooltip: 'Back',
                    semanticLabel: 'Back',
                  ),
                ),
                title: const Text(
                  'Delivery addresses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: SnapFoodColors.warmBlack,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  SnapFoodSpacing.md,
                  SnapFoodSpacing.sm,
                  SnapFoodSpacing.md,
                  SnapFoodSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SnapSectionHeader(
                      title: 'Where should we deliver?',
                      subtitle: data.addresses.isEmpty
                          ? 'Save an address for faster checkout.'
                          : data.addresses.length.toString() +
                              ' saved ' +
                              (data.addresses.length == 1
                                  ? 'address'
                                  : 'addresses'),
                      actionLabel: data.addresses.isEmpty ? null : 'Add address',
                      onAction: () => _toggleAdding(true),
                    ),
                    const SizedBox(height: SnapFoodSpacing.md),
                    if (data.addresses.isEmpty && !adding)
                      const SnapEmptyState(
                        icon: Icons.location_on_outlined,
                        title: 'No saved addresses yet',
                        message:
                            'Add your delivery address once and reuse it at checkout.',
                      ),
                    for (final address in data.addresses) ...[
                      SnapAddressTile(
                        label: address.label,
                        recipientName: address.recipientName,
                        addressLine: address.displayLine,
                        selected: data.selectedAddress?.id == address.id,
                        onTap: () => _select(address),
                        onDelete: () => _confirmDelete(address),
                      ),
                      const SizedBox(height: SnapFoodSpacing.sm),
                    ],
                    if (!adding)
                      Padding(
                        padding: const EdgeInsets.only(top: SnapFoodSpacing.xs),
                        child: SnapSecondaryButton(
                          label: 'Add a new address',
                          icon: Icons.add_location_alt_outlined,
                          onPressed: () => _toggleAdding(true),
                        ),
                      ),
                    if (adding) ...[
                      const SizedBox(height: SnapFoodSpacing.sm),
                      _buildForm(),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.md),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add delivery address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: SnapFoodColors.warmBlack,
                        ),
                      ),
                    ),
                    SnapIconButton(
                      icon: Icons.close,
                      onPressed: saving ? null : () => _toggleAdding(false),
                      tooltip: 'Cancel',
                      semanticLabel: 'Cancel adding address',
                    ),
                  ],
                ),
                const SizedBox(height: SnapFoodSpacing.sm),
                const Text(
                  'Use a recognizable label so you can pick this address quickly at checkout.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: SnapFoodColors.onSurfaceVariant,
                  ),
                ),
                if (formError != null) ...[
                  const SizedBox(height: SnapFoodSpacing.md),
                  SnapErrorState(
                    title: 'Could not save address',
                    message: formError!,
                    compact: true,
                  ),
                ],
                const SizedBox(height: SnapFoodSpacing.md),
                _field(label, 'Label (Home, Work…)'),
                _field(recipient, 'Recipient name'),
                _field(line1, 'Address line 1'),
                _field(line2, 'Address line 2', requiredField: false),
                Row(
                  children: [
                    Expanded(child: _field(city, 'City')),
                    const SizedBox(width: SnapFoodSpacing.sm),
                    Expanded(child: _field(state, 'State')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _field(postal, 'Postal code')),
                    const SizedBox(width: SnapFoodSpacing.sm),
                    Expanded(child: _field(country, 'Country')),
                  ],
                ),
                const SizedBox(height: SnapFoodSpacing.sm),
                SnapPrimaryButton(
                  label: saving ? 'Saving…' : 'Save address',
                  icon: saving ? null : Icons.check_rounded,
                  loading: saving,
                  onPressed: saving ? null : _save,
                  semanticLabel: 'Save delivery address',
                ),
              ],
            ),
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String labelText, {
    bool requiredField = true,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: SnapFoodSpacing.sm),
        child: TextFormField(
          controller: controller,
          textInputAction: TextInputAction.next,
          validator: requiredField
              ? (value) => value == null || value.trim().isEmpty
                  ? labelText + ' is required'
                  : null
              : null,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SnapFoodRadii.md),
            ),
          ),
        ),
      );

  void _toggleAdding(bool value) {
    if (!mounted) return;
    setState(() {
      adding = value;
      formError = null;
    });
  }

  void _select(SavedAddress address) {
    ref.read(addressBookControllerProvider.notifier).select(address);
    if (context.canPop()) context.pop();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() {
      saving = true;
      formError = null;
    });

    try {
      final address = await ref
          .read(addressBookControllerProvider.notifier)
          .addAddress({
        'label': label.text.trim(),
        'recipient_name': recipient.text.trim(),
        'address_line1': line1.text.trim(),
        'address_line2':
            line2.text.trim().isEmpty ? null : line2.text.trim(),
        'city': city.text.trim(),
        'state': state.text.trim(),
        'postal_code': postal.text.trim(),
        'country':
            country.text.trim().isEmpty ? 'India' : country.text.trim(),
      });

      if (!mounted || address == null) return;
      setState(() => adding = false);
      if (context.canPop()) context.pop();
    } catch (error) {
      if (mounted) {
        setState(
          () => formError = error is ApiException
              ? error.message
              : 'Could not save this address. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _confirmDelete(SavedAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => SnapAlertDialog(
        title: 'Delete ' + address.label + '?',
        message:
            'This saved address will be removed from your address book. Your existing orders are not changed.',
        confirmLabel: 'Delete',
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await ref
          .read(addressBookControllerProvider.notifier)
          .deleteAddress(address);
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => SnapAlertDialog(
          title: 'Could not delete address',
          message: error is ApiException
              ? error.message
              : 'Please try again.',
          confirmLabel: 'OK',
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () => Navigator.of(dialogContext).pop(),
        ),
      );
    }
  }
}
