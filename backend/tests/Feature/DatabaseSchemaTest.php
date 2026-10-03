<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class DatabaseSchemaTest extends TestCase
{
    public function test_initial_business_schema_is_present(): void
    {
        foreach (['customer_users', 'delivery_partner_users', 'admin_users', 'addresses', 'categories', 'products'] as $table) {
            $this->assertTrue(Schema::hasTable($table), "Missing table: {$table}");
        }

        $this->assertTrue(Schema::hasColumn('customer_users', 'google_subject') && Schema::hasColumn('admin_users', 'google_subject'));
        $this->assertTrue(Schema::hasColumn('customer_users', 'is_active'));
        $this->assertTrue(Schema::hasColumn('delivery_partner_users', 'is_active') && Schema::hasColumn('admin_users', 'is_active'));

        $this->assertTrue(Schema::hasColumn('addresses', 'user_id'));
        $this->assertTrue(Schema::hasColumn('addresses', 'latitude'));
        $this->assertTrue(Schema::hasColumn('addresses', 'longitude'));

        $this->assertTrue(Schema::hasColumn('categories', 'slug'));
        $this->assertTrue(Schema::hasColumn('categories', 'sort_order'));
        $this->assertTrue(Schema::hasColumn('categories', 'is_active'));

        $this->assertTrue(Schema::hasColumn('products', 'category_id'));
        $this->assertTrue(Schema::hasColumn('products', 'price'));
        $this->assertTrue(Schema::hasColumn('products', 'stock_quantity'));
        $this->assertTrue(Schema::hasColumn('products', 'is_available'));
        $this->assertTrue(Schema::hasColumn('products', 'is_active'));
    }
}
