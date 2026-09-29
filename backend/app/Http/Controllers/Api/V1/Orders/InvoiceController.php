<?php

namespace App\Http\Controllers\Api\V1\Orders;

use App\Models\Invoice;
use App\Models\Order;
use App\Services\InvoiceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InvoiceController
{
    public function show(Request $request, Order $order, InvoiceService $invoiceService): JsonResponse
    {
        $user = $request->user();

        if ($user->role === \App\Models\User::ROLE_CUSTOMER && $order->customer_id !== $user->id) {
            abort(403);
        }

        if ($user->role !== \App\Models\User::ROLE_CUSTOMER && $user->role !== \App\Models\User::ROLE_ADMIN) {
            abort(403);
        }

        $invoice = $invoiceService->generateForDeliveredOrder($order);

        return response()->json([
            'data' => [
                'id' => $invoice->id,
                'order_id' => $invoice->order_id,
                'invoice_number' => $invoice->invoice_number,
                'customer_name' => $invoice->customer_name,
                'customer_email' => $invoice->customer_email,
                'delivery_address_snapshot' => $invoice->delivery_address_snapshot,
                'items' => $invoice->items_snapshot,
                'subtotal' => (string) $invoice->subtotal,
                'delivery_fee' => (string) $invoice->delivery_fee,
                'total' => (string) $invoice->total,
                'payment_method' => $invoice->payment_method,
                'payment_status' => $invoice->payment_status,
                'issued_at' => $invoice->issued_at?->toIso8601String(),
                'file_reference' => $invoice->file_reference,
            ],
        ]);
    }
}
