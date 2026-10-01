<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            if (! Schema::hasColumn('products', 'dietary')) {
                $table->string('dietary', 40)->default('Non-Veg')->after('is_active');
            }

            if (! Schema::hasColumn('products', 'tags')) {
                $table->json('tags')->nullable()->after('dietary');
            }
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table): void {
            $columns = [];

            if (Schema::hasColumn('products', 'tags')) {
                $columns[] = 'tags';
            }

            if (Schema::hasColumn('products', 'dietary')) {
                $columns[] = 'dietary';
            }

            if ($columns !== []) {
                $table->dropColumn($columns);
            }
        });
    }
};
