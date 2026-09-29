<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Auth\GoogleCredentialVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
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
            ->assertJsonPath('error.code', 'INVALID_GOOGLE_CREDENTIAL');

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
            ->assertJsonPath('error.code', 'ACCOUNT_INACTIVE');

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
            ->assertJsonPath('error.code', 'ACCOUNT_INACTIVE');

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
