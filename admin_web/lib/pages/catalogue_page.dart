part of '../main.dart';

class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});
  static const products = [
    ['Classic Veg Burger', 'Burgers', '₹180', 'In stock', Icons.lunch_dining_rounded],
    ['Paneer Tikka Wrap', 'Wraps', '₹220', 'In stock', Icons.breakfast_dining_rounded],
    ['Masala Fries', 'Sides', '₹120', 'Low stock', Icons.fastfood_rounded],
    ['Chocolate Brownie', 'Desserts', '₹140', 'In stock', Icons.cake_rounded],
  ];
  @override
  Widget build(BuildContext context) => Column(children: [
    Row(children: [
      Expanded(child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 13), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(11)), child: const Row(children: [Icon(Icons.search_rounded, size: 18, color: AdminColors.muted), SizedBox(width: 9), Text('Search products...', style: TextStyle(fontSize: 11, color: AdminColors.muted))]))),
      const SizedBox(width: 10),
      Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AdminColors.line), borderRadius: BorderRadius.circular(11)), child: const Row(children: [Text('All categories', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)), SizedBox(width: 5), Icon(Icons.keyboard_arrow_down_rounded, size: 17)])),
    ]),
    const SizedBox(height: 16),
    LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 720 ? 2 : 1;
      return GridView.builder(
        itemCount: products.length, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.38),
        itemBuilder: (context, i) => _ProductCard(product: products[i]),
      );
    }),
  ]);
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final List<Object> product;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: AdminColors.canvas, borderRadius: BorderRadius.circular(14)), child: Icon(product[4] as IconData, size: 42, color: AdminColors.yellowDark))),
    const SizedBox(height: 13),
    Row(children: [Expanded(child: Text(product[0] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900))), _Pill(product[3] as String)]),
    const SizedBox(height: 5),
    Text(product[1] as String, style: const TextStyle(fontSize: 10, color: AdminColors.muted)),
    const SizedBox(height: 8),
    Text(product[2] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
  ])));
}
