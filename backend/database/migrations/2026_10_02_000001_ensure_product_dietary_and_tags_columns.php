<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('products', 'dietary')) {
            Schema::table('products', function (Blueprint $table): void {
                $table->string('dietary', 40)->default('Non-Veg')->after('is_active');
            });
        }

        if (! Schema::hasColumn('products', 'tags')) {
            Schema::table('products', function (Blueprint $table): void {
                $table->json('tags')->nullable()->after('dietary');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('products', 'tags')) {
            Schema::table('products', function (Blueprint $table): void {
                $table->dropColumn('tags');
            });
        }

        if (Schema::hasColumn('products', 'dietary')) {
            Schema::table('products', function (Blueprint $table): void {
                $table->dropColumn('dietary');
            });
        }
    }
};
