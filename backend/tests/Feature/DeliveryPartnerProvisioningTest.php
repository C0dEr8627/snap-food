<?php

namespace Tests\Feature;

use App\Models\DeliveryPartner;
use App\Models\AdminUser;
use App\Models\CustomerUser;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeliveryPartnerProvisioningTest extends TestCase
{
    use RefreshDatabase;

    private function customer(string $suffix): CustomerUser
    {
        return CustomerUser::create([
            'google_subject' => 'google-partner-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'is_active' => true,
        ]);
    }

    private function admin(string $suffix): AdminUser
    {
        return AdminUser::create([
            'google_subject' => 'google-partner-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'is_active' => true,
        ]);
    }

    public function test_admin_can_provision_and_approve_delivery_partner(): void
    {
        $admin = $this->admin('admin');
        $candidate = $this->customer('candidate');

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertCreated()
            ->assertJsonPath('data.user.role', 'DELIVERY_PARTNER')
            ->assertJsonPath('data.is_approved', false);

        $partner = DeliveryPartner::query()->firstOrFail();

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/delivery-partners/'.$partner->id.'/approval', ['approved' => true])
            ->assertOk()
            ->assertJsonPath('data.is_approved', true)
            ->assertJsonPath('data.approver.id', $admin->id);

        $this->assertDatabaseHas('delivery_partners', [
            'id' => $partner->id,
            'user_id' => $candidate->id,
            'is_approved' => true,
            'is_available' => false,
            'approved_by' => $admin->id,
        ]);
    }

    public function test_admin_can_revoke_approval_and_partner_becomes_unavailable(): void
    {
        $admin = $this->admin('revoke-admin');
        $candidate = $this->customer('revoke-candidate');

        $partner = DeliveryPartner::create([
            'user_id' => $candidate->id,
            'is_approved' => true,
            'is_active' => true,
            'is_available' => true,
            'approved_at' => now(),
            'approved_by' => $admin->id,
        ]);

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/delivery-partners/'.$partner->id.'/approval', ['approved' => false])
            ->assertOk()
            ->assertJsonPath('data.is_approved', false)
            ->assertJsonPath('data.is_available', false);
    }

    public function test_customer_cannot_provision_delivery_partner(): void
    {
        $customer = $this->customer('customer');
        $candidate = $this->customer('candidate-denied');

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertForbidden();

        $this->assertDatabaseCount('delivery_partners', 0);
        $this->assertDatabaseHas('customer_users', [
            'id' => $candidate->id,
            'role' => 'CUSTOMER',
        ]);
    }

    public function test_duplicate_provisioning_is_a_conflict(): void
    {
        $admin = $this->admin('conflict-admin');
        $candidate = $this->customer('conflict-candidate');

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertCreated();

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertStatus(409)
            ->assertJsonPath('code', 'CONFLICT');
    }
}
