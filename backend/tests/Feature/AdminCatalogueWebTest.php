<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminCatalogueWebTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_create_update_and_deactivate_catalogue_records(): void
    {
        $admin = User::factory()->admin()->create();

        $this->actingAs($admin, 'web')
            ->post('/admin/catalogue/categories', [
                'name' => 'Wraps',
                'slug' => 'wraps',
                'sort_order' => 3,
                'is_active' => '1',
            ])
            ->assertRedirect('/admin/catalogue');

        $category = Category::query()->where('slug', 'wraps')->firstOrFail();
        $this->assertTrue($category->is_active);

        $this->actingAs($admin, 'web')
            ->post('/admin/catalogue/products', [
                'category_id' => $category->id,
                'name' => 'Paneer Wrap',
                'slug' => 'paneer-wrap',
                'price' => '125.00',
                'stock_quantity' => 10,
                'is_available' => '1',
                'is_active' => '1',
            ])
            ->assertRedirect('/admin/catalogue');

        $product = Product::query()->where('slug', 'paneer-wrap')->firstOrFail();
        $this->assertSame('125.00', $product->price);

        $this->actingAs($admin, 'web')
            ->patch('/admin/catalogue/products/'.$product->id, [
                'category_id' => $category->id,
                'name' => 'Paneer Wrap Large',
                'slug' => 'paneer-wrap-large',
                'price' => '150.00',
                'stock_quantity' => 8,
                'is_available' => '1',
                'is_active' => '1',
            ])
            ->assertRedirect('/admin/catalogue');

        $this->assertDatabaseHas('products', ['id' => $product->id, 'name' => 'Paneer Wrap Large', 'price' => '150.00']);

        $this->actingAs($admin, 'web')
            ->post('/admin/catalogue/products/'.$product->id.'/deactivate')
            ->assertRedirect('/admin/catalogue');

        $this->assertDatabaseHas('products', ['id' => $product->id, 'is_active' => false, 'is_available' => false]);
    }

    public function test_customer_cannot_access_catalogue_management_or_write_actions(): void
    {
        $customer = User::factory()->create();
        $category = Category::create(['name' => 'Meals', 'slug' => 'meals', 'sort_order' => 0, 'is_active' => true]);

        $this->actingAs($customer, 'web')
            ->get('/admin/catalogue')
            ->assertForbidden();

        $this->actingAs($customer, 'web')
            ->post('/admin/catalogue/categories', ['name' => 'Nope', 'slug' => 'nope'])
            ->assertForbidden();
    }

    public function test_catalogue_search_and_filter_are_available_to_admin(): void
    {
        $admin = User::factory()->admin()->create();
        $category = Category::create(['name' => 'Drinks', 'slug' => 'drinks', 'sort_order' => 0, 'is_active' => true]);
        Product::create([
            'category_id' => $category->id,
            'name' => 'Lime Soda',
            'slug' => 'lime-soda',
            'price' => '30.00',
            'stock_quantity' => 5,
            'is_available' => true,
            'is_active' => true,
        ]);

        $this->actingAs($admin, 'web')
            ->get('/admin/catalogue?q=Lime&type=products')
            ->assertOk()
            ->assertSee('Lime Soda')
            ->assertSee('Catalogue management');
    }
}
