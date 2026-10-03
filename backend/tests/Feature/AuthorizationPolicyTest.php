<?php

namespace Tests\Feature;

use App\Http\Middleware\EnsureUserHasRole;
use App\Models\Address;
use App\Models\AdminUser;
use App\Models\Category;
use App\Models\CustomerUser;
use App\Models\Product;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Tests\TestCase;

class AuthorizationPolicyTest extends TestCase
{
    use RefreshDatabase;

    public function test_role_middleware_allows_required_role_and_rejects_other_roles(): void
    {
        $middleware = new EnsureUserHasRole;

        $admin = AdminUser::create([
            'google_subject' => 'google-role-admin',
            'name' => 'Admin',
            'email' => 'admin@example.test',
            'is_active' => true,
        ]);

        $customer = CustomerUser::create([
            'google_subject' => 'google-role-customer',
            'name' => 'Customer',
            'email' => 'customer@example.test',
            'is_active' => true,
        ]);

        $adminRequest = Request::create('/api/v1/admin/test', 'GET');
        $adminRequest->setUserResolver(fn (): Authenticatable => $admin);

        $this->assertSame(
            200,
            $middleware->handle($adminRequest, fn ($request) => response()->json(['ok' => true]), 'ADMIN')->getStatusCode()
        );

        $customerRequest = Request::create('/api/v1/admin/test', 'GET');
        $customerRequest->setUserResolver(fn (): Authenticatable => $customer);

        $this->assertSame(
            403,
            $middleware->handle($customerRequest, fn ($request) => response()->json(['ok' => true]), 'ADMIN')->getStatusCode()
        );
    }

    public function test_role_middleware_rejects_inactive_users(): void
    {
        $middleware = new EnsureUserHasRole;

        $user = AdminUser::create([
            'google_subject' => 'google-role-inactive',
            'name' => 'Inactive Admin',
            'email' => 'inactive-admin@example.test',
            'is_active' => false,
        ]);

        $request = Request::create('/api/v1/admin/test', 'GET');
        $request->setUserResolver(fn (): Authenticatable => $user);

        $response = $middleware->handle(
            $request,
            fn ($next) => response()->json(['ok' => true]),
            'ADMIN',
        );

        $this->assertSame(403, $response->getStatusCode());
        $this->assertSame('ACCOUNT_INACTIVE', $response->getData(true)['code']);
    }

    public function test_address_policy_enforces_customer_ownership_and_allows_admin_access(): void
    {
        $owner = CustomerUser::create([
            'google_subject' => 'google-policy-owner',
            'name' => 'Owner',
            'email' => 'owner@example.test',
            'is_active' => true,
        ]);

        $other = CustomerUser::create([
            'google_subject' => 'google-policy-other',
            'name' => 'Other',
            'email' => 'other@example.test',
            'is_active' => true,
        ]);

        $admin = AdminUser::create([
            'google_subject' => 'google-policy-admin',
            'name' => 'Admin',
            'email' => 'policy-admin@example.test',
            'is_active' => true,
        ]);

        $address = Address::create([
            'user_id' => $owner->id,
            'label' => 'Home',
            'recipient_name' => 'Owner',
            'address_line1' => '1 Main Street',
            'city' => 'Mumbai',
            'state' => 'Maharashtra',
            'postal_code' => '400001',
            'country' => 'India',
        ]);

        $this->assertTrue(Gate::forUser($owner)->allows('view', $address));
        $this->assertFalse(Gate::forUser($other)->allows('view', $address));
        $this->assertTrue(Gate::forUser($admin)->allows('view', $address));
        $this->assertTrue(Gate::forUser($owner)->allows('update', $address));
        $this->assertFalse(Gate::forUser($other)->allows('update', $address));
        $this->assertTrue(Gate::forUser($admin)->allows('delete', $address));
    }

    public function test_category_and_product_write_policies_are_admin_only(): void
    {
        $admin = AdminUser::create([
            'google_subject' => 'google-policy-admin-write',
            'name' => 'Admin',
            'email' => 'policy-admin-write@example.test',
            'is_active' => true,
        ]);

        $customer = CustomerUser::create([
            'google_subject' => 'google-policy-customer-write',
            'name' => 'Customer',
            'email' => 'policy-customer-write@example.test',
            'is_active' => true,
        ]);

        $category = Category::create([
            'name' => 'Pizza',
            'slug' => 'pizza',
        ]);

        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Margherita',
            'slug' => 'margherita',
            'price' => '299.00',
        ]);

        $this->assertTrue(Gate::forUser($admin)->allows('create', Category::class));
        $this->assertFalse(Gate::forUser($customer)->allows('create', Category::class));
        $this->assertTrue(Gate::forUser($admin)->allows('update', $category));
        $this->assertFalse(Gate::forUser($customer)->allows('update', $category));

        $this->assertTrue(Gate::forUser($admin)->allows('create', Product::class));
        $this->assertFalse(Gate::forUser($customer)->allows('create', Product::class));
        $this->assertTrue(Gate::forUser($admin)->allows('delete', $product));
        $this->assertFalse(Gate::forUser($customer)->allows('delete', $product));
    }
}
