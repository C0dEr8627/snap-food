<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Customers · Snap Foodd Admin</title></head><body>
<header><h1><a href="{{ route('admin.dashboard') }}">Snap Foodd Admin</a></h1><nav><a href="{{ route('admin.orders.index') }}">Orders</a> <a href="{{ route('admin.customers.index') }}">Customers</a> <a href="{{ route('admin.delivery-partners.index') }}">Delivery partners</a> <a href="{{ route('admin.assignments.index') }}">Assignments</a> <a href="{{ route('admin.invoices.index') }}">Invoices</a>
<form method="POST" action="{{ route('admin.logout') }}" style="display:inline">@csrf<button type="submit">Sign out</button></form></nav></header>
<main><h2>Customers</h2><form method="GET"><label>Search name or email <input type="search" name="q" maxlength="120" value="{{ $filters['q'] ?? '' }}"></label><button type="submit">Search</button><a href="{{ route('admin.customers.index') }}">Clear</a></form>
<table><thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Account</th><th>Joined</th></tr></thead><tbody>
@forelse ($customers as $customer)<tr><td>{{ $customer->id }}</td><td>{{ $customer->name }}</td><td>{{ $customer->email }}</td><td>{{ $customer->is_active ? 'Active' : 'Inactive' }}</td><td>{{ $customer->created_at?->toIso8601String() }}</td></tr>
@empty<tr><td colspan="5">No customers found.</td></tr>@endforelse
</tbody></table>{{ $customers->links() }}</main></body></html>
