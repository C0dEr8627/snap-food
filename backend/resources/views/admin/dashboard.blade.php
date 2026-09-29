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
        <nav><a href="{{ route('admin.catalogue.index') }}">Catalogue</a> · <a href="{{ route('admin.orders.index') }}">Orders</a> · <a href="{{ route('admin.customers.index') }}">Customers</a> · <a href="{{ route('admin.delivery-partners.index') }}">Delivery partners</a> · <a href="{{ route('admin.assignments.index') }}">Assignments</a> · <a href="{{ route('admin.invoices.index') }}">Invoices</a></nav>
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

        <section aria-labelledby="directory-summary">
            <h3 id="directory-summary">Operations directory</h3>
            <dl>
                <div><dt>Categories</dt><dd>{{ $directoryCounts['categories'] }}</dd></div>
                <div><dt>Products</dt><dd>{{ $directoryCounts['products'] }}</dd></div>
                <div><dt>Customers</dt><dd>{{ $directoryCounts['customers'] }}</dd></div>
                <div><dt>Delivery partners</dt><dd>{{ $directoryCounts['delivery_partners'] }}</dd></div>
                <div><dt>Assignments</dt><dd>{{ $directoryCounts['assignments'] }}</dd></div>
                <div><dt>Invoices issued</dt><dd>{{ $directoryCounts['invoices'] }}</dd></div>
            </dl>
        </section>

        <section aria-labelledby="operations">
            <h3 id="operations">Operations</h3>
            <ul>
                <li><a href="{{ route('admin.catalogue.index') }}">Catalogue management</a></li>
                <li><a href="{{ route('admin.orders.index') }}">Orders</a></li>
                <li><a href="{{ route('admin.customers.index') }}">Customers</a></li>
                <li><a href="{{ route('admin.delivery-partners.index') }}">Delivery partners</a></li>
                <li><a href="{{ route('admin.assignments.index') }}">Assignments</a></li>
                <li><a href="{{ route('admin.invoices.index') }}">Invoices</a></li>
            </ul>
        </section>
    </main>
</body>
</html>
