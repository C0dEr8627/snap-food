<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Order>
 */
class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        return [
            'customer_id' => User::factory(),
            'delivery_address_snapshot' => [
                'line1' => '10 Test Street',
                'city' => 'Mumbai',
                'postal_code' => '400001',
            ],
            'subtotal' => '100.00',
            'delivery_fee' => '20.00',
            'total' => '120.00',
            'payment_method' => Order::PAYMENT_METHOD_COD,
            'payment_status' => Order::PAYMENT_STATUS_PENDING,
            'status' => Order::STATUS_PLACED,
        ];
    }
}
