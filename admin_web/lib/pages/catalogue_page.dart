part of '../main.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key, this.searchQuery = ''});
  final String searchQuery;
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
  List<String> _formTags = [];
  html.File? _selectedImageFile;
  bool _gridView = true;

  @override
  void initState() {
    super.initState();
    _search.text = widget.searchQuery;
    _live = _repo.liveEnabled;
    _load();
  }

  @override
  void didUpdateWidget(covariant CataloguePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _search.text != widget.searchQuery) {
      _search.text = widget.searchQuery;
      _load(keepSelection: false);
    }
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
    _formTags = List<String>.of(product.tags);
    _name.text = product.name; _slug.text = product.slug; _description.text = product.description;
    _price.text = product.price.toStringAsFixed(2); _prep.text = product.prepTime.toString(); _stock.text = product.stock.toString();
    _imageUrl.text = product.image ?? ''; _imagePreview = product.image ?? ''; _selectedImageFile = null;
    _openProductDialog();
  }

  void _newProduct() {
    setState(() { _selected = null; _creating = true; _error = ''; _imagePreview = ''; _formDietary = 'Non-Veg'; _formTags = []; _formCategoryId = _categories.isNotEmpty ? _categories.first.id : null; });
    _name.clear(); _slug.clear(); _description.clear(); _price.clear(); _prep.text = '15'; _stock.text = '0'; _imageUrl.clear(); _tag.clear(); _selectedImageFile = null;
    _openProductDialog();
  }

  Future<void> _openProductDialog() async {
    final viewport = MediaQuery.sizeOf(context);

    // Size the dialog from the actual browser viewport rather than subtracting
    // a fixed pixel amount. This keeps the card balanced across laptop,
    // desktop and narrow browser widths while leaving a predictable gutter.
    final viewportWidth = viewport.width;
    final viewportHeight = viewport.height;
    final horizontalGutter = viewportWidth < 600
        ? 16.0
        : viewportWidth < 1000
            ? 24.0
            : 32.0;
    final verticalGutter = viewportHeight < 700 ? 24.0 : 40.0;
    final dialogWidth = (viewportWidth - (horizontalGutter * 2))
        .clamp(320.0, 820.0)
        .toDouble();
    final dialogHeight = (viewportHeight - (verticalGutter * 2))
        .clamp(260.0, 760.0)
        .toDouble();
    if (_categories.isEmpty) {
      _notice(context, 'Create a category before adding an item.', error: true);
      return;
    }
    await shad.showOverlay<void>(
      context,
      shad.DialogConfiguration(),
      builder: (dialogContext) => Center(
        child: SizedBox(
          width: dialogWidth,
          child: shad.AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(_creating ? 'Add Item' : 'Edit Item'),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(dialogContext).pop(),
                borderRadius: BorderRadius.circular(18),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(Icons.close_rounded, size: 19),
                  ),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.infinity,
          child: SizedBox(
            height: dialogHeight,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: _ProductEditor(
            form: _form,
            formCategoryId: _formCategoryId,
            formDietary: _formDietary,
            creating: _creating,
            selected: _selected,
            categories: _categories,
            name: _name,
            slug: _slug,
            description: _description,
            price: _price,
            prep: _prep,
            stock: _stock,
            tag: _tag,
            imageUrl: _imageUrl,
            imagePreview: _imagePreview,
            uploading: _uploading,
            saving: _saving,
            onClose: () => Navigator.of(dialogContext).pop(),
            onPickImage: _pickImage,
            onSave: () async {
              final saved = await _save();
              if (saved && dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            onDeactivate: () async {
              await _deactivate();
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            onCategory: (v) {
              setState(() { _formCategoryId = v; });
              if (_selected != null) _selected!.categoryId = v;
            },
            onDietary: (v) {
              _formDietary = v;
              if (_selected != null) _selected!.dietary = v;
              setState(() {});
            },
            onTags: (tags) {
              _formTags = List<String>.of(tags);
              if (_selected != null) _selected!.tags = List<String>.of(tags);
              setState(() {});
            },
              ),
            ),
          ),
        ),
          ),
        ),
      ),
    ).future;
  }
  Future<bool> _save() async {
    final validationError = _validateProductForm();
    if (validationError != null) { _notice(context, validationError, error: true); return false; }
    final product = _CatalogueProduct(
      id: _creating ? null : _selected?.id,
      name: _name.text.trim(),
      slug: _slug.text.trim().isNotEmpty
          ? _slug.text.trim()
          : _name.text.trim().toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
              .replaceAll(RegExp(r'^-+|-+$'), ''),
      description: _description.text.trim(),
      categoryId: _formCategoryId ?? (_selected?.categoryId ?? (_categories.isNotEmpty ? _categories.first.id : null)),
      categoryName: _selected?.categoryName ?? (_categories.isNotEmpty ? _categories.first.name : ''),
      price: double.tryParse(_price.text.trim()) ?? 0, stock: int.tryParse(_stock.text.trim()) ?? 0,
      available: true, active: true, image: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      dietary: _selected?.dietary ?? _formDietary, prepTime: int.tryParse(_prep.text.trim()) ?? 15,
      tags: List<String>.of(_formTags),
    );
    if (product.categoryId == null) { _notice(context, 'Select a category before saving.', error: true); return false; }
    final imageValue = _imageUrl.text.trim();
    if (imageValue.isNotEmpty) {
      final imageUri = Uri.tryParse(imageValue);
      if (imageUri == null ||
          !imageUri.hasScheme ||
          !['http', 'https'].contains(imageUri.scheme.toLowerCase()) ||
          imageUri.host.isEmpty) {
        _notice(context, 'Enter a valid image URL starting with https://, or leave it blank.', error: true);
        return false;
      }
    }
    setState(() => _saving = true);
    try {
      var saved = await _repo.save(product);
      if (_live && saved.id != null && _selectedImageFile != null) {
        saved = await _repo.uploadImage(saved.id!, _selectedImageFile!);
      }
      _selectedImageFile = null;
      if (!_live) {
        if (_creating) { _previewCatalogueProducts.insert(0, saved); } else {
          final i = _previewCatalogueProducts.indexWhere((p) => p.id == saved.id);
          if (i >= 0) _previewCatalogueProducts[i] = saved;
        }
        _applyPreviewFilters();
      } else {
        await _load(keepSelection: false);
      }
      if (!mounted) return false;
      _notice(context, _creating ? 'Item created successfully.' : 'Item updated successfully.');
      _creating = false;
      _selected = saved;
      return true;
    } catch (e) {
      if (mounted) _notice(context, e.toString(), error: true);
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateProductForm() {
    if (_name.text.trim().isEmpty) return 'Dish name is required.';
    final price = double.tryParse(_price.text.trim());
    if (price == null || price < 0) return 'Enter a valid price.';
    final prep = int.tryParse(_prep.text.trim());
    if (prep == null || prep < 1 || prep > 300) return 'Prep time must be between 1 and 300 minutes.';
    final stock = int.tryParse(_stock.text.trim());
    if (stock == null || stock < 0) return 'Enter a valid stock quantity.';
    final image = _imageUrl.text.trim();
    if (image.isNotEmpty) {
      final uri = Uri.tryParse(image);
      if (uri == null || !uri.hasScheme || !['http', 'https'].contains(uri.scheme.toLowerCase()) || uri.host.isEmpty) return 'Enter a valid image URL starting with https://, or leave it blank.';
    }
    if (_formCategoryId == null) return 'Select a category before saving.';
    return null;
  }

  Future<void> _deactivate() async {
    final p = _selected;
    if (p == null) return;
    setState(() => _saving = true);
    try {
      await _repo.deactivate(p);
      p.active = false; p.available = false;
      if (_live) await _load(keepSelection: false); else _applyPreviewFilters();
      if (mounted) { _newProduct(); _notice(context, 'Item deactivated.'); }
    } catch (e) { if (mounted) _notice(context, e.toString(), error: true); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<String?> _pickImage() async {
    final input = html.FileUploadInputElement()..accept = 'image/png,image/jpeg,image/webp';
    input.click();
    await input.onChange.first;
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) return null;
    if (file.size > 4 * 1024 * 1024) { _notice(context, 'Image must be 4MB or smaller.', error: true); return null; }
    setState(() => _uploading = true);
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;
    if (!mounted) return null;
    final result = reader.result;
    if (result is String) {
      setState(() {
        _selectedImageFile = file;
        _imagePreview = result;
        _imageUrl.text = '';
        _uploading = false;
      });
      return result;
    } else {
      setState(() => _uploading = false);
      return null;
    }
  }

  Future<void> _manageCategories() async {
    await shad.showOverlay<void>(context, shad.DialogConfiguration(), builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, dialogSetState) => shad.AlertDialog(
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
          actions: [shad.OutlineButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
        ),
      ),
    );
    if (mounted) await _load(keepSelection: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      _CategoryTabs(
        categories: _categories,
        selected: _categoryFilter,
        onSelect: (id) {
          setState(() => _categoryFilter = id);
          _load(keepSelection: false);
        },
      ),
      const SizedBox(height: 16),
      if (_error.isNotEmpty) _ErrorBanner(message: _error, onRetry: _load),
      if (_loading) const shad.LinearProgressIndicator(minHeight: 2),
      const SizedBox(height: 8),
      _buildProductPanel(),
    ]);
  }

  Widget _buildProductPanel() => _CatalogueList(
    products: _products,
    search: _search,
    foodFilter: _foodFilter,
    stockFilter: _stockFilter,
    availabilityFilter: _availabilityFilter,
    loading: _loading,
    page: _page,
    lastPage: _lastPage,
    total: _total,
    selected: _selected,
    gridView: _gridView,
    onToggleView: () => setState(() => _gridView = !_gridView),
    onSearch: () { _page = 1; _load(keepSelection: true); },
    onFood: (v) { setState(() => _foodFilter = v); if (!_live) setState(_applyPreviewFilters); },
    onStock: (v) { setState(() => _stockFilter = v); if (!_live) setState(_applyPreviewFilters); },
    onAvailability: (v) { setState(() => _availabilityFilter = v); if (!_live) setState(_applyPreviewFilters); },
    onSelect: _selectProduct,
    onPage: (p) { setState(() => _page = p); _load(keepSelection: true); },
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
  Future<void> _setCategoryActive(_CatalogueCategory category, bool active) async {
    if (category.id == null) return;
    setState(() => _busyId = category.id);
    try {
      if (widget.live) {
        await widget.repository.setCategoryActive(category.id!, active);
      } else {
        final index = widget.categories.indexWhere((c) => c.id == category.id);
        if (index >= 0) {
          final old = widget.categories[index];
          widget.categories[index] = _CatalogueCategory(
            id: old.id,
            name: old.name,
            slug: old.slug,
            sortOrder: old.sortOrder,
            active: active,
            count: old.count,
          );
        }
      }
      await widget.onChanged();
      if (mounted) _notice(context, active ? 'Category activated.' : 'Category deactivated.');
    } catch (e) {
      if (mounted) _notice(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _deleteCategory(_CatalogueCategory category) async {
    if (category.id == null) return;
    final confirmed = await shad.showOverlay<bool>(context, shad.DialogConfiguration(), builder: (c) => shad.AlertDialog(
      title: const Text('Delete category permanently?'),
      content: Text(category.count > 0 ? 'This category has assigned products. Deactivate it instead or move the products first.' : 'This permanently removes the category. This cannot be undone.'),
      actions: [
        shad.OutlineButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        if (category.count == 0) shad.DestructiveButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete Permanently')),
      ],
    )).future;
    if (confirmed != true) return;
    setState(() => _busyId = category.id);
    try {
      if (widget.live) {
        await widget.repository.deleteCategory(category.id!);
      } else {
        final list = [...widget.categories];
        final index = list.indexWhere((c) => c.id == category.id);
        if (index >= 0) list[index] = _CatalogueCategory(id: category.id, name: category.name, slug: category.slug, sortOrder: category.sortOrder, active: false, count: category.count);
        widget.categories..clear()..addAll(list);
      }
      await widget.onChanged();
      if (mounted) _notice(context, 'Category deleted permanently.');
    } catch (e) { if (mounted) _notice(context, e.toString(), error: true); }
    finally { if (mounted) setState(() => _busyId = null); }
  }
  Future<void> _openEditor([_CatalogueCategory? category]) async {
    final name = TextEditingController(text: category?.name ?? '');
    final slug = TextEditingController(text: category?.slug ?? '');
    final order = TextEditingController(text: (category?.sortOrder ?? 0).toString());

    final result = await shad.showOverlay<bool>(
      context,
      shad.DialogConfiguration(),
      builder: (c) => shad.AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: SizedBox(
            width: 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(name, 'Category name', maxLength: 120),
                const SizedBox(height: 10),
                _field(slug, 'Slug (alpha-dash)', maxLength: 140),
                const SizedBox(height: 10),
                _field(order, 'Sort order', keyboard: TextInputType.number),
              ],
            ),
          ),
          actions: [
            shad.OutlineButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
            shad.PrimaryButton(
              onPressed: () async {
                final categoryName = name.text.trim();
                final categorySlug = slug.text.trim();
                final categoryOrder = int.tryParse(order.text.trim());

                if (categoryName.isEmpty) {
                  _notice(c, 'Category name is required.', error: true);
                  return;
                }
                if (categorySlug.isEmpty ||
                    !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(categorySlug)) {
                  _notice(c, 'Use letters, numbers, - or _ for the slug.', error: true);
                  return;
                }
                if (categoryOrder == null || categoryOrder < 0) {
                  _notice(c, 'Sort order must be 0 or greater.', error: true);
                  return;
                }

                await _saveCategory(
                  id: category?.id,
                  name: categoryName,
                  slug: categorySlug,
                  sortOrder: categoryOrder,
                  active: category?.active ?? true,
                );
                if (c.mounted) Navigator.pop(c, true);
              },
              child: Text(category == null ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
    ).future;

    name.dispose();
    slug.dispose();
    order.dispose();

    if (result == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.categories.where((c) => c.active).toList();
    final inactive = widget.categories.where((c) => !c.active).toList();

    Widget categoryRow(_CatalogueCategory c, {required bool inactive}) {
      final busy = _busyId == c.id;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    (c.slug.isEmpty ? 'No slug' : c.slug) +
                        (inactive ? ' • ${c.count} product(s) • inactive' : ''),
                    style: const TextStyle(fontSize: 11, color: AdminColors.muted),
                  ),
                ],
              ),
            ),
            shad.IconButton.ghost(
              onPressed: inactive || busy ? null : () => _openEditor(c),
              icon: const AdminIcon(HugeIcons.strokeRoundedEdit02, size: 18),
            ),
            if (inactive)
              shad.IconButton.ghost(
                onPressed: busy ? null : () => _setCategoryActive(c, true),
                icon: busy
                    ? const shad.CircularProgressIndicator(size: 18, strokeWidth: 2)
                    : const AdminIcon(HugeIcons.strokeRoundedView, size: 18),
              )
            else
              shad.IconButton.ghost(
                onPressed: busy ? null : () => _setCategoryActive(c, false),
                icon: busy
                    ? const shad.CircularProgressIndicator(size: 18, strokeWidth: 2)
                    : const AdminIcon(HugeIcons.strokeRoundedViewOff, size: 18),
              ),
            shad.IconButton.ghost(
              onPressed: busy || c.count > 0 ? null : () => _deleteCategory(c),
              icon: const AdminIcon(
                HugeIcons.strokeRoundedDelete02,
                size: 18,
                color: AdminColors.red,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: shad.PrimaryButton(
            onPressed: _busyId != null ? null : () => _openEditor(),
            leading: const AdminIcon(HugeIcons.strokeRoundedAdd01, size: 16),
            child: const Text('Add Category'),
          ),
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('No active categories yet.'),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: visible.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) => categoryRow(visible[index], inactive: false),
            ),
          ),
        if (inactive.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'INACTIVE CATEGORIES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: AdminColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: inactive.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) => categoryRow(inactive[index], inactive: true),
            ),
          ),
        ],
      ],
    );
  }
}
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.categories, required this.selected, required this.onSelect});
  final List<_CatalogueCategory> categories; final int? selected; final ValueChanged<int?> onSelect;
  @override Widget build(BuildContext context) => SizedBox(height: 46, child: ListView(scrollDirection: Axis.horizontal, children: [
    _cat('All Categories', selected == null, null, 0),
    ...categories.map((c) => _cat(c.name, selected == c.id, c.id, c.count)),
  ]));
  Widget _cat(String label, bool active, int? id, int count) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => onSelect(id),
        borderRadius: BorderRadius.circular(11),
        hoverColor: AdminColors.amberSoft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: active ? AdminColors.yellow : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: active ? AdminColors.yellow : AdminColors.line,
            ),
          ),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w900 : FontWeight.w700)),
              if (count > 0) ...[
                const SizedBox(width: 7),
                Text(count.toString(), style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _CatalogueList extends StatelessWidget {
  const _CatalogueList({
    required this.products, required this.search, required this.foodFilter, required this.stockFilter,
    required this.availabilityFilter, required this.loading, required this.page, required this.lastPage,
    required this.total, required this.selected, required this.gridView, required this.onToggleView,
    required this.onSearch, required this.onFood, required this.onStock,
    required this.onAvailability, required this.onSelect, required this.onPage,
  });
  final List<_CatalogueProduct> products;
  final TextEditingController search;
  final String foodFilter, stockFilter, availabilityFilter;
  final bool loading, gridView;
  final int page, lastPage, total;
  final _CatalogueProduct? selected;
  final VoidCallback onToggleView, onSearch;
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
            Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('Select an item to edit. Use tile or list view.', style: TextStyle(fontSize: 13, color: AdminColors.muted)),
          ])),
          const SizedBox(width: 8),
          Tooltip(
            message: gridView ? 'Switch to list view' : 'Switch to tile view',
            child: shad.IconButton.ghost(
              onPressed: onToggleView,
              icon: AdminIcon(gridView ? HugeIcons.strokeRoundedMenu01 : HugeIcons.strokeRoundedGridView, size: 20),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: shad.TextField(controller: search, onSubmitted: (_) => onSearch(), placeholder: const Text('Search items...'), features: const [shad.InputLeadingFeature(AdminIcon(HugeIcons.strokeRoundedSearch01, size: 17))]),
        ),
        const SizedBox(height: 16),
        if (products.isEmpty && !loading)
          const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No items match your search.', style: TextStyle(color: AdminColors.muted))))
        else if (gridView)
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 720 ? 3 : constraints.maxWidth >= 460 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .82),
              itemBuilder: (_, index) => _ProductTile(
                product: products[index],
                selected: selected?.id == products[index].id && selected == products[index],
                onTap: () => onSelect(products[index]),
              ),
            );
          })
        else ...[
          const Row(children: [
            Expanded(flex: 5, child: Text('ITEM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .9, color: AdminColors.muted))),
            Expanded(flex: 3, child: Text('CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .9, color: AdminColors.muted))),
            SizedBox(width: 85, child: Text('STOCK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .9, color: AdminColors.muted))),
          ]),
          const Divider(height: 18),
          ...products.map((p) => _ProductRow(product: p, selected: selected?.id == p.id && selected == p, onTap: () => onSelect(p))),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text('Showing ' + (total == 0 ? '0' : '1') + '–' + products.length.toString() + ' of ' + total.toString(), style: const TextStyle(fontSize: 11, color: AdminColors.muted))),
          shad.IconButton.ghost(onPressed: page > 1 ? () => onPage(page - 1) : null, icon: const AdminIcon(HugeIcons.strokeRoundedArrowLeft01, size: 18)),
          Text(page.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          shad.IconButton.ghost(onPressed: page < lastPage ? () => onPage(page + 1) : null, icon: const AdminIcon(HugeIcons.strokeRoundedArrowRight01, size: 18)),
        ]),
      ]),
    ),
  );
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.selected, required this.onTap});
  final _CatalogueProduct product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _HoverSurface(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    selected: selected,
    child: Container(
      decoration: BoxDecoration(
        color: selected ? AdminColors.amberSoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AdminColors.amber : AdminColors.line, width: selected ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 1.35,
          child: Container(
            color: AdminColors.canvas,
            child: product.image != null && product.image!.isNotEmpty
                ? Image.network(product.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: AdminIcon(HugeIcons.strokeRoundedRestaurant01, size: 28, color: AdminColors.amber)))
                : const Center(child: AdminIcon(HugeIcons.strokeRoundedRestaurant01, size: 28, color: AdminColors.amber)),
          ),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
              if (product.badge.isNotEmpty) _Badge(product.badge),
            ]),
            const SizedBox(height: 6),
            Text(product.categoryName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AdminColors.muted)),
            const SizedBox(height: 6),
            Expanded(child: Text(product.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AdminColors.muted))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: Text('₹' + product.price.toStringAsFixed(0), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900))),
              Text(product.outOfStock ? 'Sold out' : product.stock.toString() + ' units', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: product.outOfStock ? AdminColors.red : product.lowStock ? AdminColors.warning : AdminColors.ink)),
            ]),
          ]),
        )),
      ]),
    ),
  );
}

class _HoverSurface extends StatefulWidget {
  const _HoverSurface({
    required this.child,
    required this.onTap,
    required this.borderRadius,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final bool selected;

  @override
  State<_HoverSurface> createState() => _HoverSurfaceState();
}

class _HoverSurfaceState extends State<_HoverSurface> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final lift = _hovered && !_pressed;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, lift ? -2 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: lift
                ? const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18,
                      offset: Offset(0, 7),
                    ),
                  ]
                : const [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final _CatalogueProduct product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      hoverColor: AdminColors.amberSoft,
      splashColor: AdminColors.amberSoft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(selected ? 2 : 0, 0, 0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AdminColors.amberSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    _Thumb(image: product.image, name: product.name),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.badge.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                _Badge(product.badge),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AdminColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  product.categoryName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 85,
                child: Text(
                  product.outOfStock
                      ? 'Sold out'
                      : '${product.stock} units',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: product.outOfStock
                        ? AdminColors.red
                        : product.lowStock
                            ? AdminColors.warning
                            : AdminColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.image, required this.name}); final String? image; final String name;
  @override Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(width: 50, height: 50, color: AdminColors.canvas, child: image != null && image!.isNotEmpty ? Image.network(image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()) : _placeholder()));
  Widget _placeholder() => const AdminIcon(HugeIcons.strokeRoundedRestaurant01, size: 22, color: AdminColors.amber);
}

class _Badge extends StatelessWidget {
  const _Badge(this.text); final String text;
  @override Widget build(BuildContext context) { final danger = text == 'Sold Out' || text.contains('Left'); final seasonal = text == 'Seasonal'; return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: danger ? AdminColors.redSoft : seasonal ? AdminColors.amberSoft : AdminColors.redSoft, borderRadius: BorderRadius.circular(5)), child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: danger ? AdminColors.red : AdminColors.ink))); }
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
    required this.onTags,
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
  final Future<String?> Function() onPickImage;
  final Future<void> Function() onSave;
  final Future<void> Function() onDeactivate;
  final ValueChanged<int?> onCategory;
  final ValueChanged<String> onDietary;
  final ValueChanged<List<String>> onTags;

  @override
  Widget build(BuildContext context) {
    var pickerPreview = imagePreview;
    var pickerUploading = uploading;
    final imagePicker = StatefulBuilder(
      builder: (context, setImagePickerState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Item Image', null),
            Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: pickerUploading
                ? null
                : () async {
                    setImagePickerState(() => pickerUploading = true);
                    final preview = await onPickImage();
                    if (preview != null) pickerPreview = preview;
                    setImagePickerState(() => pickerUploading = false);
                  },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: AdminColors.peach,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminColors.line),
              ),
              child: pickerPreview.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _imagePreviewWidget(pickerPreview),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AdminIcon(
                          uploading
                              ? HugeIcons.strokeRoundedHourglass
                              : HugeIcons.strokeRoundedCloudUpload,
                          size: 30,
                          color: AdminColors.amber,
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Browse image file',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'PNG, JPG, WEBP up to 4MB',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: AdminColors.muted),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _field(imageUrl, 'https://...', label: 'Image URL'),
        const SizedBox(height: 5),
        const Text(
          'Choose a file for preview or provide an image URL.',
          style: TextStyle(fontSize: 10, color: AdminColors.muted),
            ),
          ],
        );
      },
    );

    var editorCategoryId = formCategoryId;
    var editorDietary = formDietary;
    var editorTags = List<String>.of(selected?.tags ?? const <String>[]);

    final details = StatefulBuilder(
      builder: (context, setEditorState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        _label('Dish Name *', 'Required'),
        _field(name, 'Smokey Chicken Tikka Roll', maxLength: 180),
        const SizedBox(height: 12),
        _dropdownField(
          'Category',
          categories.map((c) => DropdownMenuItem<int?>(
            value: c.id,
            child: Text(c.name),
          )).toList(),
          editorCategoryId ?? (categories.isNotEmpty ? categories.first.id : null),
          (value) {
            setEditorState(() => editorCategoryId = value);
            onCategory(value);
          },
        ),
        const SizedBox(height: 12),
        _label('Dietary Classification', null),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: ['Pure Veg', 'Non-Veg', 'Contains Egg'].map((e) {
            final active = editorDietary == e;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setEditorState(() => editorDietary = e);
                  onDietary(e);
                },
                borderRadius: BorderRadius.circular(9),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? AdminColors.yellow : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: active ? AdminColors.amber : AdminColors.line,
                      width: active ? 1.2 : 1,
                    ),
                  ),
                  child: Text(
                    e,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _field(
                price,
                '₹220',
                label: 'Base Price (₹)',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _field(
                prep,
                '15',
                label: 'Prep Time (Min)',
                keyboard: TextInputType.number,
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
        if (editorTags.isEmpty)
          const Text('No tags yet', style: TextStyle(fontSize: 11, color: AdminColors.muted))
        else
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: editorTags.map(
              (e) => InputChip(
                label: Text(e, style: const TextStyle(fontSize: 11)),
                onDeleted: () {
                  setEditorState(() {
                    editorTags = List<String>.of(editorTags)..remove(e);
                  });
                  onTags(editorTags);
                },
              ),
            ).toList(),
          ),
        const SizedBox(height: 8),
        shad.OutlineButton(
          onPressed: () {
            final value = tag.text.trim();
            if (value.isEmpty || editorTags.contains(value)) return;
            setEditorState(() {
              editorTags = [...editorTags, value];
            });
            tag.clear();
            onTags(editorTags);
          },
          leading: const AdminIcon(HugeIcons.strokeRoundedAdd01, size: 15),
          child: const Text('Add tag', style: TextStyle(fontSize: 11)),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _field(stock, '0', label: 'Stock Quantity', keyboard: TextInputType.number),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Flexible(
                      child: Text('Live on app', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 6),
                    shad.Switch(
                      value: selected?.available ?? true,
                      onChanged: (v) {
                        if (selected != null) selected!.available = v;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: shad.PrimaryButton(
            onPressed: saving ? null : onSave,
            leading: AdminIcon(
              saving ? HugeIcons.strokeRoundedHourglass : HugeIcons.strokeRoundedFloppyDisk,
              size: 17,
            ),
            child: Text(saving ? 'Saving…' : 'Save Item'),
          ),
        ),
        if (!creating) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: shad.OutlineButton(
              onPressed: saving ? null : onDeactivate,
              child: const Text('Deactivate item', style: TextStyle(fontSize: 11, color: AdminColors.red)),
            ),
          ),
        ],
      ],
    );

    return Form(
      key: form,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use the full dialog content width so the editor is visually
          // balanced and does not leave a blank strip on the right.
          final availableWidth = constraints.maxWidth;
          final compact = availableWidth < 650;
          if (compact) {
            return Center(
              child: SizedBox(
                width: availableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    imagePicker,
                    const SizedBox(height: 20),
                    details,
                  ],
                ),
              ),
            );
          }

          final imageWidth = (availableWidth * 0.32).clamp(240.0, 300.0).toDouble();
          return SizedBox(
            width: availableWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: imageWidth, child: imagePicker),
                const SizedBox(width: 22),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: details,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _imagePreviewWidget(String source) {
  if (source.startsWith('data:image/')) {
    try {
      final comma = source.indexOf(',');
      if (comma > 0) {
        final bytes = base64Decode(source.substring(comma + 1));
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('Preview unavailable'),
          ),
        );
      }
    } catch (_) {}
  }
  return Image.network(
    source,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const Center(
      child: Text('Preview unavailable'),
    ),
  );
}

Widget _label(String text, String? trailing) => Padding(
  padding: const EdgeInsets.only(bottom: 5),
  child: Row(
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AdminColors.muted,
        ),
      ),
      if (trailing != null) ...[
        const SizedBox(width: 6),
        Text(
          trailing!,
          style: const TextStyle(fontSize: 11, color: AdminColors.muted),
        ),
      ],
    ],
  ),
);
Widget _field(TextEditingController c, String hint, {String? label, int? maxLength, int maxLines = 1, TextInputType? keyboard, String? Function(String?)? validator}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (label != null) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AdminColors.muted))),
    shad.TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      placeholder: Text(hint, style: const TextStyle(fontSize: 11, color: AdminColors.muted)),
    ),
  ],
);

Widget _dropdownField(
  String label,
  List<DropdownMenuItem<int?>> items,
  int? value,
  ValueChanged<int?> onChanged,
) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AdminColors.muted,
            ),
          ),
        ),
        Container(
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AdminColors.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: items.any((item) => item.value == value)
                  ? value
                  : (items.isEmpty ? null : items.first.value),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
              hint: const Text(
                'Select category',
                style: TextStyle(fontSize: 11, color: AdminColors.muted),
              ),
              onChanged: items.isEmpty ? null : onChanged,
              items: items,
            ),
          ),
        ),
      ],
    );


class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry;
  @override Widget build(BuildContext context) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AdminColors.redSoft, borderRadius: BorderRadius.circular(10)), child: Row(children: [const AdminIcon(HugeIcons.strokeRoundedAlertCircle, size: 17, color: AdminColors.red), const SizedBox(width: 8), Expanded(child: Text(message, style: const TextStyle(fontSize: 11))), shad.OutlineButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(fontSize: 11)))]));
}