<?php

namespace Tests\Feature;

use App\Models\AdminUser;
use App\Models\Category;
use App\Models\CustomerUser;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CatalogueApiTest extends TestCase
{
    use RefreshDatabase;

    private function customer(bool $active = true): CustomerUser
    {
        return CustomerUser::create([
            'google_subject' => 'google-catalogue-'.uniqid(),
            'name' => 'Customer',
            'email' => 'customer-'.uniqid().'@example.test',
            'is_active' => $active,
        ]);
    }

    public function test_customer_can_list_only_active_available_catalogue_items(): void
    {
        $customer = $this->customer();

        $activeCategory = Category::create(['name' => 'Pizza', 'slug' => 'pizza', 'is_active' => true]);
        $inactiveCategory = Category::create(['name' => 'Old', 'slug' => 'old', 'is_active' => false]);

        Product::create([
            'category_id' => $activeCategory->id,
            'name' => 'Margherita',
            'slug' => 'margherita',
            'price' => '299.00',
            'is_active' => true,
            'is_available' => true,
        ]);
        Product::create([
            'category_id' => $activeCategory->id,
            'name' => 'Unavailable',
            'slug' => 'unavailable',
            'price' => '199.00',
            'is_active' => true,
            'is_available' => false,
        ]);
        Product::create([
            'category_id' => $inactiveCategory->id,
            'name' => 'Hidden',
            'slug' => 'hidden',
            'price' => '199.00',
            'is_active' => true,
            'is_available' => true,
        ]);

        $this->actingAs($customer, 'sanctum')
            ->getJson('/api/v1/consumer/categories')
            ->assertOk()
            ->assertJsonPath('data.data.0.slug', 'pizza')
            ->assertJsonCount(1, 'data.data');

        $this->actingAs($customer, 'sanctum')
            ->getJson('/api/v1/consumer/products?search=Margherita')
            ->assertOk()
            ->assertJsonPath('data.data.0.slug', 'margherita')
            ->assertJsonCount(1, 'data.data');
    }

    public function test_customer_can_search_and_paginate_products(): void
    {
        $customer = $this->customer();
        $category = Category::create(['name' => 'Pizza', 'slug' => 'pizza']);

        foreach (['Alpha', 'Beta', 'Gamma'] as $name) {
            Product::create([
                'category_id' => $category->id,
                'name' => $name,
                'slug' => strtolower($name),
                'price' => '100.00',
            ]);
        }

        $response = $this->actingAs($customer, 'sanctum')
            ->getJson('/api/v1/consumer/products?search=Beta&per_page=1');

        $response->assertOk()
            ->assertJsonPath('data.per_page', 1)
            ->assertJsonPath('data.total', 1)
            ->assertJsonPath('data.data.0.name', 'Beta');
    }

    public function test_customer_cannot_write_catalogue(): void
    {
        $customer = $this->customer();
        $category = Category::create(['name' => 'Pizza', 'slug' => 'pizza']);

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/admin/categories', ['name' => 'Pasta', 'slug' => 'pasta'])
            ->assertForbidden();

        $this->actingAs($customer, 'sanctum')
            ->postJson('/api/v1/admin/products', [
                'category_id' => $category->id,
                'name' => 'Pasta',
                'slug' => 'pasta',
                'price' => '199.00',
            ])
            ->assertForbidden();
    }

    public function test_admin_can_create_update_and_soft_deactivate_catalogue_items(): void
    {
        $admin = AdminUser::create([
            'google_subject' => 'google-catalogue-admin',
            'name' => 'Admin',
            'email' => 'admin-catalogue@example.test',
            'is_active' => true,
        ]);
        $category = Category::create(['name' => 'Pizza', 'slug' => 'pizza']);

        $this->actingAs($admin, 'sanctum')
            ->postJson('/api/v1/admin/categories', ['name' => 'Burgers', 'slug' => 'burgers'])
            ->assertCreated()
            ->assertJsonPath('data.slug', 'burgers');

        $categoryResponse = $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/categories/'.$category->id, ['name' => 'Pizza & More'])
            ->assertOk()
            ->assertJsonPath('data.name', 'Pizza & More');

        $this->assertSame('Pizza & More', $categoryResponse->json('data.name'));

        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Margherita',
            'slug' => 'margherita',
            'price' => '299.00',
        ]);

        $this->actingAs($admin, 'sanctum')
            ->patchJson('/api/v1/admin/products/'.$product->id, ['price' => '349.00'])
            ->assertOk()
            ->assertJsonPath('data.price', '349.00');

        $this->actingAs($admin, 'sanctum')
            ->deleteJson('/api/v1/admin/products/'.$product->id)
            ->assertOk()
            ->assertJsonPath('data.is_active', false)
            ->assertJsonPath('data.is_available', false);
    }

    public function test_catalogue_requires_authentication(): void
    {
        $this->getJson('/api/v1/consumer/products')->assertUnauthorized();
        $this->getJson('/api/v1/consumer/categories')->assertUnauthorized();
    }
}
