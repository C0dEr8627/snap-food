import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/order_models.dart';
import 'order_controller.dart';

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String label;
  final String recipientName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;

  String get displayLine => [addressLine1, addressLine2, city, state, postalCode]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(', ');

  DeliveryAddress toDeliveryAddress() => DeliveryAddress(
    label: label,
    recipientName: recipientName,
    addressLine1: addressLine1,
    addressLine2: addressLine2,
    city: city,
    state: state,
    postalCode: postalCode,
    country: country,
    latitude: latitude,
    longitude: longitude,
  );

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    double? number(Object? value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
    return SavedAddress(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      label: json['label']?.toString() ?? 'Address',
      recipientName: json['recipient_name']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      latitude: number(json['latitude']),
      longitude: number(json['longitude']),
    );
  }
}

final addressBookControllerProvider =
    AsyncNotifierProvider<AddressBookController, AddressBookState>(AddressBookController.new);

class AddressBookState {
  const AddressBookState({this.addresses = const [], this.selectedAddress});
  final List<SavedAddress> addresses;
  final SavedAddress? selectedAddress;
}

class AddressBookController extends AsyncNotifier<AddressBookState> {
  @override
  Future<AddressBookState> build() => _fetch();

  Future<AddressBookState> _fetch() async {
    // Address state is account-scoped. Watching the authenticated customer id
    // forces this provider to rebuild when one customer signs out and another
    // signs in, preventing the previous customer's in-memory address list
    // from being rendered for the new account.
    ref.watch(authUserIdProvider);
    final response = await ref.read(orderApiClientProvider).get('/addresses');
    final raw = response is Map ? response['data'] : null;
    final addresses = raw is List
        ? raw.whereType<Map>().map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item))).toList(growable: false)
        : const <SavedAddress>[];
    final selectedId = state.value?.selectedAddress?.id;
    SavedAddress? selected;
    for (final address in addresses) { if (address.id == selectedId) { selected = address; break; } }
    selected ??= addresses.isNotEmpty ? addresses.first : null;
    return AddressBookState(addresses: addresses, selectedAddress: selected);
  }

  void select(SavedAddress address) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(AddressBookState(addresses: current.addresses, selectedAddress: address));
  }

  Future<SavedAddress?> addAddress(Map<String, Object?> values) async {
    try {
      final response = await ref.read(orderApiClientProvider).post('/addresses', body: values);
      final raw = response is Map ? response['data'] : null;
      if (raw is! Map) throw const ApiException(message: 'The server returned an unexpected address response.', code: 'INVALID_RESPONSE');
      final address = SavedAddress.fromJson(Map<String, dynamic>.from(raw));
      final current = state.value ?? const AddressBookState();
      state = AsyncData(AddressBookState(addresses: [address, ...current.addresses], selectedAddress: address));
      return address;
    } on ApiException {
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> deleteAddress(SavedAddress address) async {
    await ref.read(orderApiClientProvider).request('DELETE', '/addresses/${address.id}');
    final current = state.value ?? const AddressBookState();
    final remaining = current.addresses.where((item) => item.id != address.id).toList(growable: false);
    state = AsyncData(AddressBookState(
      addresses: remaining,
      selectedAddress: current.selectedAddress?.id == address.id ? (remaining.isEmpty ? null : remaining.first) : current.selectedAddress,
    ));
  }
}
