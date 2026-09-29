<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Orders · Snap Foodd Admin</title>
</head>
<body>
    <header>
        <h1><a href="{{ route('admin.dashboard') }}">Snap Foodd Admin</a></h1>
        <nav>
            <a href="{{ route('admin.orders.index') }}">Orders</a>
            <form method="POST" action="{{ route('admin.logout') }}" style="display:inline">
                @csrf
                <button type="submit">Sign out</button>
            </form>
        </nav>
    </header>

    <main>
        <h2>Orders</h2>

        <form method="GET" action="{{ route('admin.orders.index') }}">
            <label>
                Search
                <input type="search" name="q" value="{{ $filters['q'] ?? '' }}" maxlength="120">
            </label>
            <label>
                Status
                <select name="status">
                    <option value="">All statuses</option>
                    @foreach ($statuses as $status)
                        <option value="{{ $status }}" @selected(($filters['status'] ?? '') === $status)>{{ $status }}</option>
                    @endforeach
                </select>
            </label>
            <button type="submit">Filter</button>
            <a href="{{ route('admin.orders.index') }}">Clear</a>
        </form>

        <table>
            <thead>
                <tr>
                    <th>Order</th>
                    <th>Customer</th>
                    <th>Status</th>
                    <th>Total</th>
                    <th>Delivery partner</th>
                    <th>Created</th>
                </tr>
            </thead>
            <tbody>
            @forelse ($orders as $order)
                <tr>
                    <td><a href="{{ route('admin.orders.show', $order) }}">#{{ $order->id }}</a></td>
                    <td>{{ $order->customer->name }} ({{ $order->customer->email }})</td>
                    <td>{{ $order->status }}</td>
                    <td>{{ $order->total }}</td>
                    <td>{{ $order->assignment?->deliveryPartner?->user?->name ?? 'Unassigned' }}</td>
                    <td>{{ $order->created_at?->toIso8601String() }}</td>
                </tr>
            @empty
                <tr><td colspan="6">No orders found.</td></tr>
            @endforelse
            </tbody>
        </table>

        {{ $orders->links() }}
    </main>
</body>
</html>
