part of '../main.dart';

class CategoriesPage extends flutter.StatefulWidget {
  const CategoriesPage({super.key, this.searchQuery = ''});
  final String searchQuery;
  @override flutter.State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends flutter.State<CategoriesPage> {
  final _repo = _CatalogueRepository();
  final _search = TextEditingController();
  List<_CatalogueCategory> _categories = List.of(_previewCatalogueCategories);
  bool _loading = false;
  bool _live = false;
  String _error = '';

  @override void initState() {
    super.initState(); _search.text = widget.searchQuery; _live = _repo.liveEnabled; _load();
  }
  @override void didUpdateWidget(covariant CategoriesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery && _search.text != widget.searchQuery) { _search.text = widget.searchQuery; setState(() {}); }
  }
  @override void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      if (_repo.liveEnabled) {
        final fresh = await _repo.categories(); if (!mounted) return;
        setState(() { _categories = fresh; _live = true; });
      } else {
        setState(() { _categories = List.of(_previewCatalogueCategories); _live = false; });
      }
    } catch (e) { if (!mounted) return; setState(() => _error = e.toString()); SfFeedback.showError(context, _error); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  List<_CatalogueCategory> get _filtered {
    final query = _search.text.trim().toLowerCase();
    final result = _categories.where((category) => query.isEmpty || category.name.toLowerCase().contains(query) || category.slug.toLowerCase().contains(query)).toList();
    result.sort((a, b) { final order = a.sortOrder.compareTo(b.sortOrder); return order != 0 ? order : a.name.toLowerCase().compareTo(b.name.toLowerCase()); });
    return result;
  }

  Future<void> _openEditor([_CatalogueCategory? category]) async {
    final name = TextEditingController(text: category?.name ?? '');
    final slug = TextEditingController(text: category?.slug ?? '');
    final order = TextEditingController(text: (category?.sortOrder ?? _nextSortOrder).toString());
    var active = category?.active ?? true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Material(
          color: Colors.transparent,
          child: AlertDialog(
          title: Text(category == null ? 'Add category' : 'Edit category'),
          content: SizedBox(width: 440, child: Column(mainAxisSize: MainAxisSize.min, children: [
            SfInput(controller: name, label: 'Category name', hintText: 'e.g. Breakfast'),
            const SizedBox(height: AdminSpacing.md),
            SfInput(controller: slug, label: 'Slug', hintText: 'breakfast'),
            const SizedBox(height: AdminSpacing.md),
            SfInput(controller: order, label: 'Sort order', hintText: '0'),
            const SizedBox(height: AdminSpacing.md),
            Row(children: [Expanded(child: Text('Active on the app', style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600))), Switch(value: active, onChanged: (value) => setDialogState(() => active = value))]),
          ])),
          actions: [
            SfButton(variant: SfButtonVariant.ghost, onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            SfButton(onPressed: () async {
              final validation = _validateCategory(name.text, slug.text, order.text);
              if (validation != null) { SfFeedback.showError(dialogContext, validation); return; }
              Navigator.of(dialogContext).pop();
              await _saveCategory(id: category?.id, name: name.text.trim(), slug: slug.text.trim(), sortOrder: int.parse(order.text.trim()), active: active);
            }, child: Text(category == null ? 'Create category' : 'Save changes')),
          ],
          ),
        ),
      ),
    );
    name.dispose(); slug.dispose(); order.dispose();
  }

  String? _validateCategory(String name, String slug, String order) {
    if (name.trim().isEmpty) return 'Category name is required.';
    if (slug.trim().isEmpty || !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(slug.trim())) return 'Use letters, numbers, - or _ for the slug.';
    final parsedOrder = int.tryParse(order.trim());
    if (parsedOrder == null || parsedOrder < 0) return 'Sort order must be 0 or greater.';
    return null;
  }
  int get _nextSortOrder => _categories.isEmpty ? 0 : _categories.map((c) => c.sortOrder).reduce(math.max) + 1;

  Future<void> _saveCategory({int? id, required String name, required String slug, required int sortOrder, required bool active}) async {
    setState(() => _loading = true);
    try {
      final saved = await _repo.saveCategory(id: id, name: name, slug: slug, sortOrder: sortOrder, active: active);
      if (_live) { await _load(); } else {
        final index = _categories.indexWhere((item) => item.id == id);
        final updated = _CatalogueCategory(id: saved.id ?? id, name: saved.name, slug: saved.slug, sortOrder: saved.sortOrder, active: saved.active, count: index >= 0 ? _categories[index].count : saved.count);
        setState(() { if (index >= 0) { _categories[index] = updated; } else { _categories.add(updated); } _loading = false; });
      }
      if (mounted) SfFeedback.showSuccess(context, id == null ? 'Category created successfully.' : 'Category updated successfully.');
    } catch (e) { if (mounted) { setState(() => _loading = false); SfFeedback.showError(context, e.toString()); } }
  }

  Future<void> _toggleActive(_CatalogueCategory category) async {
    if (category.id == null) return; final active = !category.active;
    try {
      setState(() => _loading = true); await _repo.setCategoryActive(category.id!, active);
      if (_live) { await _load(); } else {
        final index = _categories.indexWhere((item) => item.id == category.id);
        if (index >= 0) { final old = _categories[index]; setState(() { _categories[index] = _CatalogueCategory(id: old.id, name: old.name, slug: old.slug, sortOrder: old.sortOrder, active: active, count: old.count); _loading = false; }); } else { setState(() => _loading = false); }
      }
      if (mounted) SfFeedback.showSuccess(context, active ? 'Category activated.' : 'Category deactivated.');
    } catch (e) { if (mounted) { setState(() => _loading = false); SfFeedback.showError(context, e.toString()); } }
  }

  Future<void> _delete(_CatalogueCategory category) async {
    if (category.id == null) return;
    if (category.count > 0) { SfFeedback.showInfo(context, 'This category has assigned products. Deactivate it instead.'); return; }
    final confirmed = await SfConfirmDialog.show(context, title: 'Delete category?', message: 'This permanently removes "' + category.name + '". This action cannot be undone.', confirmLabel: 'Delete category', destructive: true);
    if (!confirmed) return;
    try {
      setState(() => _loading = true); await _repo.deleteCategory(category.id!);
      if (_live) { await _load(); } else { setState(() { _categories.removeWhere((item) => item.id == category.id); _loading = false; }); }
      if (mounted) SfFeedback.showSuccess(context, 'Category deleted permanently.');
    } catch (e) { if (mounted) { setState(() => _loading = false); SfFeedback.showError(context, e.toString()); } }
  }

  @override flutter.Widget build(BuildContext context) {
    final rows = _filtered;
    final activeCount = _categories.where((item) => item.active).length;
    final inactiveCount = _categories.length - activeCount;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_error.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: AdminSpacing.md), child: SfErrorState(title: 'Categories could not be loaded', message: _error, onRetry: _load)),
      SfCard(padding: const EdgeInsets.all(AdminSpacing.lg), child: LayoutBuilder(builder: (context, constraints) => Wrap(spacing: AdminSpacing.md, runSpacing: AdminSpacing.md, crossAxisAlignment: WrapCrossAlignment.center, children: [
        SizedBox(width: constraints.maxWidth >= 760 ? 420 : constraints.maxWidth.clamp(220.0, 420.0), child: SfSearchField(controller: _search, hintText: 'Search categories by name or slug', onSubmitted: (_) => setState(() {}), onChanged: (_) => setState(() {}))),
        SfBadge(label: _live ? 'Live API' : 'Preview data', backgroundColor: _live ? AdminDesignColors.successSoft : AdminDesignColors.warningSoft, foregroundColor: _live ? AdminDesignColors.success : AdminDesignColors.warning),
        SfBadge(label: _categories.length.toString() + ' total', backgroundColor: AdminDesignColors.subtleSurface, foregroundColor: AdminDesignColors.secondaryText),
        SfBadge(label: activeCount.toString() + ' active', backgroundColor: AdminDesignColors.successSoft, foregroundColor: AdminDesignColors.success),
        if (inactiveCount > 0) SfBadge(label: inactiveCount.toString() + ' inactive', backgroundColor: AdminDesignColors.warningSoft, foregroundColor: AdminDesignColors.warning),
      ]))),
      const SizedBox(height: AdminSpacing.lg),
      if (_categories.isEmpty && !_loading)
        SfEmptyState(
          icon: HugeIcons.strokeRoundedFolder01,
          title: 'No categories yet',
          message: _live ? 'Create the first category to organize catalogue items.' : 'Preview mode has no category records to show.',
          action: SfButton(onPressed: () => _openEditor(), child: const Text('Add category')),
        )
      else
        SfDataTable(minWidth: 820, columns: const [
          SfDataTableColumn(label: 'Category', width: 260), SfDataTableColumn(label: 'Slug', width: 210),
          SfDataTableColumn(label: 'Items', width: 100, alignment: Alignment.centerRight), SfDataTableColumn(label: 'Status', width: 130),
          SfDataTableColumn(label: 'Order', width: 90, alignment: Alignment.centerRight), SfDataTableColumn(label: 'Actions', width: 160),
        ], rows: [
          for (final category in rows) [
            Text(category.name, overflow: TextOverflow.ellipsis, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w700)),
            Text(category.slug.isEmpty ? '—' : category.slug, overflow: TextOverflow.ellipsis, style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText)),
            Align(alignment: Alignment.centerRight, child: Text(category.count.toString(), style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600))),
            SfStatusBadge(label: category.active ? 'Active' : 'Inactive', status: category.active ? 'success' : 'neutral'),
            Align(alignment: Alignment.centerRight, child: Text(category.sortOrder.toString(), style: AdminTypography.small)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              SfIconButton(icon: HugeIcons.strokeRoundedEdit02, tooltip: 'Edit category', onPressed: _loading ? null : () => _openEditor(category)),
              SfIconButton(icon: category.active ? HugeIcons.strokeRoundedViewOff : HugeIcons.strokeRoundedView, tooltip: category.active ? 'Deactivate category' : 'Activate category', onPressed: _loading ? null : () => _toggleActive(category)),
              SfIconButton(icon: HugeIcons.strokeRoundedDelete02, tooltip: 'Delete category', onPressed: _loading || category.count > 0 ? null : () => _delete(category)),
            ]),
          ],
        ], onRowTap: (index) => _openEditor(rows[index])),
      if (_loading) ...[const SizedBox(height: AdminSpacing.md), const SfSkeleton(width: double.infinity, height: 4)],
    ]);
  }
}