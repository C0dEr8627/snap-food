import '../../../core/network/api_client.dart';
import 'catalogue_models.dart';

abstract interface class FavoriteRepository {
  Future<List<CatalogueProduct>> fetchFavorites();
  Future<void> addFavorite(int productId);
  Future<void> removeFavorite(int productId);
}

class RemoteFavoriteRepository implements FavoriteRepository {
  const RemoteFavoriteRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<CatalogueProduct>> fetchFavorites() async {
    final response = await _client.get('/favorites');
    if (response is! Map<String, dynamic> || response['data'] is! List) {
      throw const FormatException('Invalid favorites response.');
    }
    return (response['data'] as List)
        .whereType<Map>()
        .map((item) => CatalogueProduct.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> addFavorite(int productId) async {
    await _client.post('/favorites/$productId');
  }

  @override
  Future<void> removeFavorite(int productId) async {
    await _client.request('DELETE', '/favorites/$productId');
  }
}
