<?php

namespace Tests\Feature;

use App\Models\AdminUser;
use App\Models\CustomerUser;
use App\Models\DeliveryPartner;
use App\Models\DeliveryPartnerUser;
use App\Models\Order;
use App\Models\OrderAssignment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeliveryPartnerOrderTest extends TestCase
{
    use RefreshDatabase;

    private function customer(string $suffix): CustomerUser
    {
        return CustomerUser::create(['google_subject' => 'delivery-workflow-'.$suffix, 'name' => ucfirst($suffix), 'email' => $suffix.'@example.test', 'is_active' => true]);
    }

    private function partnerUser(string $suffix): DeliveryPartnerUser
    {
        return DeliveryPartnerUser::create(['google_subject' => 'delivery-workflow-'.$suffix, 'name' => ucfirst($suffix), 'email' => $suffix.'@example.test', 'is_active' => true]);
    }

    private function order(CustomerUser $customer, string $status): Order
    {
        return Order::create([
            'customer_id' => $customer->id,
            'delivery_address_snapshot' => ['line1' => 'Test'],
            'subtotal' => 100, 'delivery_fee' => 20, 'total' => 120,
            'payment_method' => Order::PAYMENT_METHOD_COD,
            'payment_status' => Order::PAYMENT_STATUS_PENDING,
            'status' => $status,
        ]);
    }

    private function partner(DeliveryPartnerUser $user, bool $approved = true, bool $active = true): DeliveryPartner
    {
        return DeliveryPartner::create([
            'user_id' => $user->id, 'is_approved' => $approved, 'is_active' => $active, 'is_available' => true,
            'approved_at' => $approved ? now() : null, 'approved_by' => $approved ? $this->admin()->id : null,
        ]);
    }

    private ?AdminUser $adminUser = null;

    private function admin(): AdminUser
    {
        return $this->adminUser ??= AdminUser::create([
            'google_subject' => 'delivery-workflow-admin', 'name' => 'Admin', 'email' => 'delivery-workflow-admin@example.test', 'is_active' => true,
        ]);
    }

    public function test_partner_can_list_only_its_active_assignments(): void
    {
        $customer = $this->customer('customer');
        $partnerUser = $this->partnerUser('partner');
        $otherUser = $this->partnerUser('other');
        $partner = $this->partner($partnerUser);
        $other = $this->partner($otherUser);
        $mine = $this->order($customer, Order::STATUS_ASSIGNED);
        $otherOrder = $this->order($customer, Order::STATUS_ASSIGNED);
        $mineAssignment = OrderAssignment::create(['order_id' => $mine->id, 'delivery_partner_id' => $partner->id, 'assigned_by' => $this->admin()->id, 'assigned_at' => now()]);
        OrderAssignment::create(['order_id' => $otherOrder->id, 'delivery_partner_id' => $other->id, 'assigned_by' => $this->admin()->id, 'assigned_at' => now()]);

        $this->actingAs($partnerUser, 'sanctum')->getJson('/api/v1/delivery/assignments')->assertOk()->assertJsonCount(1, 'data.data')->assertJsonPath('data.data.0.id', $mineAssignment->id);
    }

    public function test_partner_can_progress_owned_assignment_to_delivered(): void
    {
        $customer = $this->customer('customer-progress');
        $partnerUser = $this->partnerUser('partner-progress');
        $partner = $this->partner($partnerUser);
        $order = $this->order($customer, Order::STATUS_ASSIGNED);
        $assignment = OrderAssignment::create(['order_id' => $order->id, 'delivery_partner_id' => $partner->id, 'assigned_by' => $this->admin()->id, 'assigned_at' => now()]);

        foreach ([Order::STATUS_PICKED_UP, Order::STATUS_OUT_FOR_DELIVERY, Order::STATUS_DELIVERED] as $status) {
            $this->actingAs($partnerUser, 'sanctum')->patchJson('/api/v1/delivery/assignments/'.$assignment->id.'/status', ['status' => $status])->assertOk()->assertJsonPath('data.status', $status);
        }

        $this->assertDatabaseHas('order_status_histories', ['order_id' => $order->id, 'to_status' => Order::STATUS_DELIVERED, 'actor_id' => $partnerUser->id]);
    }

    public function test_partner_cannot_update_another_partners_assignment(): void
    {
        $customer = $this->customer('customer-owner');
        $owner = $this->partner($this->partnerUser('partner-owner'));
        $intruder = $this->partnerUser('partner-intruder');
        $this->partner($intruder);
        $order = $this->order($customer, Order::STATUS_ASSIGNED);
        $assignment = OrderAssignment::create(['order_id' => $order->id, 'delivery_partner_id' => $owner->id, 'assigned_by' => $this->admin()->id, 'assigned_at' => now()]);

        $this->actingAs($intruder, 'sanctum')->patchJson('/api/v1/delivery/assignments/'.$assignment->id.'/status', ['status' => Order::STATUS_PICKED_UP])->assertForbidden();
    }

    public function test_partner_cannot_skip_delivery_state(): void
    {
        $customer = $this->customer('customer-skip');
        $partnerUser = $this->partnerUser('partner-skip');
        $partner = $this->partner($partnerUser);
        $order = $this->order($customer, Order::STATUS_ASSIGNED);
        $assignment = OrderAssignment::create(['order_id' => $order->id, 'delivery_partner_id' => $partner->id, 'assigned_by' => $this->admin()->id, 'assigned_at' => now()]);

        $this->actingAs($partnerUser, 'sanctum')->patchJson('/api/v1/delivery/assignments/'.$assignment->id.'/status', ['status' => Order::STATUS_DELIVERED])->assertStatus(409);
    }

    public function test_unapproved_partner_cannot_use_delivery_workflow(): void
    {
        $customer = $this->customer('customer-unapproved');
        $partnerUser = $this->partnerUser('partner-unapproved');
        $this->partner($partnerUser, false);
        $this->actingAs($partnerUser, 'sanctum')->getJson('/api/v1/delivery/assignments')->assertForbidden();
    }
}
