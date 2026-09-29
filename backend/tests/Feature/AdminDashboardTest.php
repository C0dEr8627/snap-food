<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_dashboard_shows_current_order_counts(): void
    {
        $admin = User::factory()->admin()->create();

        Order::factory()->create(['status' => Order::STATUS_PLACED]);
        Order::factory()->create(['status' => Order::STATUS_ACCEPTED]);
        Order::factory()->create(['status' => Order::STATUS_PREPARING]);
        Order::factory()->create(['status' => Order::STATUS_READY_FOR_PICKUP]);
        Order::factory()->create(['status' => Order::STATUS_ASSIGNED]);
        Order::factory()->create(['status' => Order::STATUS_PICKED_UP]);
        Order::factory()->create(['status' => Order::STATUS_OUT_FOR_DELIVERY]);
        Order::factory()->create(['status' => Order::STATUS_DELIVERED]);
        Order::factory()->create(['status' => Order::STATUS_CANCELLED]);

        $this->actingAs($admin, 'web')
            ->get('/admin')
            ->assertOk()
            ->assertViewHas('counts', [
                'new' => 1,
                'active' => 1,
                'preparing' => 1,
                'awaiting_delivery' => 2,
                'active_delivery' => 2,
            ])
            ->assertSee('New orders')
            ->assertSee('Active orders')
            ->assertSee('Preparing')
            ->assertSee('Awaiting delivery')
            ->assertSee('Active delivery')
            ->assertSee('Operations directory')
            ->assertSee('Customers')
            ->assertSee('Delivery partners')
            ->assertSee('Assignments')
            ->assertSee('Invoices issued')
            ->assertViewHas('directoryCounts', [
                'categories' => 0,
                'products' => 0,
                'customers' => 0,
                'delivery_partners' => 0,
                'assignments' => 0,
                'invoices' => 0,
            ]);
    }

    public function test_customer_cannot_access_dashboard_counts(): void
    {
        $customer = User::factory()->create();

        $this->actingAs($customer, 'web')
            ->get('/admin')
            ->assertForbidden();
    }
}
