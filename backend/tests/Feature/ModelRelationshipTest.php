<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ModelRelationshipTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_addresses_relationship_is_bidirectional(): void
    {
        $user = User::create([
            'google_subject' => 'google-user-1',
            'name' => 'Test User',
            'email' => 'user1@example.test',
        ]);

        $address = Address::create([
            'user_id' => $user->id,
            'label' => 'Home',
            'recipient_name' => 'Test User',
            'address_line1' => '1 Test Street',
            'city' => 'Mumbai',
            'state' => 'Maharashtra',
            'postal_code' => '400001',
        ]);

        $this->assertTrue($user->addresses->contains($address));
        $this->assertTrue($address->user->is($user));
    }

    public function test_category_products_relationship_is_bidirectional(): void
    {
        $category = Category::create([
            'name' => 'Burgers',
            'slug' => 'burgers',
        ]);

        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Classic Burger',
            'slug' => 'classic-burger',
            'price' => '149.00',
        ]);

        $this->assertTrue($category->products->contains($product));
        $this->assertTrue($product->category->is($category));
    }

    public function test_foreign_keys_prevent_orphaned_children(): void
    {
        $user = User::create([
            'google_subject' => 'google-user-2',
            'name' => 'Test User',
        ]);

        Address::create([
            'user_id' => $user->id,
            'label' => 'Home',
            'recipient_name' => 'Test User',
            'address_line1' => '1 Test Street',
            'city' => 'Mumbai',
            'state' => 'Maharashtra',
            'postal_code' => '400001',
        ]);

        $user->delete();

        $this->assertDatabaseMissing('addresses', ['user_id' => $user->id]);

        $category = Category::create([
            'name' => 'Sides',
            'slug' => 'sides',
        ]);

        Product::create([
            'category_id' => $category->id,
            'name' => 'Fries',
            'slug' => 'fries',
            'price' => '99.00',
        ]);

        $this->expectException(\Illuminate\Database\QueryException::class);
        $category->delete();
    }
}
