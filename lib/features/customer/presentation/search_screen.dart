import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import 'home_feed_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  String query = '';

  static const categories = [
    (Icons.rice_bowl, 'Biryani'),
    (Icons.local_pizza, 'Pizza'),
    (Icons.lunch_dining, 'Burgers'),
    (Icons.tapas, 'Street Food'),
    (Icons.coffee, 'Cafés'),
    (Icons.icecream, 'Desserts'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = HomeFeedScreenStateData.restaurants
        .where((r) => query.isEmpty || r.name.toLowerCase().contains(query.toLowerCase()) || r.cuisines.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      onChanged: (value) => setState(() => query = value),
                      decoration: InputDecoration(
                        hintText: 'Search dishes, restaurants...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(onPressed: () { controller.clear(); setState(() => query = ''); }, icon: const Icon(Icons.close)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.tune)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Search by craving', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 102,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => InkWell(
                          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
                          onTap: () { controller.text = categories[i].$2; setState(() => query = categories[i].$2); },
                          child: Container(
                            width: 82,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg), border: Border.all(color: SnapFoodColors.softBorder)),
                            child: Column(children: [
                              Container(width: 46, height: 46, decoration: const BoxDecoration(color: SnapFoodColors.primaryContainer, shape: BoxShape.circle), child: Icon(categories[i].$1, color: SnapFoodColors.secondary)),
                              const SizedBox(height: 6),
                              Text(categories[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(child: Text(query.isEmpty ? 'Popular near you' : 'Results for “$query”', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                      if (query.isNotEmpty) Text('${results.length} places', style: const TextStyle(fontSize: 11, color: SnapFoodColors.outline)),
                    ]),
                    const SizedBox(height: 12),
                    if (results.isEmpty)
                      _EmptySearch(query: query)
                    else
                      ...results.map((restaurant) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SearchResultCard(restaurant: restaurant),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(selected: 1, onSelected: _noop),
    );
  }

  static void _noop(int _) {}
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.restaurant});
  final RestaurantMock restaurant;

  @override
  Widget build(BuildContext context) => Material(
    color: SnapFoodColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    child: InkWell(
      borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
      onTap: () => context.push('/restaurant'),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(SnapFoodRadii.md),
            child: SizedBox(width: 78, height: 78, child: Image.network(restaurant.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: SnapFoodColors.softRed, child: Icon(restaurant.icon, color: SnapFoodColors.secondary, size: 30)))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(restaurant.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(restaurant.cuisines, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
            const SizedBox(height: 7),
            Row(children: [
              const Icon(Icons.star, size: 14, color: SnapFoodColors.primary),
              const SizedBox(width: 3),
              Text(restaurant.rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text(restaurant.time, style: const TextStyle(fontSize: 11, color: SnapFoodColors.outline)),
              const SizedBox(width: 8),
              Text(restaurant.distance, style: const TextStyle(fontSize: 11, color: SnapFoodColors.outline)),
            ]),
          ])),
          const Icon(Icons.chevron_right, color: SnapFoodColors.outline),
        ]),
      ),
    ),
  );
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg)),
    child: Column(children: [
      const Icon(Icons.search_off, size: 42, color: SnapFoodColors.outline),
      const SizedBox(height: 12),
      Text('No matches for “$query”', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Try a dish, cuisine, or restaurant name.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant)),
    ]),
  );
}

abstract final class HomeFeedScreenStateData {
  static const restaurants = <RestaurantMock>[
    RestaurantMock('Mumbai Spice Kitchen • Andheri West', '4.8', '(1.2k+)', 'North Indian, Biryani, Mughlai', '20–25 mins', '1.8 km', 'Free Delivery on ₹249+', 'Special Butter Chicken & Naan Combo', '₹340', Icons.restaurant, 'https://lh3.googleusercontent.com/aida-public/AB6AXuCI8nFpldvx74-Of_l9s9jlewdgZKH18nVcu_GjT5unSeQsgHmaE2cDY_AjhVM5ogkaeDrk8hmiMl_QCntZj0ecfBVFpzMbiZNbAv5ugrK5FYsMx5XAHCEnWuE30jPap1Mz_rfQeFZvmnrA0qq-QD3fnmMPXuSdEI_yS_f2VeDedcwg2oUUPYPtT3miN-Dil1_weROneWtrTKK9s6ZOOHV9tuQotGSVPR0cfbmVdNzMH5tOzDMRLAcb'),
    RestaurantMock('The Bombay Tiffin • Juhu', '4.9', '(2.1k+)', 'Maharashtrian, Mumbai Street Food', '25–30 mins', '2.4 km', 'Free Extra Pav on ₹199+', 'Special Butter Pav Bhaji (2 Pav)', '₹140', Icons.lunch_dining, 'https://lh3.googleusercontent.com/aida-public/AB6AXuBbdGjfpMkfgJSqTJT4ni_7blK_IdTaFAbuDHIW2z_EnpYpUEt5ggg1eh7TcCOmakuIfPMUPHZxPp4Wxl5pv1YESdGqNNkbQ-zjTse61hJCjo7J3RShtExpfH6IwexkRHb7uBWimoc3iKFv3-f3g5LWkYJ9RE_3p-1Lg95gcRqZyko7jEmCmd0ws2aw7AtQYlzziRR1bb4QfamSkpnlFXMbHCngbWe7A2Y1TwheNwVqPO-IFzzjKz1C6'),
    RestaurantMock('Coastal Curry & Dosa House • Bandra', '4.7', '(890+)', 'South Indian, Coastal, Snacks', '20–25 mins', '2.1 km', 'Lightning Fast', 'Ghee Roast Masala Dosa', '₹160', Icons.restaurant_menu, 'https://lh3.googleusercontent.com/aida-public/AB6AXuAVDGZyQbP2xa-fXfa2P96qMami9MdsUAkpONQm3qw3_fpYBOtW0RjXh25ya9amXUd_v4Z56vxRVVn_04B-HmD5WQB8jZJEcA6VGhe5MWWl2byhRDQF82Ax6N46T8tPmjE11BDcQfe7Ksf0AcHmcTpD8SOCuesQqYWIjz_V5twrCz2u4B6WYexUUJZtiKNcrb15OkJFQhKQXr4i325P7L4h5EMt-zlsK9-vhRztlk12LvDjNWqWm8Ah'),
  ];
}
