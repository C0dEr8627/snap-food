<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Order;
use App\Models\Product;
use App\Models\AdminUser;
use App\Models\CustomerUser;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderApiTest extends TestCase
{
    use RefreshDatabase;

    private function customer(string $suffix): CustomerUser
    {
        return CustomerUser::create(['google_subject' => 'google-order-'.$suffix, 'name' => ucfirst($suffix), 'email' => $suffix.'@example.test', 'is_active' => true]);
    }

    private function admin(string $suffix): AdminUser
    {
        return AdminUser::create(['google_subject' => 'google-order-'.$suffix, 'name' => ucfirst($suffix), 'email' => $suffix.'@example.test', 'is_active' => true]);
    }

    private function product(): Product
    {
        $category = Category::create([
            'name' => 'Pizza',
            'slug' => 'pizza',
            'is_active' => true,
        ]);

        return Product::create([
            'category_id' => $category->id,
            'name' => 'Margherita',
            'slug' => 'margherita',
            'price' => '299.00',
            'stock_quantity' => 10,
            'is_available' => true,
            'is_active' => true,
        ]);
    }

    private function checkoutPayload(Product $product, int $quantity = 2): array
    {
        return [
            'items' => [
                ['product_id' => $product->id, 'quantity' => $quantity],
            ],
            'delivery_address' => [
                'label' => 'Home',
                'recipient_name' => 'Test Customer',
                'address_line1' => '1 Test Street',
                'address_line2' => null,
                'city' => 'Mumbai',
                'state' => 'Maharashtra',
                'postal_code' => '400001',
                'country' => 'India',
                'latitude' => 19.0760,
                'longitude' => 72.8777,
            ],
            'payment_method' => 'COD',
        ];
    }

    public function test_customer_can_create_cod_order_with_server_calculated_totals_and_snapshots(): void
    {
        $customer = $this->customer('customer');
        $product = $this->product();

        $response = $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product));

        $response->assertCreated()
            ->assertJsonPath('data.status', Order::STATUS_PLACED)
            ->assertJsonPath('data.payment_method', Order::PAYMENT_METHOD_COD)
            ->assertJsonPath('data.payment_status', Order::PAYMENT_STATUS_PENDING)
            ->assertJsonPath('data.subtotal', '598.00')
            ->assertJsonPath('data.delivery_fee', '40.00')
            ->assertJsonPath('data.total', '638.00')
            ->assertJsonPath('data.items.0.product_name', 'Margherita')
            ->assertJsonPath('data.items.0.unit_price', '299.00')
            ->assertJsonPath('data.items.0.line_total', '598.00');

        $order = Order::query()->firstOrFail();
        $this->assertSame('Test Customer', $order->delivery_address_snapshot['recipient_name']);

        $product->update(['price' => '399.00', 'name' => 'Renamed Pizza']);

        $this->assertDatabaseHas('order_items', [
            'order_id' => $order->id,
            'product_name' => 'Margherita',
            'unit_price' => '299.00',
            'line_total' => '598.00',
        ]);
        $this->assertDatabaseHas('order_status_histories', [
            'order_id' => $order->id,
            'from_status' => null,
            'to_status' => Order::STATUS_PLACED,
            'actor_id' => $customer->id,
        ]);
    }

    public function test_checkout_ignores_client_price_and_rejects_unavailable_products(): void
    {
        $customer = $this->customer('customer-price');
        $product = $this->product();

        $payload = $this->checkoutPayload($product, 1);
        $payload['items'][0]['price'] = '1.00';

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $payload)
            ->assertCreated()
            ->assertJsonPath('data.subtotal', '299.00')
            ->assertJsonPath('data.items.0.unit_price', '299.00');

        $product->update(['is_available' => false]);

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product))
            ->assertUnprocessable()
            ->assertJsonPath('code', 'VALIDATION_FAILED');
    }

    public function test_customer_can_only_list_and_view_own_orders(): void
    {
        $customer = $this->customer('owner');
        $otherCustomer = $this->customer('other');
        $product = $this->product();

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product, 1))
            ->assertCreated();

        $order = Order::firstOrFail();

        $this->actingAs($customer, 'sanctum')
            ->getJson('/api/v1/consumer/orders')
            ->assertOk()
            ->assertJsonPath('data.total', 1);

        $this->actingAs($otherCustomer, 'sanctum')
            ->getJson('/api/v1/consumer/orders/'.$order->id)
            ->assertForbidden();
    }

    public function test_admin_cannot_use_customer_order_endpoints(): void
    {
        $admin = $this->admin('admin');
        $product = $this->product();

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/consumer/orders')
            ->assertForbidden();

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product))
            ->assertForbidden();
    }

    public function test_admin_can_transition_order_and_history_records_actor(): void
    {
        $customer = $this->customer('transition-customer');
        $admin = $this->admin('transition-admin');
        $product = $this->product();

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product, 1))
            ->assertCreated();

        $order = Order::firstOrFail();

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/orders/'.$order->id.'/status', ['status' => Order::STATUS_ACCEPTED])
            ->assertOk()
            ->assertJsonPath('data.status', Order::STATUS_ACCEPTED);

        $this->assertDatabaseHas('order_status_histories', [
            'order_id' => $order->id,
            'from_status' => Order::STATUS_PLACED,
            'to_status' => Order::STATUS_ACCEPTED,
            'actor_id' => $admin->id,
        ]);
    }

    public function test_invalid_order_transition_returns_order_state_conflict(): void
    {
        $customer = $this->customer('conflict-customer');
        $admin = $this->admin('conflict-admin');
        $product = $this->product();

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product, 1))
            ->assertCreated();

        $order = Order::firstOrFail();

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/orders/'.$order->id.'/status', ['status' => Order::STATUS_DELIVERED])
            ->assertStatus(409)
            ->assertJsonPath('code', 'ORDER_STATE_CONFLICT');

        $this->assertDatabaseHas('orders', [
            'id' => $order->id,
            'status' => Order::STATUS_PLACED,
        ]);
    }

    public function test_customer_cannot_transition_order(): void
    {
        $customer = $this->customer('customer-transition-denied');
        $product = $this->product();

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product, 1))
            ->assertCreated();

        $order = Order::firstOrFail();

        $this->actingAs($customer, 'sanctum')
            ->patchJson('/api/v1/admin/orders/'.$order->id.'/status', ['status' => Order::STATUS_ACCEPTED])
            ->assertForbidden()
            ->assertJsonPath('code', 'FORBIDDEN');
    }

    public function test_repeated_transition_is_a_state_conflict(): void
    {
        $customer = $this->customer('repeat-customer');
        $admin = $this->admin('repeat-admin');
        $product = $this->product();

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/consumer/orders', $this->checkoutPayload($product, 1))
            ->assertCreated();

        $order = Order::firstOrFail();

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/orders/'.$order->id.'/status', ['status' => Order::STATUS_ACCEPTED])
            ->assertOk();

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/orders/'.$order->id.'/status', ['status' => Order::STATUS_ACCEPTED])
            ->assertStatus(409)
            ->assertJsonPath('code', 'ORDER_STATE_CONFLICT');
    }

    public function test_order_transition_rules_reject_invalid_jumps(): void
    {
        $order = new Order(['status' => Order::STATUS_PLACED]);

        $this->assertTrue($order->canTransitionTo(Order::STATUS_ACCEPTED));
        $this->assertTrue($order->canTransitionTo(Order::STATUS_CANCELLED));
        $this->assertFalse($order->canTransitionTo(Order::STATUS_DELIVERED));

        $order->status = Order::STATUS_DELIVERED;

        $this->assertFalse($order->canTransitionTo(Order::STATUS_CANCELLED));
        $this->assertFalse($order->canTransitionTo(Order::STATUS_OUT_FOR_DELIVERY));
    }
}
