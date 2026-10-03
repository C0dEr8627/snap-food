<?php

namespace App\Services\Orders;

use App\Http\Requests\StoreOrderRequest;
use App\Models\Cart;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderCheckoutService
{
    public function create(StoreOrderRequest $request): Order
    {
        return DB::transaction(function () use ($request): Order {
            $requestedItems = collect($request->validated('items'))->keyBy('product_id');

            $products = Product::query()
                ->with('category')
                ->whereIn('id', $requestedItems->keys())
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            if ($products->count() !== $requestedItems->count()) {
                throw ValidationException::withMessages([
                    'items' => ['One or more products are no longer available.'],
                ]);
            }

            $minorSubtotal = 0;
            $snapshots = [];

            foreach ($requestedItems as $productId => $item) {
                $product = $products->get($productId);

                if (! $product->is_active || ! $product->is_available || ! $product->category?->is_active || $product->stock_quantity < $item['quantity']) {
                    throw ValidationException::withMessages([
                        'items' => ["Product {$productId} is unavailable for checkout."],
                    ]);
                }

                $unitPriceMinor = $this->toMinorUnits((string) $product->price);
                $lineTotalMinor = $unitPriceMinor * $item['quantity'];
                $minorSubtotal += $lineTotalMinor;

                $snapshots[] = [
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'unit_price' => $this->fromMinorUnits($unitPriceMinor),
                    'quantity' => $item['quantity'],
                    'line_total' => $this->fromMinorUnits($lineTotalMinor),
                ];
            }

            $deliveryFeeMinor = $this->toMinorUnits((string) config('orders.delivery_fee', '40.00'));
            $totalMinor = $minorSubtotal + $deliveryFeeMinor;
            $actor = $request->user();

            $order = Order::create([
                'customer_id' => $actor->id,
                'delivery_address_snapshot' => $request->validated('delivery_address'),
                'subtotal' => $this->fromMinorUnits($minorSubtotal),
                'delivery_fee' => $this->fromMinorUnits($deliveryFeeMinor),
                'total' => $this->fromMinorUnits($totalMinor),
                'payment_method' => Order::PAYMENT_METHOD_COD,
                'payment_status' => Order::PAYMENT_STATUS_PENDING,
                'status' => Order::STATUS_PLACED,
            ]);

            $order->items()->createMany($snapshots);
            $order->statusHistory()->create([
                'from_status' => null,
                'to_status' => Order::STATUS_PLACED,
                'actor_id' => $actor->id,
                'actor_type' => $actor::class,
            ]);

            Cart::query()->where('user_id', $actor->id)->delete();

            return $order->load('items', 'statusHistory');
        });
    }

    private function toMinorUnits(string $amount): int
    {
        $normalized = trim($amount);

        if (! preg_match('/^\d+(?:\.\d{1,2})?$/', $normalized)) {
            throw new \InvalidArgumentException('Invalid monetary amount.');
        }

        [$whole, $fraction] = array_pad(explode('.', $normalized, 2), 2, '0');

        return ((int) $whole * 100) + (int) str_pad($fraction, 2, '0');
    }

    private function fromMinorUnits(int $minorUnits): string
    {
        return number_format($minorUnits / 100, 2, '.', '');
    }
}
