part of '../main.dart';

enum SfButtonVariant { primary, secondary, outline, ghost, destructive }

const _adminMotion = AdminMotion.hover;

class SfButton extends flutter.StatelessWidget {
  const SfButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = SfButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final VoidCallback? onPressed;
  final flutter.Widget child;
  final SfButtonVariant variant;
  final AdminIconData? icon;
  final bool loading;
  final bool expand;

  @override
  flutter.Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final background = switch (variant) {
      SfButtonVariant.primary => AdminDesignColors.ink,
      SfButtonVariant.secondary => AdminDesignColors.yellowSoft,
      SfButtonVariant.outline => AdminDesignColors.surface,
      SfButtonVariant.ghost => Colors.transparent,
      SfButtonVariant.destructive => AdminDesignColors.error,
    };
    final foreground = switch (variant) {
      SfButtonVariant.primary => Colors.white,
      SfButtonVariant.secondary => AdminDesignColors.primaryText,
      SfButtonVariant.outline => AdminDesignColors.primaryText,
      SfButtonVariant.ghost => AdminDesignColors.primaryText,
      SfButtonVariant.destructive => Colors.white,
    };

    flutter.Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AdminRadii.control),
        child: AnimatedContainer(
          duration: _adminMotion,
          curve: AdminMotion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: enabled ? background : AdminDesignColors.canvas,
            borderRadius: BorderRadius.circular(AdminRadii.control),
            border: variant == SfButtonVariant.outline
                ? const Border.fromBorderSide(BorderSide(color: AdminDesignColors.border))
                : null,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: enabled ? foreground : AdminDesignColors.tertiaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (icon != null) ...[
                  AdminIcon(icon!, size: 17, color: foreground),
                  const SizedBox(width: 8),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
      );

    if (expand) button = SizedBox(width: double.infinity, child: button);
    return Semantics(
      button: true,
      enabled: enabled,
      child: button,
    );
  }
}


class SfIconButton extends flutter.StatelessWidget {
  const SfIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
  });

  final AdminIconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;

  @override
  flutter.Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: Material(
        color: selected ? AdminDesignColors.yellowSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(AdminRadii.control),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AdminRadii.control),
        focusColor: AdminDesignColors.yellowSoft,
        hoverColor: AdminDesignColors.canvas,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: AdminIcon(icon, size: 18, color: AdminDesignColors.primaryText),
          ),
        ),
      ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}


class SfAnimatedSwitcher extends flutter.StatelessWidget {
  const SfAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = AdminMotion.dataUpdate,
  });

  final flutter.Widget child;
  final Duration duration;

  @override
  flutter.Widget build(BuildContext context) => AnimatedSwitcher(
    duration: duration,
    switchInCurve: AdminMotion.curve,
    switchOutCurve: AdminMotion.curve,
    child: child,
  );
}

class SfInput extends flutter.StatelessWidget {
  const SfInput({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final AdminIconData? prefixIcon;
  final flutter.Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  flutter.Widget build(BuildContext context) => TextFormField(
    controller: controller,
    focusNode: focusNode,
    enabled: enabled,
    obscureText: obscureText,
    onChanged: onChanged,
    style: AdminTypography.body,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AdminIcon(prefixIcon!, size: 18, color: AdminDesignColors.secondaryText),
            ),
      suffixIcon: suffixIcon,
    ),
  );
}

class SfSearchField extends flutter.StatelessWidget {
  const SfSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  flutter.Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: autofocus,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    textInputAction: TextInputAction.search,
    style: AdminTypography.body,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: AdminIcon(HugeIcons.strokeRoundedSearch01, size: 18),
      ),
      isDense: true,
    ),
  );
}

class SfFormSection extends flutter.StatelessWidget {
  const SfFormSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
  });

  final String title;
  final String? description;
  final flutter.Widget child;

  @override
  flutter.Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AdminTypography.cardTitle),
      if (description != null) ...[
        const SizedBox(height: AdminSpacing.xxs),
        Text(description!, style: AdminTypography.small.copyWith(color: AdminDesignColors.secondaryText)),
      ],
      const SizedBox(height: AdminSpacing.md),
      child,
    ],
  );
}

class SfFormField extends flutter.StatelessWidget {
  const SfFormField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.validator,
    this.requiredField = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? Function(String?)? validator;
  final bool requiredField;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool obscureText;

  @override
  flutter.Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: enabled,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLines: maxLines,
    maxLength: maxLength,
    validator: validator,
    style: AdminTypography.body,
    decoration: InputDecoration(
      label: label == null ? null : RichText(
        text: TextSpan(
          style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText),
          children: [
            TextSpan(text: label!),
            if (requiredField) const TextSpan(text: ' *', style: TextStyle(color: AdminDesignColors.error)),
          ],
        ),
      ),
      hintText: hintText,
      helperText: helperText,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md, vertical: 13),
    ),
  );
}

class SfBadge extends flutter.StatelessWidget {
  const SfBadge({super.key, required this.label, this.backgroundColor, this.foregroundColor});

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  flutter.Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: backgroundColor ?? AdminDesignColors.canvas,
      borderRadius: BorderRadius.circular(AdminRadii.pill),
      border: Border.all(color: AdminDesignColors.border),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: foregroundColor ?? AdminDesignColors.secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    ),
  );
}

class SfStatusBadge extends flutter.StatelessWidget {
  const SfStatusBadge({super.key, required this.label, this.status});

  final String label;
  final String? status;

  @override
  flutter.Widget build(BuildContext context) {
    final value = (status ?? label).toLowerCase();
    final (Color, Color) colors = switch (value) {
      final s when s.contains('success') ||
          s.contains('complete') ||
          s.contains('deliver') ||
          s.contains('approved') ||
          s.contains('available') ||
          s.contains('ready') => (AdminDesignColors.successSoft, AdminDesignColors.success),
      final s when s.contains('pending') ||
          s.contains('prepar') ||
          s.contains('wait') => (AdminDesignColors.warningSoft, AdminDesignColors.warning),
      final s when s.contains('fail') ||
          s.contains('cancel') ||
          s.contains('reject') ||
          s.contains('suspend') => (AdminDesignColors.errorSoft, AdminDesignColors.error),
      final s when s.contains('info') ||
          s.contains('new') ||
          s.contains('active') => (AdminDesignColors.infoSoft, AdminDesignColors.info),
      _ => (AdminDesignColors.canvas, AdminDesignColors.secondaryText),
    };
    return Semantics(
      label: 'Status: $label',
      child: SfBadge(label: label, backgroundColor: colors.$1, foregroundColor: colors.$2),
    );
  }
}

class SfCard extends flutter.StatelessWidget {
  const SfCard({super.key, required this.child, this.padding = const EdgeInsets.all(AdminSpacing.lg)});

  final flutter.Widget child;
  final EdgeInsetsGeometry padding;

  @override
  flutter.Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: AdminDesignColors.surface,
      borderRadius: BorderRadius.circular(AdminRadii.card),
      border: Border.all(color: AdminDesignColors.border),
    ),
    child: child,
  );
}

class SfStat extends flutter.StatelessWidget {
  const SfStat({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.icon,
    this.status,
  });

  final String label;
  final String value;
  final String? helper;
  final AdminIconData? icon;
  final SfStatusBadge? status;

  @override
  flutter.Widget build(BuildContext context) => SfCard(
    padding: const EdgeInsets.all(AdminSpacing.lg),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AdminTypography.small),
              const SizedBox(height: AdminSpacing.xs),
              Text(value, style: AdminTypography.pageTitle),
              if (helper != null) ...[
                const SizedBox(height: AdminSpacing.xs),
                Text(helper!, style: AdminTypography.small),
              ],
              if (status != null) ...[
                const SizedBox(height: AdminSpacing.sm),
                status!,
              ],
            ],
          ),
        ),
        if (icon != null)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AdminDesignColors.yellowSoft,
              borderRadius: BorderRadius.circular(AdminRadii.control),
            ),
            alignment: Alignment.center,
            child: AdminIcon(icon!, size: 20, color: AdminDesignColors.ink),
          ),
      ],
    ),
  );
}

class SfPageHeader extends flutter.StatelessWidget {
  const SfPageHeader({
    super.key,
    required this.title,
    this.description,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final flutter.Widget? leading;
  final List<flutter.Widget> actions;

  @override
  flutter.Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked = constraints.maxWidth < 720;
      final titleBlock = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: AdminSpacing.sm)],
              Flexible(child: Text(title, style: AdminTypography.pageTitle)),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AdminSpacing.xs),
            Text(description!, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
          ],
        ],
      );
      final actionBlock = Wrap(spacing: AdminSpacing.sm, runSpacing: AdminSpacing.sm, children: actions);
      return stacked
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [titleBlock, if (actions.isNotEmpty) ...[const SizedBox(height: AdminSpacing.md), actionBlock]])
          : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: titleBlock), if (actions.isNotEmpty) actionBlock]);
    },
  );
}

class SfFilterBar extends flutter.StatelessWidget {
  const SfFilterBar({super.key, this.leading, this.filters = const [], this.trailing = const []});

  final flutter.Widget? leading;
  final List<flutter.Widget> filters;
  final List<flutter.Widget> trailing;

  @override
  flutter.Widget build(BuildContext context) => SfCard(
    padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md, vertical: AdminSpacing.sm),
    child: Wrap(
      spacing: AdminSpacing.sm,
      runSpacing: AdminSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (leading != null) leading!,
        ...filters,
        ...trailing,
      ],
    ),
  );
}

class SfEmptyState extends flutter.StatelessWidget {
  const SfEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = HugeIcons.strokeRoundedInbox,
    this.action,
  });

  final String title;
  final String message;
  final AdminIconData icon;
  final flutter.Widget? action;

  @override
  flutter.Widget build(BuildContext context) => SfCard(
    padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.xl, vertical: AdminSpacing.huge),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AdminDesignColors.yellowSoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AdminIcon(icon, size: 32, color: AdminDesignColors.ink),
        ),
        const SizedBox(height: AdminSpacing.lg),
        Text(title, textAlign: TextAlign.center, style: AdminTypography.sectionTitle),
        const SizedBox(height: AdminSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(message, textAlign: TextAlign.center, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
        ),
        if (action != null) ...[const SizedBox(height: AdminSpacing.lg), action!],
      ],
    ),
  );
}

class SfErrorState extends flutter.StatelessWidget {
  const SfErrorState({super.key, required this.title, required this.message, this.onRetry});

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  flutter.Widget build(BuildContext context) => SfCard(
    padding: const EdgeInsets.all(AdminSpacing.xl),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminIcon(HugeIcons.strokeRoundedAlert02, size: 32, color: AdminDesignColors.error),
        const SizedBox(width: AdminSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AdminTypography.cardTitle),
              const SizedBox(height: AdminSpacing.xs),
              Text(message, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
              if (onRetry != null) ...[const SizedBox(height: AdminSpacing.md), SfButton(onPressed: onRetry, variant: SfButtonVariant.outline, child: const Text('Try again'))],
            ],
          ),
        ),
      ],
    ),
  );
}

class SfLoadingState extends flutter.StatelessWidget {
  const SfLoadingState({
    super.key,
    this.title = 'Loading…',
    this.message = 'Please wait while the latest data is loaded.',
    this.compact = false,
  });
  final String title;
  final String message;
  final bool compact;
  @override
  flutter.Widget build(BuildContext context) => SfCard(
    padding: EdgeInsets.all(compact ? AdminSpacing.lg : AdminSpacing.xl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)),
        const SizedBox(height: AdminSpacing.md),
        Text(title, textAlign: TextAlign.center, style: AdminTypography.cardTitle),
        if (!compact) ...[
          const SizedBox(height: AdminSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(message, textAlign: TextAlign.center, style: AdminTypography.body.copyWith(color: AdminDesignColors.secondaryText)),
          ),
        ],
      ],
    ),
  );
}

class SfSkeleton extends flutter.StatefulWidget {
  const SfSkeleton({super.key, this.width, this.height = 16, this.radius = AdminRadii.control});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SfSkeleton> createState() => _SfSkeletonState();
}

class _SfSkeletonState extends flutter.State<SfSkeleton> with flutter.SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  flutter.Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Opacity(
      opacity: 0.45 + (_controller.value * 0.25),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AdminDesignColors.border,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    ),
  );
}

class SfAvatar extends flutter.StatelessWidget {
  const SfAvatar({super.key, this.name, this.imageUrl, this.size = 40, this.backgroundColor, this.foregroundColor});

  final String? name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  flutter.Widget build(BuildContext context) {
    final initials = _avatarInitials(name);
    return Semantics(
      label: name == null ? 'Avatar' : 'Avatar for $name',
      image: true,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: AdminDesignColors.yellowSoft,
        foregroundImage: imageUrl == null || imageUrl!.isEmpty ? null : NetworkImage(imageUrl!),
        child: Text(initials, style: TextStyle(fontSize: size * .3, fontWeight: FontWeight.w700, color: AdminDesignColors.ink)),
      ),
    );
  }
}

String _avatarInitials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
}
