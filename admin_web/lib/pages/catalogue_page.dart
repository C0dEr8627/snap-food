part of '../main.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});
  @override State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final _repo = _CatalogueRepository();
  final _search = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _prep = TextEditingController();
  final _stock = TextEditingController();
  final _tag = TextEditingController();
  final _imageUrl = TextEditingController();

  List<_CatalogueProduct> _products = List.of(_previewCatalogueProducts);
  List<_CatalogueCategory> _categories = List.of(_previewCatalogueCategories);
  _CatalogueProduct? _selected;
  int? _categoryFilter;
  String _foodFilter = 'All Food Types';
  String _stockFilter = 'All';
  String _availabilityFilter = 'All';
  int _page = 1;
  int _lastPage = 1;
  int _total = _previewCatalogueProducts.length + 3;
  bool _loading = false;
  String _formDietary = 'Non-Veg';
  int? _formCategoryId;
  bool _saving = false;
  bool _uploading = false;
  bool _creating = true;
  bool _live = false;
  String _error = '';
  String _imagePreview = '';

  @override
  void initState() {
    super.initState();
    _live = _repo.liveEnabled;
    _load();
  }

  @override
  void dispose() {
    for (final c in [_search, _name, _slug, _description, _price, _prep, _stock, _tag, _imageUrl]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _load({bool keepSelection = true}) async {
    setState(() { _loading = true; _error = ''; });
    try {
      if (_repo.liveEnabled) {
        final results = await Future.wait([_repo.products(search: _search.text, categoryId: _categoryFilter, page: _page), _repo.categories()]);
        final p = results[0] as _CatalogueResponse;
        final c = results[1] as List<_CatalogueCategory>;
        if (!mounted) return;
        setState(() {
          _products = p.products; _categories = c; _lastPage = p.lastPage; _total = p.total; _live = true;
          if (!keepSelection) _selected = null;
        });
        if (_selected != null) {
          _CatalogueProduct? fresh;
          for (final item in _products) { if (item.id == _selected!.id) { fresh = item; break; } }
          if (fresh != null) _selectProduct(fresh);
        }
      } else {
        setState(() { _live = false; _applyPreviewFilters(); });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
      _notice(context, _error, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyPreviewFilters() {
    final query = _search.text.trim().toLowerCase();
    _products = _previewCatalogueProducts.where((p) {
      final category = _categoryFilter == null || p.categoryId == _categoryFilter;
      final search = query.isEmpty || p.name.toLowerCase().contains(query) || p.description.toLowerCase().contains(query) || p.categoryName.toLowerCase().contains(query);
      final food = _foodFilter == 'All Food Types' || p.dietary == _foodFilter;
      final stock = _stockFilter == 'All' || (_stockFilter == 'In Stock' && p.stock > 5) || (_stockFilter == 'Low Stock' && p.lowStock) || (_stockFilter == 'Out of Stock' && p.outOfStock);
      final availability = _availabilityFilter == 'All' || (_availabilityFilter == 'Live' && p.active && p.available) || (_availabilityFilter == 'Hidden' && !p.active);
      return category && search && food && stock && availability;
    }).toList();
    _total = _products.length;
    _lastPage = 1;
    _page = 1;
  }

  void _selectProduct(_CatalogueProduct product) {
    setState(() { _selected = product; _creating = false; });
    _formCategoryId = product.categoryId;
    _formDietary = product.dietary;
    _name.text = product.name; _slug.text = product.slug; _description.text = product.description;
    _price.text = product.price.toStringAsFixed(2); _prep.text = product.prepTime.toString(); _stock.text = product.stock.toString();
    _imageUrl.text = product.image ?? ''; _imagePreview = product.image ?? '';
  }

  void _newProduct() {
    setState(() { _selected = null; _creating = true; _error = ''; _imagePreview = ''; _formDietary = 'Non-Veg'; _formCategoryId = _categories.isNotEmpty ? _categories.first.id : null; });
    _name.clear(); _slug.clear(); _description.clear(); _price.clear(); _prep.text = '15'; _stock.text = '0'; _imageUrl.clear(); _tag.clear();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final product = _CatalogueProduct(
      id: _creating ? null : _selected?.id,
      name: _name.text.trim(), slug: _slug.text.trim(), description: _description.text.trim(),
      categoryId: _formCategoryId ?? (_selected?.categoryId ?? (_categories.isNotEmpty ? _categories.first.id : null)),
      categoryName: _selected?.categoryName ?? (_categories.isNotEmpty ? _categories.first.name : ''),
      price: double.tryParse(_price.text.trim()) ?? 0, stock: int.tryParse(_stock.text.trim()) ?? 0,
      available: true, active: true, image: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      dietary: _selected?.dietary ?? _formDietary, prepTime: int.tryParse(_prep.text.trim()) ?? 15,
      tags: _selected?.tags ?? [],
    );
    if (product.categoryId == null) { _notice(context, 'Select a category before saving.', error: true); return; }
    setState(() => _saving = true);
    try {
      final saved = await _repo.save(product);
      if (!_live) {
        if (_creating) { _previewCatalogueProducts.insert(0, saved); } else {
          final i = _previewCatalogueProducts.indexWhere((p) => p.id == saved.id);
          if (i >= 0) _previewCatalogueProducts[i] = saved;
        }
        _applyPreviewFilters();
      } else {
        await _load(keepSelection: false);
      }
      if (!mounted) return;
      _notice(context, _creating ? 'Product created successfully.' : 'Product updated successfully.');
      _creating = false;
      _selected = saved;
    } catch (e) {
      if (mounted) _notice(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deactivate() async {
    final p = _selected;
    if (p == null) return;
    setState(() => _saving = true);
    try {
      await _repo.deactivate(p);
      p.active = false; p.available = false;
      if (_live) await _load(keepSelection: false); else _applyPreviewFilters();
      if (mounted) { _newProduct(); _notice(context, 'Product deactivated.'); }
    } catch (e) { if (mounted) _notice(context, e.toString(), error: true); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _pickImage() async {
    final input = html.FileUploadInputElement()..accept = 'image/png,image/jpeg,image/webp';
    input.click();
    await input.onChange.first;
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) return;
    if (file.size > 4 * 1024 * 1024) { _notice(context, 'Image must be 4MB or smaller.', error: true); return; }
    setState(() => _uploading = true);
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;
    if (!mounted) return;
    final result = reader.result;
    if (result is String) {
      setState(() { _imagePreview = result; _imageUrl.text = ''; _uploading = false; });
      _notice(context, 'Image preview ready. The current Laravel API accepts an image URL, so no binary upload endpoint is available yet.');
    } else { setState(() => _uploading = false); }
  }

  Future<void> _manageCategories() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, dialogSetState) => AlertDialog(
          title: const Text('Manage Categories'),
          content: SizedBox(
            width: 560,
            child: _CategoryManager(
              categories: _categories, live: _live, repository: _repo,
              onChanged: () async {
                final fresh = _live ? await _repo.categories() : _categories;
                if (!mounted) return;
                setState(() => _categories = fresh);
                dialogSetState(() {});
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
        ),
      ),
    );
    if (mounted) await _load(keepSelection: true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 980;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CatalogueHeader(live: _live, onCategories: _manageCategories, onImport: () => _notice(context, 'CSV import is not exposed by the current Laravel API contract.', error: true), onAdd: _newProduct),
      const SizedBox(height: 18),
      _CategoryTabs(categories: _categories, selected: _categoryFilter, onSelect: (id) { setState(() => _categoryFilter = id); _load(keepSelection: false); }),
      const SizedBox(height: 16),
      _CatalogueStats(products: _live ? _products : _previewCatalogueProducts),
      const SizedBox(height: 18),
      if (_error.isNotEmpty) _ErrorBanner(message: _error, onRetry: _load),
      if (_loading) const LinearProgressIndicator(minHeight: 2),
      const SizedBox(height: 8),
      if (desktop) _Workspace(list: _buildProductPanel(), editor: _buildEditor(), listFlex: 62, editorFlex: 38)
      else Column(children: [_buildProductPanel(), const SizedBox(height: 18), _buildEditor()]),
    ]);
  }

  Widget _buildProductPanel() => _CatalogueList(
    products: _products, search: _search, foodFilter: _foodFilter, stockFilter: _stockFilter, availabilityFilter: _availabilityFilter,
    loading: _loading, page: _page, lastPage: _lastPage, total: _total, selected: _selected,
    onSearch: () { _page = 1; _load(keepSelection: true); }, onFood: (v) { setState(() => _foodFilter = v); if (!_live) setState(_applyPreviewFilters); },
    onStock: (v) { setState(() => _stockFilter = v); if (!_live) setState(_applyPreviewFilters); },
    onAvailability: (v) { setState(() => _availabilityFilter = v); if (!_live) setState(_applyPreviewFilters); },
    onSelect: _selectProduct, onPage: (p) { setState(() => _page = p); _load(keepSelection: true); },
  );

  Widget _buildEditor() => _ProductEditor(
    form: _form, formCategoryId: _formCategoryId, formDietary: _formDietary, creating: _creating, selected: _selected, categories: _categories, name: _name, slug: _slug, description: _description,
    price: _price, prep: _prep, stock: _stock, tag: _tag, imageUrl: _imageUrl, imagePreview: _imagePreview, uploading: _uploading, saving: _saving,
    onClose: _newProduct, onPickImage: _pickImage, onSave: _save, onDeactivate: _deactivate, onCategory: (v) { setState(() { _formCategoryId = v; }); if (_selected != null) _selected!.categoryId = v; },
    onDietary: (v) { if (_selected != null) _selected!.dietary = v; setState(() {}); },
  );
}

class _CategoryManager extends StatefulWidget {
  const _CategoryManager({required this.categories, required this.live, required this.repository, required this.onChanged});
  final List<_CatalogueCategory> categories;
  final bool live;
  final _CatalogueRepository repository;
  final Future<void> Function() onChanged;
  @override State<_CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<_CategoryManager> {
  int? _busyId;
  Future<void> _saveCategory({int? id, required String name, required String slug, required int sortOrder, required bool active}) async {
    setState(() => _busyId = id ?? -1);
    try {
      final saved = await widget.repository.saveCategory(id: id, name: name, slug: slug, sortOrder: sortOrder, active: active);
      if (!widget.live) {
        final list = [...widget.categories];
        final index = list.indexWhere((c) => c.id == id);
        if (index >= 0) list[index] = saved; else list.add(saved);
        widget.categories..clear()..addAll(list);
      }
      await widget.onChanged();
      if (mounted) _notice(context, id == null ? 'Category created successfully.' : 'Category updated successfully.');
    } catch (e) { if (mounted) _notice(context, e.toString(), error: true); }
    finally { if (mounted) setState(() => _busyId = null); }
  }
  Future<void> _deleteCategory(_CatalogueCategory category) async {
    if (category.id == null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Delete category?'),
      content: Text('This will deactivate "${category.name}". Products are not deleted.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), style: FilledButton.styleFrom(backgroundColor: AdminColors.red), child: const Text('Delete')),
      ],
    ));
    if (confirmed != true) return;
    setState(() => _busyId = category.id);
    try {
      if (widget.live) {
        final res = await http.delete(widget.repository._uri('/admin/categories/${category.id}'), headers: widget.repository._headers);
        if (res.statusCode < 200 || res.statusCode >= 300) throw _CatalogueApiException(res.statusCode, _CatalogueRepository._message(res));
      } else {
        final list = [...widget.categories];
        final index = list.indexWhere((c) => c.id == category.id);
        if (index >= 0) list[index] = _CatalogueCategory(id: category.id, name: category.name, slug: category.slug, sortOrder: category.sortOrder, active: false, count: category.count);
        widget.categories..clear()..addAll(list);
      }
      await widget.onChanged();
      if (mounted) _notice(context, 'Category deleted (deactivated).');
    } catch (e) { if (mounted) _notice(context, e.toString(), error: true); }
    finally { if (mounted) setState(() => _busyId = null); }
  }
  Future<void> _openEditor([_CatalogueCategory? category]) async {
    final name = TextEditingController(text: category?.name ?? '');
    final slug = TextEditingController(text: category?.slug ?? '');
    final order = TextEditingController(text: (category?.sortOrder ?? 0).toString());
    final form = GlobalKey<FormState>();
    final result = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: Text(category == null ? 'Add Category' : 'Edit Category'),
      content: SizedBox(width: 430, child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _field(name, 'Category name', maxLength: 120, validator: (v) => v == null || v.trim().isEmpty ? 'Category name is required' : null),
        const SizedBox(height: 10),
        _field(slug, 'Slug (alpha-dash)', maxLength: 140, validator: (v) { final value = v?.trim() ?? ''; if (value.isEmpty) return 'Slug is required'; if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value)) return 'Use letters, numbers, - or _'; return null; }),
        const SizedBox(height: 10),
        _field(order, 'Sort order', keyboard: TextInputType.number, validator: (v) { final value = int.tryParse(v ?? ''); return value == null || value < 0 ? 'Enter 0 or greater' : null; }),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () async {
          if (!form.currentState!.validate()) return;
          await _saveCategory(id: category?.id, name: name.text, slug: slug.text, sortOrder: int.tryParse(order.text) ?? 0, active: true);
          if (c.mounted) Navigator.pop(c, true);
        }, child: Text(category == null ? 'Create' : 'Save Changes')),
      ],
    ));
    name.dispose(); slug.dispose(); order.dispose();
    if (result == true && mounted) setState(() {});
  }
  @override Widget build(BuildContext context) {
    final visible = widget.categories.where((c) => c.active).toList();
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _busyId != null ? null : () => _openEditor(), icon: const Icon(Icons.add, size: 16), label: const Text('Add Category'))),
      const SizedBox(height: 12),
      if (visible.isEmpty) const Padding(padding: EdgeInsets.all(18), child: Text('No active categories yet.')) else ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360),
        child: ListView.separated(shrinkWrap: true, itemCount: visible.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (_, index) {
          final c = visible[index]; final busy = _busyId == c.id;
          return ListTile(dense: true, title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(c.slug.isEmpty ? 'No slug' : c.slug), trailing: Wrap(spacing: 2, children: [
            IconButton(tooltip: 'Edit', onPressed: busy ? null : () => _openEditor(c), icon: const Icon(Icons.edit_outlined, size: 18)),
            IconButton(tooltip: 'Delete', onPressed: busy ? null : () => _deleteCategory(c), icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.delete_outline, size: 18, color: AdminColors.red)),
          ]));
        }),
      ),
    ]);
  }
}
class _Workspace extends StatelessWidget {
  const _Workspace({required this.list, required this.editor, required this.listFlex, required this.editorFlex});
  final Widget list, editor; final int listFlex, editorFlex;
  @override Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(flex: listFlex, child: list), const SizedBox(width: 18), Expanded(flex: editorFlex, child: editor),
  ]);
}

class _CatalogueHeader extends StatelessWidget {
  const _CatalogueHeader({required this.live, required this.onCategories, required this.onImport, required this.onAdd});
  final bool live; final VoidCallback onCategories, onImport, onAdd;
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 7, height: 7, decoration: const BoxDecoration(color: AdminColors.red, shape: BoxShape.circle)), const SizedBox(width: 7), const Text('HQ INVENTORY  •  CLUSTER', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.3, color: AdminColors.muted))]),
        const SizedBox(height: 5), const Text('BANGALORE CENTRAL KITCHEN  #04', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12), const Text('Catalogue Management', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.5)),
        const SizedBox(height: 3), Text(live ? 'Live catalogue connected to Laravel API v1.' : 'Preview Data Mode • Live API activates when an admin bearer token is available.', style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
      ])),
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(onPressed: onCategories, icon: const Icon(Icons.folder_outlined, size: 16), label: const Text('Manage Categories')),
        OutlinedButton.icon(onPressed: onImport, icon: const Icon(Icons.upload_file_rounded, size: 16), label: const Text('Bulk CSV Import')),
        FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded, size: 17), label: const Text('Add New Product'), style: FilledButton.styleFrom(backgroundColor: AdminColors.red, foregroundColor: Colors.white)),
      ]),
    ]),
  ]);
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.categories, required this.selected, required this.onSelect});
  final List<_CatalogueCategory> categories; final int? selected; final ValueChanged<int?> onSelect;
  @override Widget build(BuildContext context) => SizedBox(height: 46, child: ListView(scrollDirection: Axis.horizontal, children: [
    _cat('All Categories', selected == null, null, 0),
    ...categories.map((c) => _cat(c.name, selected == c.id, c.id, c.count)),
  ]));
  Widget _cat(String label, bool active, int? id, int count) => Padding(padding: const EdgeInsets.only(right: 8), child: InkWell(
    onTap: () => onSelect(id), borderRadius: BorderRadius.circular(11), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: active ? AdminColors.yellow : Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: active ? AdminColors.yellow : AdminColors.line)),
      child: Row(children: [Text(label, style: TextStyle(fontSize: 10.5, fontWeight: active ? FontWeight.w900 : FontWeight.w700)), if (count > 0) ...[const SizedBox(width: 7), Text(count.toString(), style: const TextStyle(fontSize: 9, color: AdminColors.muted))]]),
    ),
  ));
}

class _CatalogueStats extends StatelessWidget {
  const _CatalogueStats({required this.products}); final List<_CatalogueProduct> products;
  @override Widget build(BuildContext context) {
    final total = products.length, active = products.where((p) => p.active && p.available).length, out = products.where((p) => p.outOfStock).length, low = products.where((p) => p.lowStock).length;
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 850 ? 4 : c.maxWidth >= 560 ? 2 : 1;
      return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.6,
        children: [
          _StatCard('TOTAL MENU ITEMS', total.toString(), 'Kitchen catalogue', Icons.restaurant_menu_rounded),
          _StatCard('ACTIVE LIVE ON APP', active.toString(), total == 0 ? '0% Availability' : ((active / total) * 100).toStringAsFixed(1) + '% Availability', Icons.check_circle_outline_rounded),
          _StatCard('OUT OF STOCK', out.toString().padLeft(2, '0'), 'Hidden from user feed', Icons.block_rounded, danger: true),
          _StatCard('LOW STOCK ALERT', low.toString().padLeft(2, '0'), 'Requires raw prep reorder', Icons.warning_amber_rounded, warning: true),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.caption, this.icon, {this.danger = false, this.warning = false});
  final String label, value, caption;
  final IconData icon;
  final bool danger, warning;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: AdminColors.line), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 14, offset: Offset(0, 5))]),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: danger ? AdminColors.redSoft : warning ? AdminColors.peach : AdminColors.amberSoft, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 19, color: danger ? AdminColors.red : warning ? AdminColors.warning : AdminColors.yellowDark)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: .8, color: AdminColors.muted)),
        const SizedBox(height: 3),
        Row(children: [
          Text(value, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: danger ? AdminColors.red : AdminColors.ink)),
          const SizedBox(width: 8),
          Flexible(child: Text(caption, style: const TextStyle(fontSize: 9, color: AdminColors.muted), overflow: TextOverflow.ellipsis)),
        ]),
      ])),
    ]),
  );
}

class _CatalogueList extends StatelessWidget {
  const _CatalogueList({required this.products, required this.search, required this.foodFilter, required this.stockFilter, required this.availabilityFilter, required this.loading, required this.page, required this.lastPage, required this.total, required this.selected, required this.onSearch, required this.onFood, required this.onStock, required this.onAvailability, required this.onSelect, required this.onPage});
  final List<_CatalogueProduct> products;
  final TextEditingController search;
  final String foodFilter, stockFilter, availabilityFilter;
  final bool loading;
  final int page, lastPage, total;
  final _CatalogueProduct? selected;
  final VoidCallback onSearch;
  final ValueChanged<String> onFood, onStock, onAvailability;
  final ValueChanged<_CatalogueProduct> onSelect;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: AdminColors.line), boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 16, offset: Offset(0, 5))]),
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PRODUCT CATALOGUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: AdminColors.muted)),
            SizedBox(height: 3),
            Text('Menu items & inventory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ])),
          IconButton(onPressed: () => _notice(context, 'Filters are applied below.'), icon: const Icon(Icons.tune_rounded, size: 18)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          SizedBox(width: 230, height: 40, child: TextField(controller: search, onSubmitted: (_) => onSearch(), decoration: _inputDecoration('Filter by dish...', Icons.search_rounded))),
          _select('All Food Types', ['All Food Types', 'Pure Veg', 'Non-Veg', 'Contains Egg'], foodFilter, onFood),
          _select('Stock', ['All', 'In Stock', 'Low Stock', 'Out of Stock'], stockFilter, onStock),
          _select('Availability', ['All', 'Live', 'Hidden'], availabilityFilter, onAvailability),
        ]),
        const SizedBox(height: 16),
        const Row(children: [
          Expanded(flex: 5, child: Text('PRODUCT', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: .9, color: AdminColors.muted))),
          Expanded(flex: 3, child: Text('CATEGORY', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: .9, color: AdminColors.muted))),
          SizedBox(width: 85, child: Text('STOCK', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: .9, color: AdminColors.muted))),
        ]),
        const Divider(height: 18),
        if (products.isEmpty && !loading)
          const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No products match these filters.', style: TextStyle(color: AdminColors.muted)))),
        ...products.map((p) => _ProductRow(product: p, selected: selected?.id == p.id && selected == p, onTap: () => onSelect(p))),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text('Showing ' + (total == 0 ? '0' : '1') + '–' + products.length.toString() + ' of ' + total.toString(), style: const TextStyle(fontSize: 9.5, color: AdminColors.muted))),
          IconButton(onPressed: page > 1 ? () => onPage(page - 1) : null, icon: const Icon(Icons.chevron_left_rounded, size: 18)),
          Text(page.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          IconButton(onPressed: page < lastPage ? () => onPage(page + 1) : null, icon: const Icon(Icons.chevron_right_rounded, size: 18)),
        ]),
      ]),
    ),
  );
}

Widget _select(String label, List<String> items, String value, ValueChanged<String> onChanged) => Container(
  height: 40,
  padding: const EdgeInsets.symmetric(horizontal: 11),
  decoration: BoxDecoration(color: AdminColors.peach, borderRadius: BorderRadius.circular(10), border: Border.all(color: AdminColors.line)),
  child: DropdownButtonHideUnderline(child: DropdownButton<String>(
    value: items.contains(value) ? value : items.first,
    isDense: true,
    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
    style: const TextStyle(fontSize: 10.5, color: AdminColors.ink, fontWeight: FontWeight.w700),
    items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
    onChanged: (v) { if (v != null) onChanged(v); },
  )),
);

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.selected, required this.onTap});
  final _CatalogueProduct product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(11),
    child: Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
      decoration: BoxDecoration(color: selected ? AdminColors.amberSoft : Colors.transparent, borderRadius: BorderRadius.circular(11)),
      child: Row(children: [
        Expanded(flex: 5, child: Row(children: [
          _Thumb(image: product.image, name: product.name),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(product.name, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis)),
              if (product.badge.isNotEmpty) ...[const SizedBox(width: 6), _Badge(product.badge)],
            ]),
            const SizedBox(height: 3),
            Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.8, color: AdminColors.muted)),
          ])),
        ])),
        Expanded(flex: 3, child: Text(product.categoryName, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
        SizedBox(width: 85, child: Text(product.outOfStock ? 'Sold out' : product.stock.toString() + ' units', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: product.outOfStock ? AdminColors.red : product.lowStock ? AdminColors.warning : AdminColors.ink))),
      ]),
    ),
  );
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.image, required this.name}); final String? image; final String name;
  @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(width: 50, height: 50, color: AdminColors.canvas, child: image != null && image!.isNotEmpty ? Image.network(image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()) : _placeholder()));
  Widget _placeholder() => const Icon(Icons.restaurant_rounded, size: 22, color: AdminColors.yellowDark);
}

class _Badge extends StatelessWidget {
  const _Badge(this.text); final String text;
  @override Widget build(BuildContext context) { final danger = text == 'Sold Out' || text.contains('Left'); final seasonal = text == 'Seasonal'; return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: danger ? AdminColors.redSoft : seasonal ? AdminColors.amberSoft : const Color(0xFFFDE8EE), borderRadius: BorderRadius.circular(5)), child: Text(text, style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: danger ? AdminColors.red : AdminColors.ink))); }
}

// Product editor intentionally uses a block-bodied build method to keep widget nesting balanced.
class _ProductEditor extends StatelessWidget {
  const _ProductEditor({
    required this.form,
    required this.formCategoryId,
    required this.formDietary,
    required this.creating,
    required this.selected,
    required this.categories,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.prep,
    required this.stock,
    required this.tag,
    required this.imageUrl,
    required this.imagePreview,
    required this.uploading,
    required this.saving,
    required this.onClose,
    required this.onPickImage,
    required this.onSave,
    required this.onDeactivate,
    required this.onCategory,
    required this.onDietary,
  });

  final GlobalKey<FormState> form;
  final int? formCategoryId;
  final String formDietary;
  final bool creating;
  final bool uploading;
  final bool saving;
  final _CatalogueProduct? selected;
  final List<_CatalogueCategory> categories;
  final TextEditingController name;
  final TextEditingController slug;
  final TextEditingController description;
  final TextEditingController price;
  final TextEditingController prep;
  final TextEditingController stock;
  final TextEditingController tag;
  final TextEditingController imageUrl;
  final String imagePreview;
  final VoidCallback onClose;
  final VoidCallback onPickImage;
  final VoidCallback onSave;
  final VoidCallback onDeactivate;
  final ValueChanged<int?> onCategory;
  final ValueChanged<String> onDietary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AdminColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LIVE SYNC ENGINE',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AdminColors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          creating ? 'Add New Product' : 'Edit Product',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
              const Divider(height: 22),
              _label('Dish Name *', 'Max 180 chars'),
              _field(
                name,
                'Smokey Chicken Tikka Roll',
                maxLength: 180,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Dish name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dropdownField(
                      'Category',
                      categories
                          .map(
                            (c) => DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      formCategoryId ??
                          (categories.isNotEmpty ? categories.first.id : null),
                      onCategory,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _select(
                      'GST Slab',
                      const ['5%', '12%', '18%'],
                      selected?.gst ?? '5%',
                      (_) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _label('Dietary Classification', null),
              Wrap(
                spacing: 6,
                children: ['Pure Veg', 'Non-Veg', 'Contains Egg']
                    .map(
                      (e) => ChoiceChip(
                        label: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        selected: formDietary == e,
                        onSelected: (_) => onDietary(e),
                        selectedColor: AdminColors.yellow,
                        side: const BorderSide(color: AdminColors.line),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      price,
                      '₹220',
                      label: 'Base Price (₹)',
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return n == null || n < 0
                            ? 'Enter a valid price'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      prep,
                      '15',
                      label: 'Prep Time (Min)',
                      keyboard: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n < 1 || n > 300
                            ? '1–300 min'
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                description,
                'Charcoal roasted chicken tikka cubes, spiced onions, mint yogurt and flaky paratha bread.',
                label: 'Short Description',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _label('Ingredients & Tags', null),
              if (selected == null || selected!.tags.isEmpty)
                const Text(
                  'No tags yet',
                  style: TextStyle(fontSize: 9, color: AdminColors.muted),
                )
              else
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: selected!.tags
                      .map(
                        (e) => InputChip(
                          label: Text(
                            e,
                            style: const TextStyle(fontSize: 9),
                          ),
                          onDeleted: () {
                            selected!.tags.remove(e);
                            (context as Element).markNeedsBuild();
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  if (tag.text.trim().isEmpty || selected == null) return;
                  selected!.tags = [
                    ...selected!.tags,
                    tag.text.trim(),
                  ];
                  tag.clear();
                  (context as Element).markNeedsBuild();
                },
                icon: const Icon(Icons.add_rounded, size: 15),
                label: const Text(
                  'Add tag',
                  style: TextStyle(fontSize: 9.5),
                ),
              ),
              const SizedBox(height: 10),
              _label('Product Photography (1:1 Ratio)', null),
              InkWell(
                onTap: uploading ? null : onPickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 135,
                  decoration: BoxDecoration(
                    color: AdminColors.peach,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminColors.line),
                  ),
                  child: imagePreview.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imagePreview,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('Preview unavailable'),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              uploading
                                  ? Icons.hourglass_top_rounded
                                  : Icons.cloud_upload_outlined,
                              size: 27,
                              color: AdminColors.yellowDark,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              uploading
                                  ? 'Reading image…'
                                  : 'Drop product image or browse file',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PNG, JPG, WEBP up to 4MB',
                              style: TextStyle(
                                fontSize: 8.5,
                                color: AdminColors.muted,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              _field(
                imageUrl,
                'https://...',
                label: 'Image URL (supported by current API)',
                validator: (_) => null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      stock,
                      '0',
                      label: 'Stock Quantity',
                      keyboard: TextInputType.number,
                      validator: (v) {
                        final value = int.tryParse(v ?? '');
                        return value == null || value < 0
                            ? 'Enter stock'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text(
                        'Live on app',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      value: selected?.available ?? true,
                      onChanged: (v) {
                        if (selected != null) {
                          selected!.available = v;
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: Icon(
                    saving
                        ? Icons.hourglass_top_rounded
                        : Icons.save_rounded,
                    size: 17,
                  ),
                  label: Text(
                    saving
                        ? 'Saving…'
                        : 'Save to Catalogue (Laravel API v1)',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminColors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
              if (!creating)
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: saving ? null : onDeactivate,
                    child: const Text(
                      'Deactivate product',
                      style: TextStyle(
                        fontSize: 9,
                        color: AdminColors.red,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 3),
              const Center(
                child: Text(
                  'Instant cache purge for user apps • server-side cache behavior applies',
                  style: TextStyle(
                    fontSize: 8,
                    color: AdminColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _label(String text, String? trailing) => Padding(
  padding: const EdgeInsets.only(bottom: 5),
  child: Row(
    children: [
      Text(text, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AdminColors.muted)),
      if (trailing != null) ...[
        const SizedBox(width: 6),
        Text(trailing!, style: const TextStyle(fontSize: 8, color: AdminColors.muted)),
      ],
    ],
  ),
);
Widget _field(TextEditingController c, String hint, {String? label, int? maxLength, int maxLines = 1, TextInputType? keyboard, String? Function(String?)? validator}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  if (label != null) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AdminColors.muted))),
  TextFormField(controller: c, maxLength: maxLength, maxLines: maxLines, keyboardType: keyboard, validator: validator, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700), decoration: _inputDecoration(hint).copyWith(counterText: '')),
]);

Widget _dropdownField(String label, List<DropdownMenuItem<int?>> items, int? value, ValueChanged<int?> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AdminColors.muted))),
  Container(height: 43, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: AdminColors.peach, borderRadius: BorderRadius.circular(9), border: Border.all(color: AdminColors.line)), child: DropdownButtonHideUnderline(child: DropdownButton<int?>(value: items.any((i) => i.value == value) ? value : (items.isEmpty ? null : items.first.value), isExpanded: true, style: const TextStyle(fontSize: 10.5, color: AdminColors.ink, fontWeight: FontWeight.w700), items: items, onChanged: onChanged))),
]);

InputDecoration _inputDecoration(String hint, [IconData? icon]) => InputDecoration(
  hintText: hint, hintStyle: const TextStyle(fontSize: 10, color: AdminColors.muted),
  prefixIcon: icon == null ? null : Icon(icon, size: 17, color: AdminColors.muted),
  filled: true, fillColor: AdminColors.peach, contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AdminColors.line)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AdminColors.line)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: AdminColors.yellowDark, width: 1.3)),
);

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry;
  @override Widget build(BuildContext context) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AdminColors.redSoft, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.error_outline_rounded, size: 17, color: AdminColors.red), const SizedBox(width: 8), Expanded(child: Text(message, style: const TextStyle(fontSize: 9.5))), TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(fontSize: 9)))]));
}
