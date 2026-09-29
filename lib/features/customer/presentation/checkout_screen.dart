import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../data/order_models.dart';
import 'cart_controller.dart';
import 'order_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController(text: 'Home');
  final _recipient = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController(text: 'Mumbai');
  final _state = TextEditingController(text: 'Maharashtra');
  final _postal = TextEditingController();
  final _country = TextEditingController(text: 'India');

  @override
  void dispose() {
    for (final controller in [
      _label,
      _recipient,
      _line1,
      _line2,
      _city,
      _state,
      _postal,
      _country,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final checkoutState = ref.watch(orderCheckoutControllerProvider);
    final isSubmitting = checkoutState.value?.isSubmitting == true;
    final apiError = checkoutState.hasError ? checkoutState.error : null;

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: SnapFoodSpacing.desktopMaxContentWidth,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: isSubmitting ? null : () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Delivery address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  _field(_label, 'Label'),
                  _field(_recipient, 'Recipient name'),
                  _field(_line1, 'Address line 1'),
                  _field(_line2, 'Address line 2', requiredField: false),
                  Row(
                    children: [
                      Expanded(child: _field(_city, 'City')),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_state, 'State')),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field(_postal, 'Postal code')),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_country, 'Country')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.payments_outlined,
                      color: SnapFoodColors.secondary,
                    ),
                    title: Text(
                      'Cash on delivery',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'Payment method is fixed to COD by the current API contract.',
                    ),
                    trailing: Icon(
                      Icons.radio_button_checked,
                      color: SnapFoodColors.secondary,
                    ),
                  ),
                  if (apiError != null) ...[
                    const SizedBox(height: 10),
                    _ErrorBox(error: apiError),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Final amount is calculated by the server after checkout.',
                    style: TextStyle(
                      fontSize: 11,
                      color: SnapFoodColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: isSubmitting || cart.items.isEmpty ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: SnapFoodColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SnapFoodRadii.md),
              ),
            ),
            child: Text(isSubmitting ? 'Placing order…' : 'Place COD order'),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool requiredField = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      validator: requiredField
          ? (value) => value == null || value.trim().isEmpty
                ? '\$label is required'
                : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = ref.read(cartControllerProvider);
    final lines = <OrderLineRequest>[];
    for (final item in cart.items) {
      final productId = int.tryParse(item.productId);
      if (productId == null || productId <= 0) {
        _showMessage(
          'Cart item ${item.name} has no valid catalogue product ID yet.',
        );
        return;
      }
      if (item.quantity < 1 || item.quantity > 99) {
        _showMessage('Each item quantity must be between 1 and 99.');
        return;
      }
      lines.add(
        OrderLineRequest(productId: productId, quantity: item.quantity),
      );
    }

    final order = await ref
        .read(orderCheckoutControllerProvider.notifier)
        .submit(
          CreateOrderRequest(
            items: lines,
            deliveryAddress: DeliveryAddress(
              label: _label.text.trim(),
              recipientName: _recipient.text.trim(),
              addressLine1: _line1.text.trim(),
              addressLine2: _line2.text.trim().isEmpty
                  ? null
                  : _line2.text.trim(),
              city: _city.text.trim(),
              state: _state.text.trim(),
              postalCode: _postal.text.trim(),
              country: _country.text.trim(),
            ),
          ),
        );
    if (!mounted || order == null) return;
    ref.read(cartControllerProvider.notifier).clear();
    context.go('/orders/${Uri.encodeComponent(order.id)}');
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) {
    final api = error is ApiException ? error as ApiException : null;
    final message =
        api?.message ?? 'We could not place the order. Please try again.';
    final code = api?.code;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SnapFoodColors.softRed,
        borderRadius: BorderRadius.circular(SnapFoodRadii.md),
      ),
      child: Text(
        code == null || code.isEmpty ? message : '$message ($code)',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
