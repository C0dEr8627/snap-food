<?php

namespace App\Services;

use App\Models\Invoice;
use App\Models\Order;
use Illuminate\Support\Facades\DB;

class InvoiceService
{
    public function generateForDeliveredOrder(Order $order): Invoice
    {
        return DB::transaction(function () use ($order): Invoice {
            $order = Order::query()
                ->with(['customer', 'items'])
                ->lockForUpdate()
                ->findOrFail($order->id);

            $invoice = Invoice::query()->where('order_id', $order->id)->first();

            if ($invoice) {
                return $invoice;
            }

            $invoice = Invoice::query()->create([
                'order_id' => $order->id,
                'invoice_number' => sprintf('INV-%s-%08d', now()->format('Y'), $order->id),
                'customer_name' => $order->customer?->name ?? 'Customer',
                'customer_email' => $order->customer?->email,
                'delivery_address_snapshot' => $order->delivery_address_snapshot,
                'items_snapshot' => $order->items->map(fn ($item): array => [
                    'product_id' => $item->product_id,
                    'product_name' => $item->product_name,
                    'unit_price' => (string) $item->unit_price,
                    'quantity' => $item->quantity,
                    'line_total' => (string) $item->line_total,
                ])->values()->all(),
                'subtotal' => $order->subtotal,
                'delivery_fee' => $order->delivery_fee,
                'total' => $order->total,
                'payment_method' => $order->payment_method,
                'payment_status' => $order->payment_status,
                'issued_at' => now(),
            ]);

            return $invoice;
        });
    }
}
