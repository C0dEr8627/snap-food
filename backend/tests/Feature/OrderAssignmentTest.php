<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\AdminUser;
use App\Models\CustomerUser;
use App\Models\DeliveryPartnerUser;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderAssignmentTest extends TestCase
{
    use RefreshDatabase;

    private function customer(string $suffix): CustomerUser
    {
        return CustomerUser::create(['google_subject' => 'google-assignment-'.$suffix, 'name' => ucfirst($suffix), 'email' => $suffix.'@example.test', 'is_active' => true]);
    }

    private function partner(string $suffix, bool $available = true): DeliveryPartnerUser
    {
        return DeliveryPartnerUser::create([
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'is_active' => true,
            'is_approved' => true,
            'is_available' => $available,
            'approved_at' => now(),
            'approved_by' => $this->admin()->id,
        ]);
    }

    private ?AdminUser $adminUser = null;

    private function admin(): AdminUser
    {
        return $this->adminUser ??= AdminUser::create(['google_subject' => 'google-assignment-admin', 'name' => 'Admin', 'email' => 'google-assignment-admin@example.test', 'is_active' => true]);
    }

    private function order(CustomerUser $customer, string $status = Order::STATUS_READY_FOR_PICKUP): Order
    {
        return Order::create([
            'customer_id' => $customer->id,
            'delivery_address_snapshot' => ['line1' => 'Test'],
            'subtotal' => 100,
            'delivery_fee' => 20,
            'total' => 120,
            'payment_method' => Order::PAYMENT_METHOD_COD,
            'payment_status' => Order::PAYMENT_STATUS_PENDING,
            'status' => $status,
        ]);
    }

    public function test_admin_can_assign_eligible_partner_and_records_actor_history(): void
    {
        $admin = $this->admin();
        $customer = $this->customer('customer');
        $partner = $this->partner('partner');
        $order = $this->order($customer);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/orders/'.$order->id.'/assignment', [
                'delivery_partner_id' => $partner->id,
            ])
            ->assertCreated()
            ->assertJsonPath('data.delivery_partner.id', $partner->id)
            ->assertJsonPath('data.assigner.id', $admin->id)
            ->assertJsonPath('data.order.status', Order::STATUS_ASSIGNED);

        $this->assertDatabaseHas('order_assignments', [
            'order_id' => $order->id,
            'delivery_partner_id' => $partner->id,
            'assigned_by' => $admin->id,
        ]);
        $this->assertDatabaseHas('order_status_histories', [
            'order_id' => $order->id,
            'from_status' => Order::STATUS_READY_FOR_PICKUP,
            'to_status' => Order::STATUS_ASSIGNED,
            'actor_id' => $admin->id,
        ]);
    }

    public function test_admin_orders_list_remains_loadable_after_assignment(): void
    {
        $admin = $this->admin();
        $customer = $this->customer('customer-list');
        $partner = $this->partner('partner-list');
        $order = $this->order($customer);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/orders/'.$order->id.'/assignment', [
                'delivery_partner_id' => $partner->id,
            ])
            ->assertCreated();

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/admin/orders?per_page=100')
            ->assertOk()
            ->assertJsonPath('data.data.0.assignment.delivery_partner.id', $partner->id)
            ->assertJsonPath('data.data.0.assignment.delivery_partner.name', $partner->name);
    }

    public function test_customer_cannot_assign_an_order(): void
    {
        $customer = $this->customer('customer-denied');
        $partner = $this->partner('partner-denied');
        $order = $this->order($customer);

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/admin/orders/'.$order->id.'/assignment', [
                'delivery_partner_id' => $partner->id,
            ])
            ->assertForbidden();

        $this->assertDatabaseCount('order_assignments', 0);
    }

    public function test_unavailable_partner_is_rejected(): void
    {
        $admin = $this->admin();
        $customer = $this->customer('customer-unavailable');
        $partner = $this->partner('partner-unavailable', false);
        $order = $this->order($customer);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/orders/'.$order->id.'/assignment', [
                'delivery_partner_id' => $partner->id,
            ])
            ->assertStatus(409)
            ->assertJsonPath('code', 'CONFLICT');
    }

    public function test_assignment_is_conflict_for_non_ready_or_already_assigned_order(): void
    {
        $admin = $this->admin();
        $customer = $this->customer('customer-conflict');
        $partner = $this->partner('partner-conflict');
        $order = $this->order($customer, Order::STATUS_PREPARING);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/orders/'.$order->id.'/assignment', [
                'delivery_partner_id' => $partner->id,
            ])
            ->assertStatus(409);

        $order->update(['status' => Order::STATUS_READY_FOR_PICKUP]);
        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/orders/'.$order->id.'/assignment', [
                'delivery_partner_id' => $partner->id,
            ])
            ->assertCreated();

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/orders/'.$order->id.'/assignment', [
                'delivery_partner_id' => $partner->id,
            ])
            ->assertStatus(409);

        $this->assertDatabaseCount('order_assignments', 1);
    }
}
