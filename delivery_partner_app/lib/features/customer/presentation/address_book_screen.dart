import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'address_book_controller.dart';

class AddressBookScreen extends ConsumerStatefulWidget {
  const AddressBookScreen({super.key});

  @override
  ConsumerState<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends ConsumerState<AddressBookScreen> {
  bool adding = false;
  bool saving = false;
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
    for (final controller in [label, recipient, line1, line2, city, state, postal, country]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = ref.watch(addressBookControllerProvider);
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      appBar: AppBar(
        title: const Text('Delivery addresses', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: SnapFoodColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: book.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_off_outlined, size: 40),
              const SizedBox(height: 10),
              const Text('Could not load your saved addresses.'),
              TextButton(onPressed: () => ref.read(addressBookControllerProvider.notifier).refresh(), child: const Text('Try again')),
            ]),
          ),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            if (data.addresses.isEmpty && !adding)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: const Column(children: [
                  Icon(Icons.location_on_outlined, size: 38, color: SnapFoodColors.secondary),
                  SizedBox(height: 8),
                  Text('No saved addresses yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Add your delivery address to use it across the app.', textAlign: TextAlign.center),
                ]),
              ),
            for (final address in data.addresses)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: data.selectedAddress?.id == address.id ? SnapFoodColors.secondary : SnapFoodColors.outline.withAlpha(35), width: data.selectedAddress?.id == address.id ? 1.5 : 1),
                ),
                child: ListTile(
                  onTap: () {
                    ref.read(addressBookControllerProvider.notifier).select(address);
                    context.pop();
                  },
                  leading: Icon(data.selectedAddress?.id == address.id ? Icons.radio_button_checked : Icons.location_on_outlined, color: SnapFoodColors.secondary),
                  title: Text(address.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${address.recipientName}\n${address.displayLine}'),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Delete address',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _delete(address),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => setState(() => adding = !adding),
              icon: Icon(adding ? Icons.close : Icons.add_location_alt_outlined),
              label: Text(adding ? 'Cancel adding address' : 'Add a new address'),
            ),
            if (adding) ...[
              const SizedBox(height: 14),
              Form(
                key: formKey,
                child: Column(children: [
                  _field(label, 'Label (Home, Work...)'),
                  _field(recipient, 'Recipient name'),
                  _field(line1, 'Address line 1'),
                  _field(line2, 'Address line 2', requiredField: false),
                  Row(children: [Expanded(child: _field(city, 'City')), const SizedBox(width: 8), Expanded(child: _field(state, 'State'))]),
                  Row(children: [Expanded(child: _field(postal, 'Postal code')), const SizedBox(width: 8), Expanded(child: _field(country, 'Country'))]),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: saving ? null : _save,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: SnapFoodColors.secondary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.md))),
                    child: Text(saving ? 'Saving…' : 'Save address'),
                  ),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String labelText, {bool requiredField = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      validator: requiredField ? (value) => value == null || value.trim().isEmpty ? '$labelText is required' : null : null,
      decoration: InputDecoration(labelText: labelText, border: const OutlineInputBorder()),
    ),
  );

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    try {
      final address = await ref.read(addressBookControllerProvider.notifier).addAddress({
        'label': label.text.trim(),
        'recipient_name': recipient.text.trim(),
        'address_line1': line1.text.trim(),
        'address_line2': line2.text.trim().isEmpty ? null : line2.text.trim(),
        'city': city.text.trim(),
        'state': state.text.trim(),
        'postal_code': postal.text.trim(),
        'country': country.text.trim().isEmpty ? 'India' : country.text.trim(),
      });
      if (!mounted || address == null) return;
      setState(() => adding = false);
      context.pop();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'Could not save this address. Please try again.')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _delete(SavedAddress address) async {
    try {
      await ref.read(addressBookControllerProvider.notifier).deleteAddress(address);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error is ApiException ? error.message : 'Could not delete this address.')));
    }
  }
}
