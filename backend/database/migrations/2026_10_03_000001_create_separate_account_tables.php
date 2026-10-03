<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Introduce separate account stores without disrupting existing API/model
     * consumers. This is an additive compatibility migration; the legacy users
     * table remains authoritative until all foreign keys and auth consumers have
     * been cut over in a later migration.
     */
    public function up(): void
    {
        Schema::create('customer_users', function (Blueprint $table): void {
            $table->id();
            $table->string('google_subject', 255)->nullable()->unique();
            $table->string('name', 150);
            $table->string('email', 255)->nullable()->unique();
            $table->string('phone', 32)->nullable()->unique();
            $table->string('password')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });

        Schema::create('delivery_partner_users', function (Blueprint $table): void {
            $table->id();
            $table->string('name', 150);
            $table->string('email', 255)->nullable()->unique();
            $table->string('phone', 32)->nullable()->unique();
            $table->string('password')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });

        Schema::create('admin_users', function (Blueprint $table): void {
            $table->id();
            $table->string('google_subject', 255)->nullable()->unique();
            $table->string('name', 150);
            $table->string('email', 255)->nullable()->unique();
            $table->string('password')->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });

        // Preserve identifiers where possible, but do not delete or mutate the
        // legacy rows: existing foreign keys, tokens, and API consumers continue
        // working during the account-store cutover.
        DB::table('users')->where('role', 'CUSTOMER')->orderBy('id')->chunk(500, function ($rows): void {
            foreach ($rows as $row) {
                DB::table('customer_users')->updateOrInsert(
                    ['id' => $row->id],
                    [
                        'google_subject' => $row->google_subject,
                        'name' => $row->name,
                        'email' => $row->email,
                        'phone' => $row->phone ?? null,
                        'password' => $row->password ?? null,
                        'is_active' => $row->is_active,
                        'created_at' => $row->created_at,
                        'updated_at' => $row->updated_at,
                    ],
                );
            }
        });

        DB::table('users')->where('role', 'DELIVERY_PARTNER')->orderBy('id')->chunk(500, function ($rows): void {
            foreach ($rows as $row) {
                DB::table('delivery_partner_users')->updateOrInsert(
                    ['id' => $row->id],
                    [
                        'name' => $row->name,
                        'email' => $row->email,
                        'phone' => $row->phone ?? null,
                        'password' => $row->password ?? null,
                        'is_active' => $row->is_active,
                        'created_at' => $row->created_at,
                        'updated_at' => $row->updated_at,
                    ],
                );
            }
        });

        DB::table('users')->where('role', 'ADMIN')->orderBy('id')->chunk(500, function ($rows): void {
            foreach ($rows as $row) {
                DB::table('admin_users')->updateOrInsert(
                    ['id' => $row->id],
                    [
                        'google_subject' => $row->google_subject,
                        'name' => $row->name,
                        'email' => $row->email,
                        'password' => $row->password ?? null,
                        'is_active' => $row->is_active,
                        'created_at' => $row->created_at,
                        'updated_at' => $row->updated_at,
                    ],
                );
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('admin_users');
        Schema::dropIfExists('delivery_partner_users');
        Schema::dropIfExists('customer_users');
    }
};
