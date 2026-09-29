import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_transport.dart';
import '../../../core/network/api_exception.dart';
import '../data/catalogue_models.dart';
import '../data/catalogue_repository.dart';

final catalogueApiTransportProvider = Provider<HttpApiTransport>((ref) {
  final transport = HttpApiTransport();
  ref.onDispose(transport.close);
  return transport;
});

final catalogueApiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ApiConfig.fromEnvironment(),
    transport: ref.watch(catalogueApiTransportProvider),
  );
});

final catalogueRepositoryProvider = Provider<CatalogueRepository>((ref) {
  return RemoteCatalogueRepository(ref.watch(catalogueApiClientProvider));
});

final catalogueControllerProvider =
    AsyncNotifierProvider<CatalogueController, CatalogueSnapshot>(
  CatalogueController.new,
);

class CatalogueController extends AsyncNotifier<CatalogueSnapshot> {
  CatalogueRepository get _repository => ref.read(catalogueRepositoryProvider);

  @override
  Future<CatalogueSnapshot> build() => _load();

  Future<CatalogueSnapshot> _load() async {
    final results = await Future.wait<Object>([
      _repository.fetchCategories(),
      _repository.fetchProducts(),
    ]);

    return CatalogueSnapshot(
      categories: results[0] as List<CatalogueCategory>,
      products: results[1] as CataloguePage,
    );
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<CatalogueSnapshot>();
    state = await AsyncValue.guard(_load);
  }

  String messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'We could not load the catalogue. Please try again.';
  }
}
