<?php

namespace Tests\\Feature;

use App\\Models\\AdminUser;
use App\\Models\\CustomerUser;
use App\\Models\\DeliveryPartnerUser;
use Illuminate\\Foundation\\Testing\\RefreshDatabase;
use Tests\\TestCase;

class AdminUsersApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_users_endpoint_filters_by_dedicated_account_table(): void
    {
        $admin = AdminUser::create([
            'name' => 'Platform Admin',
            'email' => 'platform-admin@example.test',
            'is_active' => true,
        ]);
        CustomerUser::create([
            'name' => 'Customer Account',
            'email' => 'customer@example.test',
            'is_active' => true,
        ]);
        DeliveryPartnerUser::create([
            'name' => 'Delivery Account',
            'email' => 'delivery@example.test',
            'is_active' => true,
        ]);

        $this->actingAs($admin, 'sanctum');

        $this->getJson('/api/v1/admin/users?role=ADMIN')
            ->assertOk()
            ->assertJsonPath('data.total', 1)
            ->assertJsonPath('data.data.0.role', 'ADMIN')
            ->assertJsonPath('data.data.0.email', 'platform-admin@example.test');

        $this->getJson('/api/v1/admin/users?role=CUSTOMER')
            ->assertOk()
            ->assertJsonPath('data.total', 1)
            ->assertJsonPath('data.data.0.role', 'CUSTOMER')
            ->assertJsonPath('data.data.0.email', 'customer@example.test');

        $this->getJson('/api/v1/admin/users?role=DELIVERY_PARTNER')
            ->assertOk()
            ->assertJsonPath('data.total', 1)
            ->assertJsonPath('data.data.0.role', 'DELIVERY_PARTNER')
            ->assertJsonPath('data.data.0.email', 'delivery@example.test');

        $this->getJson('/api/v1/admin/users?role=ALL')
            ->assertOk()
            ->assertJsonPath('data.total', 3);
    }

    public function test_admin_users_endpoint_rejects_unknown_role_filter(): void
    {
        $admin = AdminUser::create([
            'name' => 'Platform Admin',
            'email' => 'platform-admin-filter@example.test',
            'is_active' => true,
        ]);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/v1/admin/users?role=RIDER')
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Unsupported user role filter.');
    }
}
