<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiSurfaceTest extends TestCase
{
    public function test_client_api_surfaces_are_explicitly_namespaced(): void
    {
        $this->getJson('/api/v1/consumer/categories')->assertUnauthorized();
        $this->getJson('/api/v1/consumer/products')->assertUnauthorized();
        $this->getJson('/api/v1/consumer/orders')->assertUnauthorized();

        $this->getJson('/api/v1/delivery/assignments')->assertUnauthorized();

        $this->getJson('/api/v1/admin/invoices')->assertUnauthorized();
        $this->getJson('/api/v1/admin/categories')->assertUnauthorized();
        $this->getJson('/api/v1/admin/products')->assertUnauthorized();

        $this->getJson('/api/v1/categories')->assertNotFound();
        $this->getJson('/api/v1/products')->assertNotFound();
        $this->getJson('/api/v1/orders')->assertNotFound();
    }

    public function test_admin_auth_is_under_admin_surface(): void
    {
        $this->postJson('/api/v1/admin/auth/password', [
            'email' => 'missing@example.test',
            'password' => 'invalid123',
        ])->assertUnauthorized();

        $this->postJson('/api/v1/auth/admin/password', [
            'email' => 'missing@example.test',
            'password' => 'invalid',
        ])->assertNotFound();
    }
}
