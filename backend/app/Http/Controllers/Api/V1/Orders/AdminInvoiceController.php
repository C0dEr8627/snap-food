<?php

namespace App\Http\Controllers\Api\V1\Orders;

use App\Models\Invoice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminInvoiceController
{
    public function index(Request $request): JsonResponse
    {
        $query = Invoice::query()->with('order:id,status')
            ->when($request->filled('search'), function ($builder) use ($request): void {
                $term = trim((string) $request->query('search'));
                $builder->where(function ($where) use ($term): void {
                    $where->where('invoice_number', 'like', '%'.$term.'%')
                        ->orWhere('customer_name', 'like', '%'.$term.'%')
                        ->orWhere('customer_email', 'like', '%'.$term.'%')
                        ->orWhereHas('order', fn ($orders) => $orders->where('id', 'like', '%'.$term.'%'));
                });
            })
            ->when($request->filled('from'), fn ($builder) => $builder->whereDate('issued_at', '>=', $request->query('from')))
            ->when($request->filled('to'), fn ($builder) => $builder->whereDate('issued_at', '<=', $request->query('to')))
            ->when($request->query('status') === 'PAID', fn ($builder) => $builder->where('payment_status', 'PAID'))
            ->when($request->query('status') === 'PENDING', fn ($builder) => $builder->where('payment_status', '!=', 'PAID'))
            ->latest('issued_at');

        $summaryQuery = clone $query;
        $summary = [
            'count' => (clone $summaryQuery)->count(),
            'total' => (float) (clone $summaryQuery)->sum('total'),
            'paid_count' => (clone $summaryQuery)->where('payment_status', 'PAID')->count(),
            'paid_total' => (float) (clone $summaryQuery)->where('payment_status', 'PAID')->sum('total'),
        ];

        $invoices = $query->paginate(min(max((int) $request->integer('per_page', 10), 1), 100))
            ->withQueryString();

        return response()->json(['data' => $invoices, 'summary' => $summary]);
    }
}
