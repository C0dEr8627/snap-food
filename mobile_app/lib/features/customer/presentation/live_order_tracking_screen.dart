import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../design_system/components/snap_food_feedback.dart';
import '../../../design_system/components/snap_order_status.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_radii.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';
import 'order_controller.dart';
import '../data/order_models.dart';
import '../data/order_tracking_models.dart';

class LiveOrderTrackingScreen extends ConsumerStatefulWidget {
  const LiveOrderTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<LiveOrderTrackingScreen> createState() =>
      _LiveOrderTrackingScreenState();
}

class _LiveOrderTrackingScreenState
    extends ConsumerState<LiveOrderTrackingScreen> {
  Timer? _poller;

  @override
  void initState() {
    super.initState();
    if (widget.orderId.trim().isNotEmpty) {
      Future.microtask(_load);
      _poller = Timer.periodic(const Duration(seconds: 10), (_) => _load());
    }
  }

  Future<void> _load() async {
    if (!mounted || widget.orderId.trim().isEmpty) return;
    await ref
        .read(orderTrackingControllerProvider.notifier)
        .load(widget.orderId);
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(orderTrackingControllerProvider);

    return Scaffold(
      backgroundColor: SnapFoodColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: SnapFoodColors.surface,
              surfaceTintColor: Colors.transparent,
              leading: Semantics(
                button: true,
                label: 'Back',
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else if (widget.orderId.trim().isNotEmpty) {
                      context.go('/orders/' + Uri.encodeComponent(widget.orderId));
                    } else {
                      context.go('/orders');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              title: Text(
                widget.orderId.trim().isEmpty
                    ? 'Live tracking'
                    : 'Track #${widget.orderId}',
                style: SnapFoodTypography.titleMedium,
              ),
            ),
            if (widget.orderId.trim().isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _Unavailable(
                  message:
                      'Open tracking from a specific order to see live status.',
                ),
              )
            else
              tracking.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SnapLoadingState(
                    message: 'Loading live delivery status…',
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(error: error, onRetry: _load),
                ),
                data: (value) => value == null
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _Unavailable(
                          message: 'Delivery tracking is not available yet.',
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: _TrackingBody(
                          orderId: widget.orderId,
                          tracking: value,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrackingBody extends ConsumerWidget {
  const _TrackingBody({required this.orderId, required this.tracking});

  final String orderId;
  final OrderTracking tracking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = OrderStatus.fromWire(tracking.status);
    final location = tracking.latestLocation;

    return RefreshIndicator(
      onRefresh: () => ref
          .read(orderTrackingControllerProvider.notifier)
          .load(orderId),
      child: ListView(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          SnapFoodSpacing.mobileMargin,
          SnapFoodSpacing.sm,
          SnapFoodSpacing.mobileMargin,
          SnapFoodSpacing.xxl,
        ),
        children: [
          _StatusHero(status: status, tracking: tracking),
          const SizedBox(height: SnapFoodSpacing.md),
          _ProgressSection(status: status),
          if (tracking.deliveryPartner != null) ...[
            const SizedBox(height: SnapFoodSpacing.md),
            _DeliveryPartnerSection(partner: tracking.deliveryPartner!),
          ],
          const SizedBox(height: SnapFoodSpacing.md),
          _LocationSection(
            location: location,
            stale: tracking.isStale,
            partnerAssigned: tracking.deliveryPartner != null,
          ),
          const SizedBox(height: SnapFoodSpacing.md),
          _RefreshNote(stale: tracking.isStale),
        ],
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.status, required this.tracking});

  final OrderStatus status;
  final OrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    final isTerminal =
        status == OrderStatus.delivered || status == OrderStatus.cancelled;

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Current order status: ${_statusMessage(status, tracking)}',
      child: Container(
        padding: const EdgeInsets.all(SnapFoodSpacing.lg),
        decoration: BoxDecoration(
          color: SnapFoodColors.primaryContainer,
          borderRadius: BorderRadius.circular(SnapFoodRadii.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: SnapFoodColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(SnapFoodSpacing.sm),
                    child: Icon(
                      Icons.delivery_dining_rounded,
                      color: SnapFoodColors.secondary,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: SnapFoodSpacing.sm),
                Expanded(
                  child: Text(
                    _statusHeadline(status),
                    style: SnapFoodTypography.headlineSmall,
                  ),
                ),
                SnapOrderStatus(status: status, compact: true),
              ],
            ),
            const SizedBox(height: SnapFoodSpacing.md),
            Text(
              _statusMessage(status, tracking),
              style: SnapFoodTypography.bodyMedium.copyWith(
                color: SnapFoodColors.onSurfaceVariant,
              ),
            ),
            if (!isTerminal) ...[
              const SizedBox(height: SnapFoodSpacing.sm),
              Row(
                children: [
                  Icon(
                    tracking.isStale
                        ? Icons.sync_problem_rounded
                        : Icons.sync_rounded,
                    size: 16,
                    color: tracking.isStale
                        ? SnapFoodColors.onSurfaceVariant
                        : SnapFoodColors.secondary,
                  ),
                  const SizedBox(width: SnapFoodSpacing.xs),
                  Expanded(
                    child: Text(
                      tracking.isStale
                          ? 'Location updates may be delayed.'
                          : 'Live status refreshes while this screen is open.',
                      style: SnapFoodTypography.labelSmall.copyWith(
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.status});

  final OrderStatus status;

  static const _steps = [
    _TrackingStep(OrderStatus.placed, 'Order placed'),
    _TrackingStep(OrderStatus.accepted, 'Order accepted'),
    _TrackingStep(OrderStatus.preparing, 'Food is being prepared'),
    _TrackingStep(OrderStatus.readyForPickup, 'Ready for pickup'),
    _TrackingStep(OrderStatus.assigned, 'Delivery partner assigned'),
    _TrackingStep(OrderStatus.pickedUp, 'Picked up'),
    _TrackingStep(OrderStatus.outForDelivery, 'On the way'),
    _TrackingStep(OrderStatus.delivered, 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((step) => step.status == status);
    final resolvedIndex = currentIndex < 0
        ? status == OrderStatus.cancelled
            ? _steps.length - 1
            : 0
        : currentIndex;

    return _SectionSurface(
      title: 'Order progress',
      child: Column(
        children: [
          for (var index = 0; index < _steps.length; index++)
            _ProgressRow(
              label: _steps[index].label,
              completed:
                  index < resolvedIndex || status == OrderStatus.delivered,
              current: index == resolvedIndex &&
                  status != OrderStatus.delivered &&
                  status != OrderStatus.cancelled,
              last: index == _steps.length - 1,
            ),
          if (status == OrderStatus.cancelled) const _CancelledNotice(),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.completed,
    required this.current,
    required this.last,
  });

  final String label;
  final bool completed;
  final bool current;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final active = completed || current;

    return Semantics(
      container: true,
      label:
          '${label}${current ? ', current step' : completed ? ', complete' : ''}',
      child: SizedBox(
        height: last ? 42 : 52,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: current ? 18 : 14,
                    height: current ? 18 : 14,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: active
                          ? SnapFoodColors.secondary
                          : SnapFoodColors.softBorder,
                      shape: BoxShape.circle,
                      border: current
                          ? Border.all(
                              color: SnapFoodColors.softYellow,
                              width: 4,
                            )
                          : null,
                    ),
                    child: completed && !current
                        ? const Icon(
                            Icons.check_rounded,
                            size: 10,
                            color: SnapFoodColors.surface,
                          )
                        : null,
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: completed
                            ? SnapFoodColors.secondary
                            : SnapFoodColors.softBorder,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: SnapFoodSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: SnapFoodTypography.bodySmall.copyWith(
                  fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                  color: current
                      ? SnapFoodColors.warmBlack
                      : SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ),
            if (current)
              const Text(
                'Now',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: SnapFoodColors.secondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryPartnerSection extends StatelessWidget {
  const _DeliveryPartnerSection({required this.partner});

  final DeliveryPartnerContact partner;

  @override
  Widget build(BuildContext context) => _SectionSurface(
        title: 'Your delivery partner',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: SnapFoodColors.primaryContainer,
              child: Icon(Icons.person_outline_rounded, color: SnapFoodColors.secondary),
            ),
            const SizedBox(width: SnapFoodSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(partner.name, style: SnapFoodTypography.titleMedium),
                  const SizedBox(height: SnapFoodSpacing.xs),
                  if (partner.phone == null)
                    Text(
                      'Contact number is not available yet.',
                      style: SnapFoodTypography.bodySmall.copyWith(
                        color: SnapFoodColors.onSurfaceVariant,
                      ),
                    )
                  else ...[
                    SelectableText(
                      partner.phone!,
                      style: SnapFoodTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: SnapFoodSpacing.xs),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: partner.phone!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Phone number copied')),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy phone number'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.location,
    required this.stale,
    required this.partnerAssigned,
  });

  final OrderTrackingLocation? location;
  final bool stale;
  final bool partnerAssigned;

  @override
  Widget build(BuildContext context) {
    return _SectionSurface(
      title: 'Delivery location',
      child: location == null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_searching_rounded,
                  color: SnapFoodColors.onSurfaceVariant,
                ),
                SizedBox(width: SnapFoodSpacing.sm),
                Expanded(
                  child: Text(
                    partnerAssigned
                        ? 'Your delivery partner has not shared a location yet.'
                        : 'Live location will become available after a delivery partner is assigned.',
                  ),
                ),
              ],
            )
          : Semantics(
              container: true,
              label: 'Latest delivery location available',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    color: SnapFoodColors.secondary,
                  ),
                  const SizedBox(width: SnapFoodSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${location!.latitude.toStringAsFixed(5)}°, '
                          '${location!.longitude.toStringAsFixed(5)}°',
                          style: SnapFoodTypography.titleSmall,
                        ),
                        const SizedBox(height: SnapFoodSpacing.xs),
                        Text(
                          stale
                              ? 'This location may be outdated.'
                              : location!.recordedAt == null
                                  ? 'Latest location received.'
                                  : 'Updated ${_formatDateTime(location!.recordedAt!)}',
                          style: SnapFoodTypography.bodySmall.copyWith(
                            color: SnapFoodColors.onSurfaceVariant,
                          ),
                        ),
                        if (location!.accuracy != null) ...[
                          const SizedBox(height: SnapFoodSpacing.xs),
                          Text(
                            'Accuracy ±${location!.accuracy!.toStringAsFixed(0)} m',
                            style: SnapFoodTypography.labelSmall.copyWith(
                              color: SnapFoodColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _RefreshNote extends StatelessWidget {
  const _RefreshNote({required this.stale});

  final bool stale;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SnapFoodSpacing.md,
          vertical: SnapFoodSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: stale
              ? SnapFoodColors.softYellow
              : SnapFoodColors.surfaceContainer,
          borderRadius: BorderRadius.circular(SnapFoodRadii.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              stale ? Icons.info_outline_rounded : Icons.refresh_rounded,
              size: 15,
              color: SnapFoodColors.onSurfaceVariant,
            ),
            const SizedBox(width: SnapFoodSpacing.xs),
            Flexible(
              child: Text(
                stale
                    ? 'The latest tracking update is stale. Pull to refresh.'
                    : 'Pull down anytime to refresh tracking.',
                textAlign: TextAlign.center,
                style: SnapFoodTypography.labelSmall.copyWith(
                  color: SnapFoodColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
}

class _SectionSurface extends StatelessWidget {
  const _SectionSurface({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(SnapFoodSpacing.md),
        decoration: BoxDecoration(
          color: SnapFoodColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SnapFoodRadii.lg),
          border: Border.all(color: SnapFoodColors.softBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: SnapFoodTypography.titleSmall),
            const SizedBox(height: SnapFoodSpacing.md),
            child,
          ],
        ),
      );
}

class _CancelledNotice extends StatelessWidget {
  const _CancelledNotice();

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: SnapFoodSpacing.sm),
        padding: const EdgeInsets.all(SnapFoodSpacing.sm),
        decoration: BoxDecoration(
          color: SnapFoodColors.softRed,
          borderRadius: BorderRadius.circular(SnapFoodRadii.md),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, size: 17),
            SizedBox(width: SnapFoodSpacing.sm),
            Expanded(
              child: Text(
                'This order was cancelled, so delivery tracking has stopped.',
              ),
            ),
          ],
        ),
      );
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => SnapEmptyState(
        icon: Icons.location_searching_outlined,
        title: 'Tracking unavailable',
        message: message,
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ApiException
        ? (error as ApiException).message
        : 'We could not load live tracking.';

    return SnapErrorState(
      title: 'Tracking unavailable',
      message: message,
      onRetry: onRetry,
    );
  }
}

String _statusHeadline(OrderStatus status) => switch (status) {
      OrderStatus.placed => 'We have your order',
      OrderStatus.accepted => 'Your order is accepted',
      OrderStatus.preparing => 'Your food is being prepared',
      OrderStatus.readyForPickup => 'Your order is ready',
      OrderStatus.assigned => 'A delivery partner is assigned',
      OrderStatus.pickedUp => 'Your order has been picked up',
      OrderStatus.outForDelivery => 'Your order is on the way',
      OrderStatus.delivered => 'Order delivered',
      OrderStatus.cancelled => 'Order cancelled',
      OrderStatus.unknown => 'Tracking status unavailable',
    };

String _statusMessage(OrderStatus status, OrderTracking tracking) {
  if (status == OrderStatus.cancelled) {
    return 'This order is no longer moving through the delivery flow.';
  }
  if (status == OrderStatus.delivered) {
    return 'Your order has reached its delivery status.';
  }
  if (tracking.deliveryPartner == null) {
    return 'Your order is being processed. Delivery partner details will appear here as soon as one is assigned.';
  }
  if (tracking.isStale) {
    return 'The latest delivery update is older than expected. The status above remains the latest server response.';
  }
  if (tracking.latestLocation == null) {
    return 'We are waiting for the latest delivery location from the tracking service.';
  }
  return 'The latest delivery location is available from the tracking service.';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}/${local.month}/${local.year} $hour:$minute';
}

class _TrackingStep {
  const _TrackingStep(this.status, this.label);

  final OrderStatus status;
  final String label;
}
