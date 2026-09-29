import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/tokens/app_colors.dart';
import 'catalogue_controller.dart';
import 'catalogue_state_message.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  int filter = 0;
  int nav = 0;
  final favorites = <int>{};

  static const filterNames = ['Filters', 'Under 25 mins', 'Rating 4.5+', 'Great Offers', 'Pure Veg'];

  static const restaurants = [
    RestaurantMock('Mumbai Spice Kitchen • Andheri West', '4.8', '(1.2k+)', 'North Indian, Biryani, Mughlai', '20–25 mins', '1.8 km', 'Free Delivery on ₹249+', 'Special Butter Chicken & Naan Combo', '₹340', Icons.restaurant, 'https://lh3.googleusercontent.com/aida-public/AB6AXuCI8nFpldvx74-Of_l9s9jlewdgZKH18nVcu_GjT5unSeQsgHmaE2cDY_AjhVM5ogkaeDrk8hmiMl_QCntZj0ecfBVFpzMbiZNbAv5ugrK5FYsMx5XAHCEnWuE30jPap1Mz_rfQeFZvmnrA0qq-QD3fnmMPXuSdEI_yS_f2VeDedcwg2oUUPYPtT3miN-Dil1_weROneWtrTKK9s6ZOOHV9tuQotGSVPR0cfbmVdNzMH5tOzDMRLAcb'),
    RestaurantMock('The Bombay Tiffin • Juhu', '4.9', '(2.1k+)', 'Maharashtrian, Mumbai Street Food', '25–30 mins', '2.4 km', 'Free Extra Pav on ₹199+', 'Special Butter Pav Bhaji (2 Pav)', '₹140', Icons.lunch_dining, 'https://lh3.googleusercontent.com/aida-public/AB6AXuBbdGjfpMkfgJSqTJT4ni_7blK_IdTaFAbuDHIW2z_EnpYpUEt5ggg1eh7TcCOmakuIfPMUPHZxPp4Wxl5pv1YESdGqNNkbQ-zjTse61hJCjo7J3RShtExpfH6IwexkRHb7uBWimoc3iKFv3-f3g5LWkYJ9RE_3p-1Lg95gcRqZyko7jEmCmd0ws2aw7AtQYlzziRR1bb4QfamSkpnlFXMbHCngbWe7A2Y1TwheNwVqPO-IFzzjKz1C6'),
    RestaurantMock('Coastal Curry & Dosa House • Bandra', '4.7', '(890+)', 'South Indian, Coastal, Snacks', '20–25 mins', '2.1 km', 'Lightning Fast', 'Ghee Roast Masala Dosa', '₹160', Icons.restaurant_menu, 'https://lh3.googleusercontent.com/aida-public/AB6AXuAVDGZyQbP2xa-fXfa2P96qMami9MdsUAkpONQm3qw3_fpYBOtW0RjXh25ya9amXUd_v4Z56vxRVVn_04B-HmD5WQB8jZJEcA6VGhe5MWWl2byhRDQF82Ax6N46T8tPmjE11BDcQfe7Ksf0AcHmcTpD8SOCuesQqYWIjz_V5twrCz2u4B6WYexUUJZtiKNcrb15OkJFQhKQXr4i325P7L4h5EMt-zlsK9-vhRztlk12LvDjNWqWm8Ah'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: SafeArea(
          bottom: false,
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= 1024;
          return Stack(children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 76, bottom: 88 + MediaQuery.paddingOf(context).bottom),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: SnapFoodSpacing.desktopMaxContentWidth),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Greeting(),
                        Consumer(builder: (context, ref, _) {
                          final catalogue = ref.watch(catalogueControllerProvider);
                          return CatalogueStateMessage(
                            value: catalogue,
                            onRetry: () => ref.read(catalogueControllerProvider.notifier).retry(),
                          );
                        }),
                        const SizedBox(height: 16),
                        SearchFilters(selected: filter, onSelected: (v) => setState(() => filter = v)),
                        const SizedBox(height: 20),
                        const Cravings(),
                        const SizedBox(height: 20),
                        const WelcomeOffer(),
                        const SizedBox(height: 20),
                        const QuickReorder(),
                        const SizedBox(height: 24),
                        Featured(restaurants: restaurants, favorites: favorites, onFavorite: (i) => setState(() {
                          if (!favorites.add(i)) favorites.remove(i);
                        })),
                        const SizedBox(height: 16),
                        const ExpressBar(),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(top: 0, left: 0, right: 0, child: HomeHeader()),
            Positioned(left: 0, right: 0, bottom: 0, child: BottomNav(selected: nav, onSelected: (v) => setState(() => nav = v))),
            ]);
          }),
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader();
  @override
  Widget build(BuildContext context) => Material(
    color: SnapFoodColors.surface.withAlpha(242),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(height: 64, child: Row(children: [
        Expanded(child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: SnapFoodColors.surfaceContainer, borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
          child: const Row(children: [
            Icon(Icons.location_on, size: 18, color: SnapFoodColors.secondary),
            SizedBox(width: 6),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DELIVER TO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: SnapFoodColors.outline)),
              Text('Andheri West, Mumbai • Flat 402, Sunshine Apts', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ])),
            Icon(Icons.expand_more, size: 18, color: SnapFoodColors.outline),
          ]),
        )),
        const SizedBox(width: 8),
        Stack(children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          Positioned(top: 9, right: 9, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: SnapFoodColors.secondary, shape: BoxShape.circle, border: Border.all(color: SnapFoodColors.surface, width: 2)))),
        ]),
        Container(width: 36, height: 36, decoration: const BoxDecoration(color: SnapFoodColors.primaryContainer, shape: BoxShape.circle), child: const Icon(Icons.person, size: 20, color: SnapFoodColors.warmBlack)),
      ]),
    ),
    ),
  );
}

class Greeting extends StatelessWidget {
  const Greeting();
  @override
  Widget build(BuildContext context) => const Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Good afternoon, Alex! 🍕', style: TextStyle(fontSize: 20, height: 1.3, fontWeight: FontWeight.w700)),
      SizedBox(height: 3),
      Text('What are you craving today?', style: TextStyle(fontSize: 14, color: SnapFoodColors.onSurfaceVariant)),
    ])),
    FastBadge(),
  ]);
}

class FastBadge extends StatelessWidget {
  const FastBadge();
  @override
  Widget build(BuildContext context) => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(color: SnapFoodColors.primaryContainer.withAlpha(80), shape: BoxShape.circle),
    child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
      const Icon(Icons.two_wheeler, color: SnapFoodColors.secondary, size: 26),
      Positioned(right: -3, bottom: -3, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(color: SnapFoodColors.secondary, borderRadius: BorderRadius.circular(8)),
        child: const Text('FAST', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)),
      )),
    ]),
  );
}

class SearchFilters extends StatelessWidget {
  const SearchFilters({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      const Expanded(child: TextField(decoration: InputDecoration(
        hintText: 'Search dishes, restaurants (e.g. Biryani, Pav Bhaji)...',
        prefixIcon: Icon(Icons.search), suffixIcon: Icon(Icons.mic_none),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ))),
      const SizedBox(width: 8),
      SizedBox(width: 48, height: 48, child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(backgroundColor: SnapFoodColors.primaryContainer, foregroundColor: SnapFoodColors.warmBlack, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.md))),
        child: const Icon(Icons.tune),
      )),
    ]),
    const SizedBox(height: 8),
    SizedBox(height: 34, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: HomeFeedScreenState.filters.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => FilterChip(
        selected: selected == i, showCheckmark: false, onSelected: (_) => onSelected(i),
        backgroundColor: SnapFoodColors.surfaceContainerLowest, selectedColor: SnapFoodColors.surfaceContainerHigh, side: BorderSide.none,
        shape: const StadiumBorder(),
        avatar: Icon([Icons.tune, Icons.bolt, Icons.star, Icons.local_offer, Icons.eco][i], size: 15, color: i == 2 ? SnapFoodColors.primary : SnapFoodColors.secondary),
        label: Text(HomeFeedScreenState.filters[i]),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    )),
  ]);
}

abstract final class HomeFeedScreenState {
  static const filters = ['Filters', 'Under 25 mins', 'Rating 4.5+', 'Great Offers', 'Pure Veg'];
}

class Cravings extends StatelessWidget {
  const Cravings();
  static const items = [
    (Icons.rice_bowl, 'Biryani'), (Icons.tapas, 'Street Food'), (Icons.kebab_dining, 'Rolls & Frankie'),
    (Icons.dinner_dining, 'South Indian'), (Icons.lunch_dining, 'Burgers'), (Icons.local_pizza, 'Pizza'),
  ];
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('Explore Cravings'),
    const SizedBox(height: 12),
    SizedBox(height: 94, child: ListView.separated(
      scrollDirection: Axis.horizontal, itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (_, i) => SizedBox(width: 72, child: Column(children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: i == 0 ? SnapFoodColors.primaryContainer : SnapFoodColors.surfaceContainerLowest,
            shape: BoxShape.circle, border: Border.all(color: SnapFoodColors.softBorder),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Icon(items[i].$1, size: 28, color: SnapFoodColors.secondary),
            if (i == 0) Positioned(top: 0, right: 0, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: SnapFoodColors.secondary, borderRadius: BorderRadius.circular(5)),
              child: const Text('HOT', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white)),
            )),
          ]),
        ),
        const SizedBox(height: 6),
        Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ])),
    )),
  ]);
}

class WelcomeOffer extends StatelessWidget {
  const WelcomeOffer();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: SnapFoodColors.primaryContainer, borderRadius: BorderRadius.circular(SnapFoodRadii.lg)),
    child: Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('WELCOME TREAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        SizedBox(height: 4),
        Text('Get ₹150 OFF', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text('on your first 3 orders', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('SNAP150  •  Over ₹299', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ])),
      FilledButton.tonal(onPressed: () {}, child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Claim Discount', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        SizedBox(width: 4), Icon(Icons.arrow_forward, size: 15),
      ])),
    ]),
  );
}

class QuickReorder extends StatelessWidget {
  const QuickReorder();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionTitle('Quick Re-order', trailing: 'Last week'),
    const SizedBox(height: 10),
    Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg), boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 5, offset: Offset(0, 2))]),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: SnapFoodColors.softRed, borderRadius: BorderRadius.circular(SnapFoodRadii.md)), child: const Icon(Icons.ramen_dining, color: SnapFoodColors.secondary, size: 28)),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Chicken Dum Biryani (Single)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          SizedBox(height: 2),
          Text('The Bombay Tiffin • Andheri West', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
          SizedBox(height: 2), Text('₹260  •  1x Single', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        ])),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.replay, size: 15), label: const Text('Reorder', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
      ]),
    ),
  ]);
}

class Featured extends StatelessWidget {
  const Featured({required this.restaurants, required this.favorites, required this.onFavorite});
  final List<RestaurantMock> restaurants;
  final Set<int> favorites;
  final ValueChanged<int> onFavorite;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final columns = c.maxWidth >= 900 ? 3 : c.maxWidth >= 600 ? 2 : 1;
    final gap = 16.0;
    final width = columns == 1 ? c.maxWidth : (c.maxWidth - gap * (columns - 1)) / columns;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle('Featured Champions', subtitle: 'Top-rated neighborhood cravings', trailing: 'Nearby'),
      const SizedBox(height: 10),
      Wrap(spacing: gap, runSpacing: gap, children: [
        for (var i = 0; i < restaurants.length; i++)
          SizedBox(width: width, child: RestaurantCard(
            restaurant: restaurants[i], favorite: favorites.contains(i), onFavorite: () => onFavorite(i),
          )),
      ]),
    ]);
  });
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({required this.restaurant, required this.favorite, required this.onFavorite});
  final RestaurantMock restaurant;
  final bool favorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => Material(
    color: SnapFoodColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/restaurant'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 176, child: Stack(fit: StackFit.expand, children: [
          Image.network(restaurant.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: SnapFoodColors.surfaceContainerHigh, child: Center(child: Icon(restaurant.icon, size: 72, color: SnapFoodColors.secondary.withAlpha(100))))),
          Positioned(top: 12, right: 12, child: Material(
            color: SnapFoodColors.surfaceContainerLowest.withAlpha(230), shape: const CircleBorder(),
            child: IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, size: 19, color: SnapFoodColors.secondary)),
          )),
          Positioned(bottom: 12, left: 12, child: Pill(icon: Icons.schedule, text: restaurant.time + '  •  ' + restaurant.distance)),
          Positioned(top: 12, left: 12, child: Pill(icon: restaurant.offer == 'Lightning Fast' ? Icons.bolt : Icons.local_offer, text: restaurant.offer, filled: true)),
        ])),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(restaurant.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            const SizedBox(width: 8),
            Rating(restaurant.rating, restaurant.reviews),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            const Text('₹₹', style: TextStyle(color: SnapFoodColors.secondary, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6), const Text('•', style: TextStyle(color: SnapFoodColors.outline)), const SizedBox(width: 6),
            Expanded(child: Text(restaurant.cuisines, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: SnapFoodColors.onSurfaceVariant))),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLow, borderRadius: BorderRadius.circular(SnapFoodRadii.md)),
            child: Row(children: [
              Icon(restaurant.icon, size: 15, color: SnapFoodColors.secondary), const SizedBox(width: 6),
              Expanded(child: Text(restaurant.dish, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8), Text(restaurant.price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(height: 7),
          const Row(children: [
            Tag('Clay Oven'), SizedBox(width: 6), Tag('Dum Cooked'), Spacer(), Tag('₹25 Delivery'),
          ]),
        ])),
      ]),
    ),
  );
}

class Pill extends StatelessWidget {
  const Pill({required this.icon, required this.text, this.filled = false});
  final IconData icon;
  final String text;
  final bool filled;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: filled ? SnapFoodColors.primaryContainer : SnapFoodColors.surfaceContainerLowest.withAlpha(242), borderRadius: BorderRadius.circular(SnapFoodRadii.full)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: filled ? SnapFoodColors.warmBlack : SnapFoodColors.secondary),
      const SizedBox(width: 5),
      Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: filled ? SnapFoodColors.warmBlack : SnapFoodColors.onSurface)),
    ]),
  );
}

class Rating extends StatelessWidget {
  const Rating(this.rating, this.reviews);
  final String rating;
  final String reviews;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: SnapFoodColors.primaryContainer.withAlpha(75), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star, size: 13, color: SnapFoodColors.primary), const SizedBox(width: 2),
      Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)), const SizedBox(width: 2),
      Text(reviews, style: const TextStyle(fontSize: 10, color: SnapFoodColors.outline)),
    ]),
  );
}

class Tag extends StatelessWidget {
  const Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: SnapFoodColors.surfaceContainer, borderRadius: BorderRadius.circular(6)),
    child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: SnapFoodColors.onSurfaceVariant)),
  );
}

class ExpressBar extends StatelessWidget {
  const ExpressBar();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: SnapFoodColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(SnapFoodRadii.lg)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: const BoxDecoration(color: SnapFoodColors.primaryContainer, shape: BoxShape.circle), child: const Icon(Icons.electric_scooter, size: 22, color: SnapFoodColors.warmBlack)),
      const SizedBox(width: 10),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SNAP EXPRESS MASCOT', style: TextStyle(fontSize: 9, letterSpacing: .8, fontWeight: FontWeight.w800, color: SnapFoodColors.outline)),
        SizedBox(height: 2), Text('Delivery in ~22 mins avg across Mumbai suburbs', maxLines: 2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ])),
      FilledButton(onPressed: () {}, child: const Text('Track Zone', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
    ]),
  );
}

class BottomNav extends StatelessWidget {
  const BottomNav({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  static const items = [(Icons.storefront, 'Home'), (Icons.search, 'Search'), (Icons.receipt_long, 'Orders'), (Icons.favorite, 'Favorites'), (Icons.person, 'Profile')];

  @override
  Widget build(BuildContext context) => Material(
    color: SnapFoodColors.surface.withAlpha(247), elevation: 12,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: SizedBox(height: 64, child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(child: InkWell(onTap: () {
            switch (i) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/search');
                break;
              case 2:
                context.go('/orders');
                break;
              case 3:
                context.go('/favorites');
                break;
              case 4:
                context.go('/profile');
                break;
            }
            onSelected(i);
          }, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(items[i].$1, size: 22, color: i == selected ? SnapFoodColors.secondary : SnapFoodColors.onSurfaceVariant),
            const SizedBox(height: 2),
            Text(items[i].$2, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == selected ? SnapFoodColors.secondary : SnapFoodColors.onSurfaceVariant)),
          ]))),
      ])),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 11, color: SnapFoodColors.onSurfaceVariant)),
    ])),
    if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SnapFoodColors.secondary)),
  ]);
}

class RestaurantMock {
  const RestaurantMock(this.name, this.rating, this.reviews, this.cuisines, this.time, this.distance, this.offer, this.dish, this.price, this.icon, this.imageUrl);
  final String name, rating, reviews, cuisines, time, distance, offer, dish, price, imageUrl;
  final IconData icon;
}
