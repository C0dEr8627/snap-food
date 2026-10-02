<?php

namespace Tests\Feature;

use App\Models\Cart;
use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CartApiTest extends TestCase
{
    use RefreshDatabase;

    private function user(string $suffix): User
    {
        return User::create([
            'google_subject' => 'google-cart-'.$suffix,
            'name' => ucfirst($suffix),
            'email' => $suffix.'@example.test',
            'role' => User::ROLE_CUSTOMER,
            'is_active' => true,
        ]);
    }

    private function product(): Product
    {
        $category = Category::create([
            'name' => 'Pizza',
            'slug' => 'pizza',
            'is_active' => true,
        ]);

        return Product::create([
            'category_id' => $category->id,
            'name' => 'Margherita',
            'slug' => 'margherita',
            'price' => '299.00',
            'stock_quantity' => 10,
            'is_available' => true,
            'is_active' => true,
        ]);
    }

    public function test_cart_is_persisted_and_isolated_per_authenticated_customer(): void
    {
        $customerA = $this->user('customer-a');
        $customerB = $this->user('customer-b');
        $product = $this->product();

        $this->actingAs($customerA, 'sanctum')
            ->postJson('/api/v1/consumer/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk()
            ->assertJsonPath('data.quantity', 2);

        $this->assertDatabaseHas('carts', [
            'user_id' => $customerA->id,
            'product_id' => $product->id,
            'quantity' => 2,
        ]);

        $this->actingAs($customerB, 'sanctum')
            ->getJson('/api/v1/consumer/cart')
            ->assertOk()
            ->assertJsonCount(0, 'data');

        $this->actingAs($customerA, 'sanctum')
            ->getJson('/api/v1/consumer/cart')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.product_id', (string) $product->id);
    }

    public function test_customer_cannot_change_another_customers_cart_item(): void
    {
        $customerA = $this->user('owner');
        $customerB = $this->user('attacker');
        $product = $this->product();

        Cart::create([
            'user_id' => $customerA->id,
            'product_id' => $product->id,
            'quantity' => 3,
        ]);

        $this->actingAs($customerB, 'sanctum')
            ->patchJson('/api/v1/consumer/cart/items/'.$product->id, ['quantity' => 1])
            ->assertNotFound();

        $this->actingAs($customerB, 'sanctum')
            ->deleteJson('/api/v1/consumer/cart/items/'.$product->id)
            ->assertOk();

        $this->assertDatabaseHas('carts', [
            'user_id' => $customerA->id,
            'product_id' => $product->id,
            'quantity' => 3,
        ]);
    }
}
