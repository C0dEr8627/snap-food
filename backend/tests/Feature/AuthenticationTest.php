<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Auth\GoogleCredentialVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    public function test_google_login_creates_a_customer_and_returns_a_sanctum_token(): void
    {
        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->with('valid-google-token')
                ->andReturn([
                    'sub' => 'google-sub-123',
                    'name' => 'Google User',
                    'email' => 'google@example.test',
                ]);
        });

        $response = $this->postJson('/api/v1/auth/google', [
            'credential' => 'valid-google-token',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.user.google_subject', 'google-sub-123')
            ->assertJsonPath('data.user.role', 'CUSTOMER')
            ->assertJsonStructure([
                'data' => [
                    'token',
                    'user' => ['id', 'name', 'email', 'role'],
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'google_subject' => 'google-sub-123',
            'role' => 'CUSTOMER',
            'is_active' => 1,
        ]);
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_google_login_updates_identity_fields_but_does_not_escalate_existing_role(): void
    {
        $user = User::create([
            'google_subject' => 'google-sub-456',
            'name' => 'Old Name',
            'email' => 'old@example.test',
            'role' => 'ADMIN',
            'is_active' => true,
        ]);

        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->andReturn([
                    'sub' => 'google-sub-456',
                    'name' => 'Updated Name',
                    'email' => 'new@example.test',
                ]);
        });

        $this->postJson('/api/v1/auth/google', [
            'credential' => 'valid-google-token',
        ])->assertOk();

        $user->refresh();

        $this->assertSame('Updated Name', $user->name);
        $this->assertSame('new@example.test', $user->email);
        $this->assertSame('ADMIN', $user->role);
    }

    public function test_invalid_google_credential_is_rejected_without_creating_a_user(): void
    {
        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->andThrow(new RuntimeException('invalid'));
        });

        $this->postJson('/api/v1/auth/google', [
            'credential' => 'invalid-google-token',
        ])->assertUnauthorized()
            ->assertJsonPath('code', 'INVALID_GOOGLE_CREDENTIAL');

        $this->assertDatabaseCount('users', 0);
    }

    public function test_inactive_account_cannot_login(): void
    {
        User::create([
            'google_subject' => 'google-sub-inactive',
            'name' => 'Inactive User',
            'email' => 'inactive@example.test',
            'role' => 'CUSTOMER',
            'is_active' => false,
        ]);

        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->andReturn([
                    'sub' => 'google-sub-inactive',
                    'name' => 'Inactive User',
                    'email' => 'inactive@example.test',
                ]);
        });

        $this->postJson('/api/v1/auth/google', [
            'credential' => 'valid-google-token',
        ])->assertForbidden()
            ->assertJsonPath('code', 'ACCOUNT_INACTIVE');

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_authenticated_user_can_read_me_and_logout_revokes_current_token(): void
    {
        $user = User::create([
            'google_subject' => 'google-sub-me',
            'name' => 'Me User',
            'email' => 'me@example.test',
            'role' => 'CUSTOMER',
            'is_active' => true,
        ]);

        $token = $user->createToken('flutter')->plainTextToken;

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/me')
            ->assertOk()
            ->assertJsonPath('data.user.id', $user->id);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/auth/logout')
            ->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 0);

        // Clear the cached guard user between requests so the next call exercises
        // Sanctum token lookup against the database rather than the test container's
        // in-memory guard state.
        Auth::forgetGuards();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/me')
            ->assertUnauthorized();
    }

    public function test_missing_or_invalid_authentication_cannot_read_me(): void
    {
        $this->getJson('/api/v1/me')->assertUnauthorized();

        $this->withHeader('Authorization', 'Bearer not-a-real-token')
            ->getJson('/api/v1/me')
            ->assertUnauthorized();
    }

    public function test_inactive_authenticated_user_is_blocked_and_current_token_is_revoked(): void
    {
        $user = User::create([
            'google_subject' => 'google-sub-blocked',
            'name' => 'Blocked User',
            'email' => 'blocked@example.test',
            'role' => 'CUSTOMER',
            'is_active' => false,
        ]);

        $token = $user->createToken('flutter')->plainTextToken;

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/me')
            ->assertForbidden()
            ->assertJsonPath('code', 'ACCOUNT_INACTIVE');

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_google_login_is_rate_limited_after_ten_attempts_from_same_ip(): void
    {
        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->times(10)
                ->andThrow(new RuntimeException('invalid'));
        });

        for ($attempt = 0; $attempt < 10; $attempt++) {
            $this->postJson('/api/v1/auth/google', [
                'credential' => 'invalid-google-token',
            ])->assertUnauthorized();
        }

        $this->postJson('/api/v1/auth/google', [
            'credential' => 'invalid-google-token',
        ])->assertTooManyRequests()
            ->assertJsonPath('code', 'RATE_LIMITED')
            ->assertJsonPath('message', 'Too many requests. Please try again later.');
    }

    public function test_failed_google_credential_logs_only_safe_context(): void
    {
        Log::spy();

        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->with('secret-google-credential')
                ->andThrow(new RuntimeException('invalid'));
        });

        $this->postJson('/api/v1/auth/google', [
            'credential' => 'secret-google-credential',
        ])->assertUnauthorized()
            ->assertJsonStructure(['message', 'errors', 'code']);

        Log::shouldHaveReceived('warning')
            ->once()
            ->withArgs(function (string $message, array $context): bool {
                return $message === 'Google credential verification failed.'
                    && ! array_key_exists('credential', $context)
                    && ($context['route'] ?? null) === 'api.v1.auth.google';
            });
    }

    public function test_api_validation_errors_follow_contract_shape(): void
    {
        $this->postJson('/api/v1/auth/google', [])
            ->assertUnprocessable()
            ->assertJsonStructure(['message', 'errors' => ['credential'], 'code'])
            ->assertJsonPath('code', 'VALIDATION_FAILED')
            ->assertJsonPath('message', 'Validation failed.');
    }

    public function test_unknown_api_route_uses_contract_not_found_shape(): void
    {
        $this->getJson('/api/v1/does-not-exist')
            ->assertNotFound()
            ->assertJsonStructure(['message', 'errors', 'code'])
            ->assertJsonPath('code', 'NOT_FOUND');
    }

    public function test_admin_password_login_returns_a_token_only_for_an_active_admin(): void
    {
        $admin = User::create([
            'google_subject' => null,
            'name' => 'Admin User',
            'email' => 'admin@example.test',
            'password' => password_hash('CorrectHorseBatteryStaple!', PASSWORD_BCRYPT),
            'role' => User::ROLE_ADMIN,
            'is_active' => true,
        ]);

        $this->postJson('/api/v1/auth/admin/password', [
            'email' => $admin->email,
            'password' => 'CorrectHorseBatteryStaple!',
        ])->assertOk()
            ->assertJsonPath('data.user.id', $admin->id)
            ->assertJsonPath('data.user.role', 'ADMIN')
            ->assertJsonStructure(['data' => ['token', 'user']]);

        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_admin_password_login_rejects_non_admin_and_invalid_password(): void
    {
        User::create([
            'google_subject' => null,
            'name' => 'Customer User',
            'email' => 'customer@example.test',
            'password' => password_hash('CorrectHorseBatteryStaple!', PASSWORD_BCRYPT),
            'role' => User::ROLE_CUSTOMER,
            'is_active' => true,
        ]);

        $this->postJson('/api/v1/auth/admin/password', [
            'email' => 'customer@example.test',
            'password' => 'CorrectHorseBatteryStaple!',
        ])->assertUnauthorized()
            ->assertJsonPath('code', 'INVALID_CREDENTIALS');

        $this->postJson('/api/v1/auth/admin/password', [
            'email' => 'customer@example.test',
            'password' => 'wrong-password',
        ])->assertUnauthorized()
            ->assertJsonPath('code', 'INVALID_CREDENTIALS');

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_admin_google_login_requires_an_existing_admin_identity(): void
    {
        $admin = User::create([
            'google_subject' => 'admin-google-sub',
            'name' => 'Admin User',
            'email' => 'admin@example.test',
            'role' => User::ROLE_ADMIN,
            'is_active' => true,
        ]);

        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->with('admin-google-token')
                ->andReturn([
                    'sub' => 'admin-google-sub',
                    'name' => 'Updated Admin',
                    'email' => 'admin@example.test',
                ]);
        });

        $this->postJson('/api/v1/auth/admin/google', [
            'credential' => 'admin-google-token',
        ])->assertOk()
            ->assertJsonPath('data.user.id', $admin->id)
            ->assertJsonPath('data.user.role', 'ADMIN');

        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_admin_google_login_does_not_create_a_new_account(): void
    {
        $this->mock(GoogleCredentialVerifier::class, function ($mock): void {
            $mock->shouldReceive('verify')
                ->once()
                ->andReturn([
                    'sub' => 'unprovisioned-google-sub',
                    'name' => 'Unprovisioned User',
                    'email' => 'unprovisioned@example.test',
                ]);
        });

        $this->postJson('/api/v1/auth/admin/google', [
            'credential' => 'google-token',
        ])->assertForbidden()
            ->assertJsonPath('code', 'ADMIN_ACCESS_REQUIRED');

        $this->assertDatabaseCount('users', 0);
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

}
