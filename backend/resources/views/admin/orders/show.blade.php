<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Order #{{ $order->id }} · Snap Foodd Admin</title>
</head>
<body>
    <header>
        <h1><a href="{{ route('admin.dashboard') }}">Snap Foodd Admin</a></h1>
        <nav>
            <a href="{{ route('admin.catalogue.index') }}">Catalogue</a> · <a href="{{ route('admin.orders.index') }}">Orders</a>
            <form method="POST" action="{{ route('admin.logout') }}" style="display:inline">
                @csrf
                <button type="submit">Sign out</button>
            </form>
        </nav>
    </header>

    <main>
        <p><a href="{{ route('admin.orders.index') }}">← Back to orders</a></p>
        <h2>Order #{{ $order->id }}</h2>

        @if (session('status'))
            <p role="status">{{ session('status') }}</p>
        @endif

        <dl>
            <dt>Customer</dt>
            <dd>{{ $order->customer->name }} ({{ $order->customer->email }})</dd>
            <dt>Status</dt>
            <dd>{{ $order->status }}</dd>
            <dt>Payment</dt>
            <dd>{{ $order->payment_method }} / {{ $order->payment_status }}</dd>
            <dt>Subtotal</dt>
            <dd>{{ $order->subtotal }}</dd>
            <dt>Delivery fee</dt>
            <dd>{{ $order->delivery_fee }}</dd>
            <dt>Total</dt>
            <dd>{{ $order->total }}</dd>
        </dl>

        @if (count($nextStatuses) > 0)
            <section>
                <h3>Change status</h3>
                <form method="POST" action="{{ route('admin.orders.status', $order) }}">
                    @csrf
                    <label>
                        New status
                        <select name="status" required>
                            @foreach ($nextStatuses as $status)
                                <option value="{{ $status }}">{{ $status }}</option>
                            @endforeach
                        </select>
                    </label>
                    <button type="submit">Update status</button>
                </form>
                @error('status')<p>{{ $message }}</p>@enderror
            </section>
        @endif

        <section>
            <h3>Items</h3>
            <ul>
                @forelse ($order->items as $item)
                    <li>{{ $item->product_name }} × {{ $item->quantity }} @ {{ $item->unit_price }} = {{ $item->line_total }}</li>
                @empty
                    <li>No item snapshot available.</li>
                @endforelse
            </ul>
        </section>

        <section>
            <h3>Delivery</h3>
            <p>{{ $order->assignment?->deliveryPartner?->user?->name ?? 'Unassigned' }}</p>
            @if ($order->assignment)
                <p>Assigned at: {{ $order->assignment->assigned_at?->toIso8601String() }}</p>
            @elseif ($order->status === 'READY_FOR_PICKUP')
                <h4>Assign delivery partner</h4>
                @if ($eligiblePartners->isNotEmpty())
                    <form method="POST" action="{{ route('admin.orders.assignment', $order) }}">
                        @csrf
                        <label>Eligible partner <select name="delivery_partner_id" required>@foreach ($eligiblePartners as $partner)<option value="{{ $partner->id }}">{{ $partner->user->name }} ({{ $partner->user->email }})</option>@endforeach</select></label>
                        <button type="submit">Assign delivery</button>
                    </form>
                    @error('delivery_partner_id')<p>{{ $message }}</p>@enderror
                @else
                    <p>No approved, active and available delivery partners are currently eligible.</p>
                @endif
            @endif
        </section>

        <section>
            <h3>Status history</h3>
            <ol>
                @forelse ($order->statusHistory->sortByDesc('created_at') as $history)
                    <li>{{ $history->from_status ?? '—' }} → {{ $history->to_status }} by {{ $history->actor?->email ?? 'system' }} at {{ $history->created_at?->toIso8601String() }}</li>
                @empty
                    <li>No status history.</li>
                @endforelse
            </ol>
        </section>

        @if ($order->invoice)
            <p>Invoice: {{ $order->invoice->invoice_number }}</p>
        @endif
    </main>
</body>
</html>
