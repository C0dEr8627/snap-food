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
import '../data/cart_models.dart';
import '../data/order_models.dart';
import 'cart_controller.dart';
import 'order_controller.dart';
import 'address_book_controller.dart';

final directCheckoutItemsProvider = StateProvider<List<CartItem>?>((ref) => null);

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
    final directItems = ref.watch(directCheckoutItemsProvider);
    final checkoutItems = directItems ?? cart.items;
    final checkoutItemCount = checkoutItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final checkoutSubtotal = checkoutItems.fold<int>(0, (sum, item) => sum + item.previewPrice * item.quantity);
    final checkoutState = ref.watch(orderCheckoutControllerProvider);
    final addressState = ref.watch(addressBookControllerProvider);
    final savedAddress = addressState.value?.selectedAddress;
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
                padding: const EdgeInsets.fromLTRB(
                  SnapFoodSpacing.md,
                  SnapFoodSpacing.sm,
                  SnapFoodSpacing.md,
                  132,
                ),
                children: [
                  Row(
                    children: [
                      SnapIconButton(
                        icon: Icons.arrow_back,
                        onPressed: isSubmitting ? null : () => context.pop(),
                        tooltip: 'Back',
                        semanticLabel: 'Back to cart',
                      ),
                      const SizedBox(width: SnapFoodSpacing.sm),
                      const Expanded(
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: SnapFoodColors.warmBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SnapFoodSpacing.lg),
                  SnapSectionHeader(
                    title: 'Delivery address',
                    subtitle: savedAddress == null
                        ? 'Choose where your order should be delivered.'
                        : 'Your selected delivery destination.',
                  ),
                  const SizedBox(height: SnapFoodSpacing.sm),
                  if (savedAddress != null)
                    _SelectedAddressCard(
                      address: savedAddress,
                      onChange: isSubmitting ? null : () => context.push('/addresses'),
                    )
                  else ...[
                    const _CheckoutNotice(
                      icon: Icons.location_on_outlined,
                      title: 'No saved address selected',
                      message: 'Add a delivery address to continue.',
                    ),
                    const SizedBox(height: SnapFoodSpacing.md),
                    _field(_label, 'Label'),
                    _field(_recipient, 'Recipient name'),
                    _field(_line1, 'Address line 1'),
                    _field(_line2, 'Address line 2', requiredField: false),
                    Row(
                      children: [
                        Expanded(child: _field(_city, 'City')),
                        const SizedBox(width: SnapFoodSpacing.sm),
                        Expanded(child: _field(_state, 'State')),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field(_postal, 'Postal code')),
                        const SizedBox(width: SnapFoodSpacing.sm),
                        Expanded(child: _field(_country, 'Country')),
                      ],
                    ),
                  ],
                  const SizedBox(height: SnapFoodSpacing.xl),
                  SnapSectionHeader(
                    title: directItems == null ? 'Order summary' : 'Order now · single item checkout',
                    subtitle: checkoutItemCount.toString() +
                        ' item' +
                        (checkoutItemCount == 1 ? '' : 's'),
                  ),
                  const SizedBox(height: SnapFoodSpacing.sm),
                  if (checkoutItems.isEmpty)
                    const _CheckoutNotice(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Your cart is empty',
                      message: 'Add dishes before placing an order.',
                    )
                  else
                    _CheckoutSummary(items: checkoutItems),
                  const SizedBox(height: SnapFoodSpacing.xl),
                  SnapSectionHeader(
                    title: 'Payment method',
                    subtitle: 'The available payment method for checkout.',
                  ),
                  const SizedBox(height: SnapFoodSpacing.sm),
                  const _PaymentMethodTile(),
                  const SizedBox(height: SnapFoodSpacing.xl),
                  SnapSectionHeader(
                    title: 'Price breakdown',
                    subtitle:
                        'Preview only — final charges are calculated by the server.',
                  ),
                  const SizedBox(height: SnapFoodSpacing.sm),
                  _PriceBreakdown(previewSubtotal: checkoutSubtotal),
                  if (apiError != null) ...[
                    const SizedBox(height: SnapFoodSpacing.md),
                    _ErrorBox(error: apiError),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SnapFoodSpacing.md,
            SnapFoodSpacing.sm,
            SnapFoodSpacing.md,
            SnapFoodSpacing.md,
          ),
          child: SnapPrimaryButton(
            label: isSubmitting ? 'Placing order…' : 'Place COD order',
            icon: isSubmitting ? null : Icons.check_rounded,
            loading: isSubmitting,
            onPressed: isSubmitting || checkoutItems.isEmpty ? null : _submit,
            semanticLabel: 'Place cash on delivery order',
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
    final savedAddress = ref.read(addressBookControllerProvider).value?.selectedAddress;
    if (savedAddress == null && !_formKey.currentState!.validate()) return;
    final directItems = ref.read(directCheckoutItemsProvider);
    final checkoutItems = directItems ?? ref.read(cartControllerProvider).items;
    final lines = <OrderLineRequest>[];
    for (final item in checkoutItems) {
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

    DeliveryAddress deliveryAddress;
    if (savedAddress != null) {
      deliveryAddress = savedAddress.toDeliveryAddress();
    } else {
      try {
        final created = await ref.read(addressBookControllerProvider.notifier).addAddress({
          'label': _label.text.trim(),
          'recipient_name': _recipient.text.trim(),
          'address_line1': _line1.text.trim(),
          'address_line2': _line2.text.trim().isEmpty ? null : _line2.text.trim(),
          'city': _city.text.trim(),
          'state': _state.text.trim(),
          'postal_code': _postal.text.trim(),
          'country': _country.text.trim().isEmpty ? 'India' : _country.text.trim(),
        });
        if (created == null) {
          _showMessage('Could not save the delivery address.');
          return;
        }
        deliveryAddress = created.toDeliveryAddress();
      } catch (error) {
        _showMessage(error is ApiException ? error.message : 'Could not save the delivery address.');
        return;
      }
    }

    final order = await ref
        .read(orderCheckoutControllerProvider.notifier)
        .submit(CreateOrderRequest(items: lines, deliveryAddress: deliveryAddress));
    if (!mounted || order == null) return;
    if (directItems != null) {
      ref.read(directCheckoutItemsProvider.notifier).state = null;
    } else {
      ref.read(cartControllerProvider.notifier).clear();
    }
    context.go('/orders/${Uri.encodeComponent(order.id)}');
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _SelectedAddressCard extends StatelessWidget {
  const _SelectedAddressCard({required this.address, this.onChange});

  final SavedAddress address;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.secondary),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, color: SnapFoodColors.secondary, size: 22),
              const SizedBox(width: SnapFoodSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.label,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SnapFoodColors.warmBlack),
                          ),
                        ),
                        if (onChange != null)
                          TextButton(onPressed: onChange, child: const Text('Change')),
                      ],
                    ),
                    Text(
                      address.recipientName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SnapFoodColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: SnapFoodSpacing.xs),
                    Text(
                      address.displayLine,
                      style: const TextStyle(fontSize: 13, height: 1.35, color: SnapFoodColors.warmBlack),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({required this.items});
  final List<CartItem> items;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _CheckoutItem(item: items[index]),
              if (index != items.length - 1)
                const Divider(height: 1, color: SnapFoodColors.softBorder),
            ],
          ],
        ),
      );
}

class _CheckoutItem extends StatelessWidget {
  const _CheckoutItem({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.previewPrice * item.quantity;
    return Padding(
      padding: const EdgeInsets.all(SnapFoodSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SnapFoodColors.warmBlack)),
                const SizedBox(height: SnapFoodSpacing.xs),
                Text('Qty ' + item.quantity.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SnapFoodColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: SnapFoodSpacing.md),
          SnapPrice(value: lineTotal.toString(), fontSize: 15),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile();

  @override
  Widget build(BuildContext context) => Semantics(
        selected: true,
        label: 'Cash on delivery, selected',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SnapFoodColors.softYellow,
            borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
            border: Border.all(color: SnapFoodColors.goldenYellow, width: 1.5),
          ),
          child: const Padding(
            padding: EdgeInsets.all(SnapFoodSpacing.md),
            child: Row(
              children: [
                Icon(Icons.payments_outlined, color: SnapFoodColors.secondary),
                SizedBox(width: SnapFoodSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cash on delivery', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SnapFoodColors.warmBlack)),
                      SizedBox(height: SnapFoodSpacing.xs),
                      Text(
                        'Payment method is fixed to COD by the current API contract.',
                        style: TextStyle(fontSize: 12, height: 1.3, color: SnapFoodColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded, color: SnapFoodColors.secondary),
              ],
            ),
          ),
        ),
      );
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.previewSubtotal});
  final int previewSubtotal;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.md),
          child: Column(
            children: [
              _PriceRow(label: 'Items subtotal (preview)', value: previewSubtotal.toString()),
              const SizedBox(height: SnapFoodSpacing.sm),
              const _PriceRow(
                label: 'Delivery fee & final charges',
                value: 'Calculated at checkout',
                emphasizeValue: false,
              ),
              const Divider(height: SnapFoodSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Final total',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SnapFoodColors.warmBlack),
                    ),
                  ),
                  const Flexible(
                    child: Text(
                      'Confirmed after order',
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SnapFoodColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SnapFoodSpacing.sm),
              const Text(
                'The server recalculates the final order amount when the order is placed. The preview above is not a promise of the final total.',
                style: TextStyle(fontSize: 11, height: 1.35, color: SnapFoodColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.emphasizeValue = true});
  final String label;
  final String value;
  final bool emphasizeValue;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: SnapFoodColors.onSurfaceVariant)),
          ),
          const SizedBox(width: SnapFoodSpacing.md),
          if (emphasizeValue)
            SnapPrice(value: value, fontSize: 14)
          else
            Flexible(
              child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SnapFoodColors.onSurfaceVariant)),
            ),
        ],
      );
}

class _CheckoutNotice extends StatelessWidget {
  const _CheckoutNotice({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainer,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SnapFoodSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: SnapFoodColors.secondary),
              const SizedBox(width: SnapFoodSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: SnapFoodSpacing.xs),
                    Text(message, style: const TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final api = error is ApiException ? error as ApiException : null;
    final message = api?.message ?? 'We could not place the order. Please try again.';
    final code = api?.code;
    return SnapErrorState(
      title: 'Could not place order',
      message: code == null || code.isEmpty ? message : message + ' (' + code + ')',
      compact: true,
    );
  }
}
