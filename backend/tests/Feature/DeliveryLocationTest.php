<?php

namespace Tests\Feature;

use App\Models\AdminUser;
use App\Models\CustomerUser;
use App\Models\DeliveryLocation;
use App\Models\DeliveryPartner;
use App\Models\DeliveryPartnerUser;
use App\Models\Order;
use App\Models\OrderAssignment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeliveryLocationTest extends TestCase
{
    use RefreshDatabase;

    private function customer(string $suffix): CustomerUser
    {
        return CustomerUser::create([
            'google_subject' => 'delivery-location-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'is_active' => true,
        ]);
    }

    private function partnerUser(string $suffix): DeliveryPartnerUser
    {
        return DeliveryPartnerUser::create([
            'google_subject' => 'delivery-location-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'is_active' => true,
        ]);
    }

    private ?AdminUser $adminUser = null;

    private function admin(): AdminUser
    {
        return $this->adminUser ??= AdminUser::create([
            'google_subject' => 'delivery-location-admin',
            'name' => 'Admin',
            'email' => 'delivery-location-admin@example.test',
            'is_active' => true,
        ]);
    }

    private function partner(DeliveryPartnerUser $user): DeliveryPartner
    {
        return DeliveryPartner::create([
            'user_id' => $user->id,
            'is_approved' => true,
            'is_active' => true,
            'is_available' => true,
            'approved_at' => now(),
            'approved_by' => $this->admin()->id,
        ]);
    }

    private function assignment(CustomerUser $customer, DeliveryPartnerUser $partnerUser, string $status = Order::STATUS_OUT_FOR_DELIVERY): OrderAssignment
    {
        $partner = $this->partner($partnerUser);
        $order = Order::create([
            'customer_id' => $customer->id,
            'delivery_address_snapshot' => ['line1' => 'Test'],
            'subtotal' => 100,
            'delivery_fee' => 20,
            'total' => 120,
            'payment_method' => Order::PAYMENT_METHOD_COD,
            'payment_status' => Order::PAYMENT_STATUS_PENDING,
            'status' => $status,
        ]);

        return OrderAssignment::create([
            'order_id' => $order->id,
            'delivery_partner_id' => $partner->id,
            'assigned_by' => $this->admin()->id,
            'assigned_at' => now(),
        ]);
    }

    public function test_partner_can_post_valid_location_for_owned_active_trip(): void
    {
        $customer = $this->customer('customer');
        $partner = $this->partnerUser('partner');
        $assignment = $this->assignment($customer, $partner);

        $this->actingAs($partner, 'sanctum')
            ->postJson('/api/v1/delivery/assignments/'.$assignment->id.'/location', [
                'latitude' => 19.076090,
                'longitude' => 72.877426,
                'accuracy' => 12.5,
                'recorded_at' => now()->toIso8601String(),
            ])
            ->assertCreated()
            ->assertJsonPath('data.assignment_id', $assignment->id);

        $this->assertDatabaseHas('delivery_locations', [
            'assignment_id' => $assignment->id,
            'latitude' => '19.0760900',
            'longitude' => '72.8774260',
        ]);
    }

    public function test_location_payload_validates_coordinates_and_timestamp(): void
    {
        $customer = $this->customer('customer-validation');
        $partner = $this->partnerUser('partner-validation');
        $assignment = $this->assignment($customer, $partner);

        $this->actingAs($partner, 'sanctum')
            ->postJson('/api/v1/delivery/assignments/'.$assignment->id.'/location', [
                'latitude' => 91,
                'longitude' => 181,
                'accuracy' => -1,
                'recorded_at' => 'not-a-date',
            ])
            ->assertStatus(422);
    }

    public function test_partner_cannot_post_location_for_another_partner(): void
    {
        $customer = $this->customer('customer-owner');
        $owner = $this->partnerUser('partner-owner');
        $intruder = $this->partnerUser('partner-intruder');
        $assignment = $this->assignment($customer, $owner);
        $this->partner($intruder);

        $this->actingAs($intruder, 'sanctum')
            ->postJson('/api/v1/delivery/assignments/'.$assignment->id.'/location', [
                'latitude' => 19.0,
                'longitude' => 72.8,
                'recorded_at' => now()->toIso8601String(),
            ])
            ->assertForbidden();
    }

    public function test_partner_cannot_post_location_before_pickup(): void
    {
        $customer = $this->customer('customer-before-pickup');
        $partner = $this->partnerUser('partner-before-pickup');
        $assignment = $this->assignment($customer, $partner, Order::STATUS_ASSIGNED);

        $this->actingAs($partner, 'sanctum')
            ->postJson('/api/v1/delivery/assignments/'.$assignment->id.'/location', [
                'latitude' => 19.0,
                'longitude' => 72.8,
                'recorded_at' => now()->toIso8601String(),
            ])
            ->assertStatus(409);
    }

    public function test_customer_can_read_latest_location_and_stale_state(): void
    {
        $customer = $this->customer('customer-track');
        $partner = $this->partnerUser('partner-track');
        $assignment = $this->assignment($customer, $partner);
        DeliveryLocation::create([
            'assignment_id' => $assignment->id,
            'latitude' => 19.0760900,
            'longitude' => 72.8774260,
            'accuracy' => 10,
            'recorded_at' => now()->subMinutes(3),
        ]);

        $this->actingAs($customer, 'sanctum')
            ->getJson('/api/v1/consumer/orders/'.$assignment->order_id.'/tracking')
            ->assertOk()
            ->assertJsonPath('data.location.latitude', '19.0760900')
            ->assertJsonPath('data.is_stale', true);
    }

    public function test_other_customer_cannot_read_tracking(): void
    {
        $customer = $this->customer('customer-track-owner');
        $other = $this->customer('customer-track-other');
        $partner = $this->partnerUser('partner-track-owner');
        $assignment = $this->assignment($customer, $partner);

        $this->actingAs($other, 'sanctum')
            ->getJson('/api/v1/consumer/orders/'.$assignment->order_id.'/tracking')
            ->assertForbidden();
    }

    public function test_admin_can_read_tracking(): void
    {
        $customer = $this->customer('customer-track-admin');
        $partner = $this->partnerUser('partner-track-admin');
        $assignment = $this->assignment($customer, $partner);
        DeliveryLocation::create([
            'assignment_id' => $assignment->id,
            'latitude' => 19.0,
            'longitude' => 72.8,
            'recorded_at' => now(),
        ]);

        $this->actingAs($this->admin(), 'sanctum')
            ->getJson('/api/v1/admin/orders/'.$assignment->order_id.'/tracking')
            ->assertOk();
    }
}
