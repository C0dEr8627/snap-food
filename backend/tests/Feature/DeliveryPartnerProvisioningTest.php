<?php

namespace Tests\Feature;

use App\Models\DeliveryPartner;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeliveryPartnerProvisioningTest extends TestCase
{
    use RefreshDatabase;

    private function user(string $suffix, string $role = User::ROLE_CUSTOMER): User
    {
        return User::create([
            'google_subject' => 'google-partner-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'role' => $role,
            'is_active' => true,
        ]);
    }

    public function test_admin_can_provision_and_approve_delivery_partner(): void
    {
        $admin = $this->user('admin', User::ROLE_ADMIN);
        $candidate = $this->user('candidate');

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertCreated()
            ->assertJsonPath('data.user.role', User::ROLE_DELIVERY_PARTNER)
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
        $admin = $this->user('revoke-admin', User::ROLE_ADMIN);
        $candidate = $this->user('revoke-candidate');

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
        $customer = $this->user('customer');
        $candidate = $this->user('candidate-denied');

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertForbidden();

        $this->assertDatabaseCount('delivery_partners', 0);
        $this->assertDatabaseHas('users', [
            'id' => $candidate->id,
            'role' => User::ROLE_CUSTOMER,
        ]);
    }

    public function test_duplicate_and_admin_provisioning_are_conflicts(): void
    {
        $admin = $this->user('conflict-admin', User::ROLE_ADMIN);
        $candidate = $this->user('conflict-candidate');
        $adminTarget = $this->user('already-admin', User::ROLE_ADMIN);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertCreated();

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $candidate->id])
            ->assertStatus(409);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', ['user_id' => $adminTarget->id])
            ->assertStatus(409);
    }
}
