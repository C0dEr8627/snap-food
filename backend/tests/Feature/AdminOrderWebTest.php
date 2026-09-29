<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminOrderWebTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_search_filter_and_open_order_details(): void
    {
        $admin = User::factory()->admin()->create();
        $customer = User::factory()->create([
            'name' => 'Asha Customer',
            'email' => 'asha@example.test',
        ]);

        $matching = Order::factory()->create([
            'customer_id' => $customer->id,
            'status' => Order::STATUS_PREPARING,
        ]);
        OrderItem::factory()->create([
            'order_id' => $matching->id,
            'product_name' => 'Paneer Wrap',
            'quantity' => 2,
            'unit_price' => '50.00',
            'line_total' => '100.00',
        ]);

        Order::factory()->create([
            'status' => Order::STATUS_PLACED,
        ]);

        $this->actingAs($admin, 'web')
            ->get('/admin/orders?q=asha@example.test&status=PREPARING')
            ->assertOk()
            ->assertViewHas('orders', fn ($orders) => $orders->total() === 1)
            ->assertSee('#'.$matching->id)
            ->assertSee('Asha Customer');

        $this->actingAs($admin, 'web')
            ->get('/admin/orders/'.$matching->id)
            ->assertOk()
            ->assertSee('Paneer Wrap')
            ->assertSee('PREPARING')
            ->assertSee('Update status');
    }

    public function test_admin_can_update_order_status_and_history_records_actor(): void
    {
        $admin = User::factory()->admin()->create();
        $order = Order::factory()->create([
            'status' => Order::STATUS_PLACED,
        ]);

        $this->actingAs($admin, 'web')
            ->post('/admin/orders/'.$order->id.'/status', [
                'status' => Order::STATUS_ACCEPTED,
            ])
            ->assertRedirect('/admin/orders/'.$order->id)
            ->assertSessionHas('status', 'Order status updated.');

        $this->assertDatabaseHas('orders', [
            'id' => $order->id,
            'status' => Order::STATUS_ACCEPTED,
        ]);
        $this->assertDatabaseHas('order_status_histories', [
            'order_id' => $order->id,
            'from_status' => Order::STATUS_PLACED,
            'to_status' => Order::STATUS_ACCEPTED,
            'actor_id' => $admin->id,
        ]);
    }

    public function test_admin_status_action_rejects_invalid_transition(): void
    {
        $admin = User::factory()->admin()->create();
        $order = Order::factory()->create([
            'status' => Order::STATUS_DELIVERED,
        ]);

        $this->actingAs($admin, 'web')
            ->post('/admin/orders/'.$order->id.'/status', [
                'status' => Order::STATUS_ACCEPTED,
            ])
            ->assertConflict();

        $this->assertDatabaseHas('orders', [
            'id' => $order->id,
            'status' => Order::STATUS_DELIVERED,
        ]);
    }

    public function test_non_admin_cannot_access_admin_orders(): void
    {
        $customer = User::factory()->create();

        $this->actingAs($customer, 'web')
            ->get('/admin/orders')
            ->assertForbidden();
    }
}
