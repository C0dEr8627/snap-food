<?php

namespace App\Http\Controllers\Api\V1\Orders;

use App\Models\Order;
use App\Services\InvoiceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;

class InvoiceController
{
    public function show(Request $request, Order $order, InvoiceService $invoiceService): JsonResponse
    {
        $user = $request->user();

        if (
            ($user->hasRole('CUSTOMER') && (int) $order->customer_id !== (int) $user->id)
            || (! $user->hasRole('CUSTOMER') && ! $user->hasRole('ADMIN'))
        ) {
            throw new AccessDeniedHttpException('You are not authorized to perform this action.');
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
