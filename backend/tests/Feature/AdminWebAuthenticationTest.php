<?php

namespace Tests\Feature;

use App\Models\AdminUser;
use App\Models\CustomerUser;
use App\Services\Auth\GoogleCredentialVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use RuntimeException;
use Tests\TestCase;

class AdminWebAuthenticationTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_login_page_is_public(): void
    {
        $this->get('/admin/login')
            ->assertOk()
            ->assertSee('Snap Foodd Admin');
    }

    public function test_admin_can_sign_in_with_a_valid_google_identity_and_get_a_web_session(): void
    {
        $admin = AdminUser::create([
            'google_subject' => 'google-admin',
            'name' => 'Admin User',
            'email' => 'admin@example.test',
                        'is_active' => true,
        ]);

        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')->once()->andReturn([
                'sub' => 'google-admin',
                'name' => 'Admin User',
                'email' => 'admin@example.test',
            ]);
        });

        $response = $this->post('/admin/login', [
            'credential' => 'valid-google-token',
        ]);

        $response->assertRedirect('/admin');
        $this->assertAuthenticatedAs($admin, 'web');
    }

    public function test_customer_cannot_create_an_admin_web_session(): void
    {
        CustomerUser::create([
            'google_subject' => 'google-customer',
            'name' => 'Customer User',
            'email' => 'customer@example.test',
                        'is_active' => true,
        ]);

        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')->once()->andReturn([
                'sub' => 'google-customer',
                'name' => 'Customer User',
                'email' => 'customer@example.test',
            ]);
        });

        $this->post('/admin/login', [
            'credential' => 'valid-google-token',
        ])->assertSessionHasErrors('credential');

        $this->assertGuest('web');
    }

    public function test_inactive_admin_cannot_create_an_admin_web_session(): void
    {
        AdminUser::create([
            'google_subject' => 'google-inactive-admin',
            'name' => 'Inactive Admin',
            'email' => 'inactive-admin@example.test',
            'role' => 'ADMIN',
            'is_active' => false,
        ]);

        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')->once()->andReturn([
                'sub' => 'google-inactive-admin',
                'name' => 'Inactive Admin',
                'email' => 'inactive-admin@example.test',
            ]);
        });

        $this->post('/admin/login', [
            'credential' => 'valid-google-token',
        ])->assertSessionHasErrors('credential');

        $this->assertGuest('web');
    }

    public function test_authenticated_non_admin_is_denied_from_dashboard(): void
    {
        $customer = CustomerUser::create([
            'google_subject' => 'google-customer',
            'name' => 'Customer User',
            'email' => 'customer@example.test',
            'role' => 'CUSTOMER',
            'is_active' => true,
        ]);

        $this->actingAs($customer, 'web')
            ->get('/admin')
            ->assertForbidden();
    }

    public function test_admin_can_access_dashboard_and_logout_invalidates_session(): void
    {
        $admin = AdminUser::create([
            'google_subject' => 'google-admin',
            'name' => 'Admin User',
            'email' => 'admin@example.test',
            'role' => 'ADMIN',
            'is_active' => true,
        ]);

        $this->actingAs($admin, 'web')
            ->get('/admin')
            ->assertOk()
            ->assertSee('Operations dashboard');

        $this->actingAs($admin, 'web')
            ->post('/admin/logout')
            ->assertRedirect('/admin/login');

        Auth::guard('web')->logout();

        $this->get('/admin')
            ->assertRedirect('/admin/login');
    }

    public function test_invalid_google_credential_is_rejected_without_creating_a_session(): void
    {
        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')->once()->andThrow(new RuntimeException('invalid'));
        });

        $this->post('/admin/login', [
            'credential' => 'invalid-google-token',
        ])->assertSessionHasErrors('credential');

        $this->assertGuest('web');
    }
}
