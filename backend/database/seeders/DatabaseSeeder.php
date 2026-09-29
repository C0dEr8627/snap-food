<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Burgers',
                'slug' => 'burgers',
                'sort_order' => 10,
                'is_active' => true,
            ],
            [
                'name' => 'Pizza',
                'slug' => 'pizza',
                'sort_order' => 20,
                'is_active' => true,
            ],
            [
                'name' => 'Beverages',
                'slug' => 'beverages',
                'sort_order' => 30,
                'is_active' => true,
            ],
            [
                'name' => 'Archived',
                'slug' => 'archived',
                'sort_order' => 90,
                'is_active' => false,
            ],
        ];

        foreach ($categories as $categoryData) {
            $category = Category::updateOrCreate(
                ['slug' => $categoryData['slug']],
                $categoryData,
            );

            if ($category->slug === 'burgers') {
                $category->products()->updateOrCreate(
                    ['slug' => 'classic-chicken-burger'],
                    [
                        'name' => 'Classic Chicken Burger',
                        'description' => 'Grilled chicken burger with lettuce and house sauce.',
                        'price' => 179.00,
                        'stock_quantity' => 25,
                        'is_available' => true,
                        'is_active' => true,
                    ],
                );

                $category->products()->updateOrCreate(
                    ['slug' => 'veg-crispy-burger'],
                    [
                        'name' => 'Veg Crispy Burger',
                        'description' => 'Crispy vegetable patty with fresh lettuce and sauce.',
                        'price' => 149.00,
                        'stock_quantity' => 30,
                        'is_available' => true,
                        'is_active' => true,
                    ],
                );
            }

            if ($category->slug === 'pizza') {
                $category->products()->updateOrCreate(
                    ['slug' => 'margherita-pizza'],
                    [
                        'name' => 'Margherita Pizza',
                        'description' => 'Classic tomato, mozzarella and basil pizza.',
                        'price' => 249.00,
                        'stock_quantity' => 20,
                        'is_available' => true,
                        'is_active' => true,
                    ],
                );
            }

            if ($category->slug === 'beverages') {
                $category->products()->updateOrCreate(
                    ['slug' => 'fresh-lime-soda'],
                    [
                        'name' => 'Fresh Lime Soda',
                        'description' => 'Chilled fresh lime soda.',
                        'price' => 89.00,
                        'stock_quantity' => 40,
                        'is_available' => true,
                        'is_active' => true,
                    ],
                );
            }

            if ($category->slug === 'archived') {
                $category->products()->updateOrCreate(
                    ['slug' => 'archived-special'],
                    [
                        'name' => 'Archived Special',
                        'description' => 'Seed record kept to exercise inactive catalogue filtering.',
                        'price' => 99.00,
                        'stock_quantity' => 0,
                        'is_available' => false,
                        'is_active' => false,
                    ],
                );
            }
        }
    }
}
