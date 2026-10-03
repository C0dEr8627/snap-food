part of '../main.dart';

class SfDataTableColumn {
  const SfDataTableColumn({
    required this.label,
    this.width,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final double? width;
  final Alignment alignment;
}

class SfDataTable extends StatelessWidget {
  const SfDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.minWidth = 760,
    this.rowHeight = 68,
  });

  final List<SfDataTableColumn> columns;
  final List<List<Widget>> rows;
  final ValueChanged<int>? onRowTap;
  final double minWidth;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminDesignColors.surface,
        border: Border.all(color: AdminDesignColors.border),
        borderRadius: BorderRadius.circular(AdminRadii.card),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminRadii.card),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final naturalWidth = columns.fold<double>(
              0,
              (sum, column) => sum + (column.width ?? 160),
            );
            final width = math.max(
              minWidth,
              math.max(
                naturalWidth,
                constraints.maxWidth.isFinite ? constraints.maxWidth : minWidth,
              ),
            );
            final viewportWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : minWidth;
            return SizedBox(
              width: viewportWidth,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                child: Column(
                  children: [
                    Container(
                      height: 46,
                      decoration: const BoxDecoration(
                        color: AdminDesignColors.subtleSurface,
                        border: Border(
                          bottom: BorderSide(color: AdminDesignColors.border),
                        ),
                      ),
                      child: Row(
                        children: columns.map((column) {
                          return SizedBox(
                            width: column.width ?? 160,
                            child: Align(
                              alignment: column.alignment,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md),
                                child: Text(
                                  column.label.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AdminTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: .7,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    ...List.generate(rows.length, (index) {
                      final cells = rows[index];
                      return Material(
                        color: AdminDesignColors.surface,
                        child: InkWell(
                          onTap: onRowTap == null ? null : () => onRowTap!(index),
                          hoverColor: AdminDesignColors.canvas,
                          child: Container(
                            height: rowHeight,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AdminDesignColors.border),
                              ),
                            ),
                            child: Row(
                              children: List.generate(columns.length, (columnIndex) {
                                final column = columns[columnIndex];
                                final child = columnIndex < cells.length
                                    ? cells[columnIndex]
                                    : const SizedBox.shrink();
                                return SizedBox(
                                  width: column.width ?? 160,
                                  child: Align(
                                    alignment: column.alignment,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md),
                                      child: child,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SfTablePagination extends StatelessWidget {
  const SfTablePagination({
    super.key,
    required this.page,
    required this.lastPage,
    required this.total,
    this.onPrevious,
    this.onNext,
  });

  final int page;
  final int lastPage;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AdminSpacing.md),
    child: Row(
      children: [
        Text(
          'Page $page of $lastPage · $total records',
          style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText),
        ),
        const Spacer(),
        SfIconButton(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          onPressed: page > 1 ? onPrevious : null,
          tooltip: 'Previous page',
        ),
        const SizedBox(width: AdminSpacing.xs),
        SfIconButton(
          icon: HugeIcons.strokeRoundedArrowRight01,
          onPressed: page < lastPage ? onNext : null,
          tooltip: 'Next page',
        ),
      ],
    ),
  );
}
