<?php

namespace Tests\Feature;

use App\Models\AdminUser;
use App\Models\DeliveryPartnerUser;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeliveryPartnerProvisioningTest extends TestCase
{
    use RefreshDatabase;

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

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', [
                'name' => 'Candidate Rider',
                'email' => 'candidate@example.test',
                'phone' => '+919876543210',
                'password' => 'secret123',
                'password_confirmation' => 'secret123',
            ])
            ->assertCreated()
            ->assertJsonPath('data.name', 'Candidate Rider')
            ->assertJsonPath('data.role', 'DELIVERY_PARTNER')
            ->assertJsonPath('data.is_approved', false)
            ->assertJsonPath('data.is_available', false);

        $partner = DeliveryPartnerUser::query()->where('email', 'candidate@example.test')->firstOrFail();

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/delivery-partners/'.$partner->id.'/approval', ['approved' => true])
            ->assertOk()
            ->assertJsonPath('data.is_approved', true)
            ->assertJsonPath('data.is_available', true)
            ->assertJsonPath('data.approver.id', $admin->id);

        $this->assertDatabaseHas('delivery_partner_users', [
            'id' => $partner->id,
            'is_approved' => true,
            'is_available' => true,
            'approved_by' => $admin->id,
        ]);

        $this->assertDatabaseMissing('delivery_partners', ['user_id' => $partner->id]);
    }

    public function test_admin_can_revoke_approval_and_partner_becomes_unavailable(): void
    {
        $admin = $this->admin('revoke-admin');

        $partner = DeliveryPartnerUser::create([
            'name' => 'Approved Rider',
            'email' => 'revoke@example.test',
            'password' => 'secret123',
            'is_active' => true,
            'is_approved' => true,
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
        $this->assertDatabaseCount('delivery_partner_users', 0);
    }

    public function test_duplicate_provisioning_is_rejected_by_delivery_partner_account_uniqueness(): void
    {
        $admin = $this->admin('conflict-admin');

        $payload = [
            'name' => 'Duplicate Rider',
            'email' => 'duplicate@example.test',
            'password' => 'secret123',
            'password_confirmation' => 'secret123',
        ];

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', $payload)
            ->assertCreated();

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/delivery-partners', $payload)
            ->assertUnprocessable();
    }
}
