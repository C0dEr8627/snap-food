part of '../main.dart';

class SfCommandPalette extends StatefulWidget {
  const SfCommandPalette({
    super.key,
    required this.sections,
    required this.selectedSection,
    required this.onSelectSection,
    this.onSearchInSection,
    this.onAddProduct,
    this.onManageCategories,
  });

  final List<AdminSection> sections;
  final AdminSection selectedSection;
  final ValueChanged<AdminSection> onSelectSection;
  final void Function(AdminSection, String)? onSearchInSection;
  final VoidCallback? onAddProduct;
  final VoidCallback? onManageCategories;

  static Future<void> show(
    BuildContext context, {
    required List<AdminSection> sections,
    required AdminSection selectedSection,
    required ValueChanged<AdminSection> onSelectSection,
    void Function(AdminSection, String)? onSearchInSection,
    VoidCallback? onAddProduct,
    VoidCallback? onManageCategories,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(.28),
      builder: (dialogContext) => SfCommandPalette(
        sections: sections,
        selectedSection: selectedSection,
        onSelectSection: (value) {
          Navigator.of(dialogContext).pop();
          onSelectSection(value);
        },
        onSearchInSection: onSearchInSection == null
            ? null
            : (value, query) {
                Navigator.of(dialogContext).pop();
                onSearchInSection(value, query);
              },
        onAddProduct: onAddProduct == null
            ? null
            : () {
                Navigator.of(dialogContext).pop();
                onAddProduct();
              },
        onManageCategories: onManageCategories == null
            ? null
            : () {
                Navigator.of(dialogContext).pop();
                onManageCategories();
              },
      ),
    );
  }

  @override
  State<SfCommandPalette> createState() => _SfCommandPaletteState();
}

class _SfCommandPaletteState extends State<SfCommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() => _query = _controller.text.trim().toLowerCase());

  List<AdminSection> get _matches {
    if (_query.isEmpty) return widget.sections;
    return widget.sections.where((section) {
      return section.label.toLowerCase().contains(_query) ||
          section.subtitle.toLowerCase().contains(_query);
    }).toList();
  }

  bool get _catalogueActionVisible =>
      widget.selectedSection == AdminSection.catalogue &&
      (_query.isEmpty ||
          'add product'.contains(_query) ||
          'new product'.contains(_query));

  bool get _categoriesActionVisible =>
      widget.selectedSection == AdminSection.catalogue &&
      (_query.isEmpty ||
          'manage categories'.contains(_query) ||
          'categories'.contains(_query));

  void _submit() {
    if (_matches.isNotEmpty) {
      final target = _matches.first;
      if (_query.isNotEmpty && widget.onSearchInSection != null) {
        widget.onSearchInSection!(target, _controller.text.trim());
      } else {
        widget.onSelectSection(target);
      }
      return;
    }
    if (_catalogueActionVisible && widget.onAddProduct != null) {
      widget.onAddProduct!();
      return;
    }
    if (_categoriesActionVisible && widget.onManageCategories != null) {
      widget.onManageCategories!();
    }
  }

  @override
  Widget build(BuildContext context) => Focus(
    autofocus: true,
    onKeyEvent: (_, event) {
      if (event is flutter.KeyDownEvent &&
          event.logicalKey == flutter.LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      }
      if (event is flutter.KeyDownEvent &&
          event.logicalKey == flutter.LogicalKeyboardKey.enter) {
        _submit();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      backgroundColor: AdminDesignColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminRadii.feature),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AdminSpacing.md),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: (_) => _submit(),
                autofocus: true,
                style: AdminTypography.body,
                decoration: InputDecoration(
                  hintText: 'Search orders, users, products…',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AdminSpacing.md),
                    child: AdminIcon(HugeIcons.strokeRoundedSearch01, size: 19),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: AdminSpacing.sm),
                    child: Center(
                      widthFactor: 1,
                      child: SfBadge(
                        label: 'ESC',
                        backgroundColor: AdminDesignColors.canvas,
                      ),
                    ),
                  ),
                  filled: true,
                  fillColor: AdminDesignColors.canvas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminRadii.input),
                    borderSide: const BorderSide(color: AdminDesignColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminRadii.input),
                    borderSide: const BorderSide(color: AdminDesignColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AdminRadii.input),
                    borderSide: const BorderSide(color: AdminDesignColors.ink, width: 1.2),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AdminDesignColors.border),
            Flexible(
              child: _matches.isEmpty && !_catalogueActionVisible && !_categoriesActionVisible
                  ? const SfEmptyState(
                      title: 'No matching destinations',
                      message: 'Try a section name such as Orders, Users or Products.',
                    )
                  : ListView(
                      padding: const EdgeInsets.all(AdminSpacing.sm),
                      shrinkWrap: true,
                      children: [
                        if (_matches.isNotEmpty) ...[
                          _PaletteSectionLabel(
                            label: _query.isEmpty ? 'Navigate' : 'Matching sections',
                          ),
                          ..._matches.map(
                            (section) => _PaletteItem(
                              icon: section.icon,
                              title: section.label,
                              subtitle: _query.isEmpty
                                  ? section.subtitle
                                  : 'Search “${_controller.text.trim()}” in ${section.label}.',
                              selected: section == widget.selectedSection,
                              shortcut: section == widget.selectedSection ? 'Current' : null,
                              onTap: () {
                                if (_query.isNotEmpty && widget.onSearchInSection != null) {
                                  widget.onSearchInSection!(section, _controller.text.trim());
                                } else {
                                  widget.onSelectSection(section);
                                }
                              },
                            ),
                          ),
                        ],
                        if (_catalogueActionVisible && widget.onAddProduct != null) ...[
                          const _PaletteSectionLabel(label: 'Actions'),
                          _PaletteItem(
                            icon: HugeIcons.strokeRoundedAdd01,
                            title: 'Add product',
                            subtitle: 'Create a catalogue product.',
                            onTap: widget.onAddProduct!,
                          ),
                        ],
                        if (_categoriesActionVisible && widget.onManageCategories != null)
                          _PaletteItem(
                            icon: HugeIcons.strokeRoundedTag01,
                            title: 'Manage categories',
                            subtitle: 'Open catalogue category management.',
                            onTap: widget.onManageCategories!,
                          ),
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminSpacing.md,
                vertical: AdminSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: AdminDesignColors.subtleSurface,
                border: Border(top: BorderSide(color: AdminDesignColors.border)),
              ),
              child: Row(
                children: [
                  Text('Enter', style: AdminTypography.caption),
                  const SizedBox(width: AdminSpacing.xs),
                  Text('select', style: AdminTypography.caption.copyWith(color: AdminDesignColors.secondaryText)),
                  const Spacer(),
                  Text('Esc', style: AdminTypography.caption),
                  const SizedBox(width: AdminSpacing.xs),
                  Text('close', style: AdminTypography.caption.copyWith(color: AdminDesignColors.secondaryText)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PaletteSectionLabel extends StatelessWidget {
  const _PaletteSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AdminSpacing.sm,
      AdminSpacing.sm,
      AdminSpacing.sm,
      AdminSpacing.xs,
    ),
    child: Text(
      label.toUpperCase(),
      style: AdminTypography.caption.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    ),
  );
}

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.shortcut,
  });

  final AdminIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;
  final String? shortcut;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '$title. $subtitle',
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? AdminDesignColors.yellowSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AdminRadii.control),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AdminRadii.control),
          hoverColor: AdminDesignColors.canvas,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminSpacing.sm,
              vertical: AdminSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected ? AdminDesignColors.surface : AdminDesignColors.canvas,
                    borderRadius: BorderRadius.circular(AdminRadii.control),
                    border: Border.all(color: AdminDesignColors.border),
                  ),
                  alignment: Alignment.center,
                  child: AdminIcon(icon, size: 18, color: AdminDesignColors.primaryText),
                ),
                const SizedBox(width: AdminSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AdminTypography.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AdminTypography.caption,
                      ),
                    ],
                  ),
                ),
                if (shortcut != null)
                  SfBadge(
                    label: shortcut!,
                    backgroundColor: AdminDesignColors.surface,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
