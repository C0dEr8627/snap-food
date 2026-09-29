<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DatabaseSeederTest extends TestCase
{
    use RefreshDatabase;

    public function test_catalogue_seed_is_deterministic_and_preserves_inactive_demo_records(): void
    {
        $this->seed();

        $this->assertSame(4, Category::count());
        $this->assertSame(5, Product::count());

        $this->assertDatabaseHas('categories', [
            'slug' => 'burgers',
            'is_active' => true,
        ]);

        $this->assertDatabaseHas('products', [
            'slug' => 'classic-chicken-burger',
            'price' => '179.00',
            'is_available' => true,
            'is_active' => true,
        ]);

        $this->assertDatabaseHas('categories', [
            'slug' => 'archived',
            'is_active' => false,
        ]);

        $this->assertDatabaseHas('products', [
            'slug' => 'archived-special',
            'is_available' => false,
            'is_active' => false,
        ]);

        $this->seed();
        $this->assertSame(4, Category::count());
        $this->assertSame(5, Product::count());
    }
}
