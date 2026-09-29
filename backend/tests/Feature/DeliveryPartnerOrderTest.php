<?php

namespace Tests\Feature;

use App\Models\DeliveryPartner;
use App\Models\Order;
use App\Models\OrderAssignment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeliveryPartnerOrderTest extends TestCase
{
    use RefreshDatabase;

    private function user(string $suffix, string $role): User
    {
        return User::create([
            'google_subject' => 'delivery-workflow-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'role' => $role,
            'is_active' => true,
        ]);
    }

    private function order(User $customer, string $status): Order
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

    private function partner(User $user, bool $approved = true, bool $active = true): DeliveryPartner
    {
        return DeliveryPartner::create([
            'user_id' => $user->id,
            'is_approved' => $approved,
            'is_active' => $active,
            'is_available' => true,
            'approved_at' => $approved ? now() : null,
            'approved_by' => $approved ? $this->admin()->id : null,
        ]);
    }

    private ?User $adminUser = null;

    private function admin(): User
    {
        return $this->adminUser ??= $this->user('admin', User::ROLE_ADMIN);
    }

    public function test_partner_can_list_only_its_active_assignments(): void
    {
        $customer = $this->user('customer', User::ROLE_CUSTOMER);
        $partnerUser = $this->user('partner', User::ROLE_DELIVERY_PARTNER);
        $otherUser = $this->user('other', User::ROLE_DELIVERY_PARTNER);
        $partner = $this->partner($partnerUser);
        $other = $this->partner($otherUser);

        $mine = $this->order($customer, Order::STATUS_ASSIGNED);
        $otherOrder = $this->order($customer, Order::STATUS_ASSIGNED);
        OrderAssignment::create(['order_id' => $mine->id, 'delivery_partner_id' => $partner->id, 'assigned_by' => $this->admin()->id, 'assigned_at' => now()]);
        OrderAssignment::create(['order_id' => $otherOrder->id, 'delivery_partner_id' => $other->id, 'assigned_by' => $this->admin()->id, 'assigned_at' => now()]);

        $this->actingAs($partnerUser, 'sanctum')
            ->getJson('/api/v1/delivery/assignments')
            ->assertOk()
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.id', $mine->id);
    }

    public function test_partner_can_progress_owned_assignment_to_delivered(): void
    {
        $customer = $this->user('customer-progress', User::ROLE_CUSTOMER);
        $partnerUser = $this->user('partner-progress', User::ROLE_DELIVERY_PARTNER);
        $partner = $this->partner($partnerUser);
        $order = $this->order($customer, Order::STATUS_ASSIGNED);
        $assignment = OrderAssignment::create([
            'order_id' => $order->id,
            'delivery_partner_id' => $partner->id,
            'assigned_by' => $this->admin()->id,
            'assigned_at' => now(),
        ]);

        foreach ([Order::STATUS_PICKED_UP, Order::STATUS_OUT_FOR_DELIVERY, Order::STATUS_DELIVERED] as $status) {
            $this->actingAs($partnerUser, 'sanctum')
                ->patchJson('/api/v1/delivery/assignments/'.$assignment->id.'/status', ['status' => $status])
                ->assertOk()
                ->assertJsonPath('data.status', $status);
        }

        $this->assertDatabaseHas('order_status_histories', [
            'order_id' => $order->id,
            'to_status' => Order::STATUS_DELIVERED,
            'actor_id' => $partnerUser->id,
        ]);
    }

    public function test_partner_cannot_update_another_partners_assignment(): void
    {
        $customer = $this->user('customer-owner', User::ROLE_CUSTOMER);
        $owner = $this->partner($this->user('partner-owner', User::ROLE_DELIVERY_PARTNER));
        $intruder = $this->user('partner-intruder', User::ROLE_DELIVERY_PARTNER);
        $this->partner($intruder);
        $order = $this->order($customer, Order::STATUS_ASSIGNED);
        $assignment = OrderAssignment::create([
            'order_id' => $order->id,
            'delivery_partner_id' => $owner->id,
            'assigned_by' => $this->admin()->id,
            'assigned_at' => now(),
        ]);

        $this->actingAs($intruder, 'sanctum')
            ->patchJson('/api/v1/delivery/assignments/'.$assignment->id.'/status', ['status' => Order::STATUS_PICKED_UP])
            ->assertForbidden();
    }

    public function test_partner_cannot_skip_delivery_state(): void
    {
        $customer = $this->user('customer-skip', User::ROLE_CUSTOMER);
        $partnerUser = $this->user('partner-skip', User::ROLE_DELIVERY_PARTNER);
        $partner = $this->partner($partnerUser);
        $order = $this->order($customer, Order::STATUS_ASSIGNED);
        $assignment = OrderAssignment::create([
            'order_id' => $order->id,
            'delivery_partner_id' => $partner->id,
            'assigned_by' => $this->admin()->id,
            'assigned_at' => now(),
        ]);

        $this->actingAs($partnerUser, 'sanctum')
            ->patchJson('/api/v1/delivery/assignments/'.$assignment->id.'/status', ['status' => Order::STATUS_DELIVERED])
            ->assertStatus(409);
    }

    public function test_unapproved_partner_cannot_use_delivery_workflow(): void
    {
        $customer = $this->user('customer-unapproved', User::ROLE_CUSTOMER);
        $partnerUser = $this->user('partner-unapproved', User::ROLE_DELIVERY_PARTNER);
        $this->partner($partnerUser, false);
        $this->actingAs($partnerUser, 'sanctum')
            ->getJson('/api/v1/delivery/assignments')
            ->assertForbidden();
    }
}
