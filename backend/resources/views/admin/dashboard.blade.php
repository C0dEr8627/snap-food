<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Snap Foodd Admin</title>
</head>
<body>
    <header>
        <h1>Snap Foodd Admin</h1>
        <p>Signed in as {{ auth('web')->user()->email ?? auth('web')->user()->name }}</p>
        <form method="POST" action="{{ route('admin.logout') }}">
            @csrf
            <button type="submit">Sign out</button>
        </form>
    </header>

    <main>
        <h2>Operations dashboard</h2>

        <section aria-labelledby="order-summary">
            <h3 id="order-summary">Order summary</h3>
            <dl>
                <div>
                    <dt>New orders</dt>
                    <dd>{{ $counts['new'] }}</dd>
                </div>
                <div>
                    <dt>Active orders</dt>
                    <dd>{{ $counts['active'] }}</dd>
                </div>
                <div>
                    <dt>Preparing</dt>
                    <dd>{{ $counts['preparing'] }}</dd>
                </div>
                <div>
                    <dt>Awaiting delivery</dt>
                    <dd>{{ $counts['awaiting_delivery'] }}</dd>
                </div>
                <div>
                    <dt>Active delivery</dt>
                    <dd>{{ $counts['active_delivery'] }}</dd>
                </div>
            </dl>
        </section>

        <section aria-labelledby="operations">
            <h3 id="operations">Operations</h3>
            <ul>
                <li>Catalogue</li>
                <li>Orders</li>
                <li>Customers</li>
                <li>Delivery partners</li>
                <li>Assignments</li>
                <li>Invoices</li>
            </ul>
        </section>
    </main>
</body>
</html>
