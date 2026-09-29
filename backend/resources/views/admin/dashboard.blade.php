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
        <ul>
            <li>Catalogue</li>
            <li>Orders</li>
            <li>Customers</li>
            <li>Delivery partners</li>
            <li>Assignments</li>
            <li>Invoices</li>
        </ul>
    </main>
</body>
</html>
