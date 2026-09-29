<?php

namespace Tests\Feature;

use App\Http\Requests\StoreAddressRequest;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\StoreProductRequest;
use App\Models\Category;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Validator;
use Tests\TestCase;

class RequestValidationTest extends TestCase
{
    use RefreshDatabase;

    public function test_address_rules_accept_valid_coordinates_and_reject_out_of_range_values(): void
    {
        $request = new StoreAddressRequest;

        $valid = Validator::make([
            'label' => 'Home',
            'recipient_name' => 'Test User',
            'address_line1' => '1 Test Street',
            'city' => 'Mumbai',
            'state' => 'Maharashtra',
            'postal_code' => '400001',
            'latitude' => 19.076,
            'longitude' => 72.8777,
        ], $request->rules());

        $this->assertFalse($valid->fails());

        $invalid = Validator::make([
            'label' => 'Home',
            'recipient_name' => 'Test User',
            'address_line1' => '1 Test Street',
            'city' => 'Mumbai',
            'state' => 'Maharashtra',
            'postal_code' => '400001',
            'latitude' => 91,
            'longitude' => 181,
        ], $request->rules());

        $this->assertTrue($invalid->fails());
        $this->assertArrayHasKey('latitude', $invalid->errors()->toArray());
        $this->assertArrayHasKey('longitude', $invalid->errors()->toArray());
    }

    public function test_category_rules_validate_slug_and_sort_order(): void
    {
        $request = new StoreCategoryRequest;

        $valid = Validator::make([
            'name' => 'Burgers',
            'slug' => 'burgers',
            'sort_order' => 1,
        ], $request->rules());

        $this->assertFalse($valid->fails());

        $invalid = Validator::make([
            'name' => 'Burgers',
            'slug' => 'not valid',
            'sort_order' => -1,
        ], $request->rules());

        $this->assertTrue($invalid->fails());
        $this->assertArrayHasKey('slug', $invalid->errors()->toArray());
        $this->assertArrayHasKey('sort_order', $invalid->errors()->toArray());
    }

    public function test_product_rules_validate_category_price_and_stock(): void
    {
        $category = Category::create([
            'name' => 'Burgers',
            'slug' => 'burgers',
        ]);

        $request = new StoreProductRequest;

        $valid = Validator::make([
            'category_id' => $category->id,
            'name' => 'Classic Burger',
            'slug' => 'classic-burger',
            'price' => '149.00',
            'stock_quantity' => 10,
        ], $request->rules());

        $this->assertFalse($valid->fails());

        $invalid = Validator::make([
            'category_id' => 'invalid',
            'name' => 'Classic Burger',
            'slug' => 'classic burger',
            'price' => '149.999',
            'stock_quantity' => -1,
        ], $request->rules());

        $this->assertTrue($invalid->fails());
        $this->assertArrayHasKey('category_id', $invalid->errors()->toArray());
        $this->assertArrayHasKey('slug', $invalid->errors()->toArray());
        $this->assertArrayHasKey('price', $invalid->errors()->toArray());
        $this->assertArrayHasKey('stock_quantity', $invalid->errors()->toArray());
    }

    public function test_admin_write_requests_are_not_authorized_for_customers(): void
    {
        $customer = new User(['role' => 'CUSTOMER']);
        $admin = new User(['role' => 'ADMIN']);

        foreach ([new StoreCategoryRequest, new StoreProductRequest] as $request) {
            $request->setUserResolver(fn () => $customer);
            $this->assertFalse($request->authorize());

            $request->setUserResolver(fn () => $admin);
            $this->assertTrue($request->authorize());
        }
    }
}
