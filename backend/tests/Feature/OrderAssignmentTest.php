<?php

namespace Tests\Feature;

use App\Models\DeliveryPartner;
use App\Models\Order;
use App\Models\OrderAssignment;
use App\Models\OrderStatusHistory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderAssignmentTest extends TestCase
{
    use RefreshDatabase;

    private function user(string $suffix, string $role): User
    {
        return User::create([
            'google_subject' => 'google-assignment-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'role' => $role,
            'is_active' => true,
        ]);
    }

    private function partner(User $user, bool $available = true): DeliveryPartner
    {
        return DeliveryPartner::create([
            'user_id' => $user->id,
            'is_approved' => true,
            'is_active' => true,
            'is_available' => $available,
            'approved_at' => now(),
            'approved_by' => $this->admin()->id,
        ]);
    }

    private ?User $adminUser = null;

    private function admin(): User
    {
        return $this->adminUser ??= $this->user('admin', User::ROLE_ADMIN);
    }

    private function order(User $customer, string $status = Order::STATUS_READY_FOR_PICKUP): Order
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
        $customer = $this->user('customer', User::ROLE_CUSTOMER);
        $partner = $this->partner($this->user('partner', User::ROLE_DELIVERY_PARTNER));
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

    public function test_customer_cannot_assign_an_order(): void
    {
        $customer = $this->user('customer-denied', User::ROLE_CUSTOMER);
        $partner = $this->partner($this->user('partner-denied', User::ROLE_DELIVERY_PARTNER));
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
        $customer = $this->user('customer-unavailable', User::ROLE_CUSTOMER);
        $partner = $this->partner($this->user('partner-unavailable', User::ROLE_DELIVERY_PARTNER), false);
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
        $customer = $this->user('customer-conflict', User::ROLE_CUSTOMER);
        $partner = $this->partner($this->user('partner-conflict', User::ROLE_DELIVERY_PARTNER));
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
