<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Move operational foreign keys to the dedicated account tables.
     * The legacy users table is retained temporarily for historical order
     * status actors and existing legacy Sanctum tokens; new authentication
     * flows no longer create or query rows there.
     */
    public function up(): void
    {
        Schema::table('addresses', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->foreign('user_id')->references('id')->on('customer_users')->cascadeOnDelete();
        });

        Schema::table('orders', function (Blueprint $table): void {
            $table->dropForeign(['customer_id']);
            $table->foreign('customer_id')->references('id')->on('customer_users')->restrictOnDelete();
        });

        Schema::table('carts', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->foreign('user_id')->references('id')->on('customer_users')->cascadeOnDelete();
        });

        Schema::table('favorites', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->foreign('user_id')->references('id')->on('customer_users')->cascadeOnDelete();
        });

        Schema::table('delivery_partners', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->dropForeign(['approved_by']);
            $table->foreign('user_id')->references('id')->on('delivery_partner_users')->cascadeOnDelete();
            $table->foreign('approved_by')->references('id')->on('admin_users')->nullOnDelete();
        });

        Schema::table('order_assignments', function (Blueprint $table): void {
            $table->dropForeign(['assigned_by']);
            $table->foreign('assigned_by')->references('id')->on('admin_users')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('order_assignments', function (Blueprint $table): void {
            $table->dropForeign(['assigned_by']);
            $table->foreign('assigned_by')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::table('delivery_partners', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->dropForeign(['approved_by']);
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->foreign('approved_by')->references('id')->on('users')->nullOnDelete();
        });

        Schema::table('favorites', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });

        Schema::table('carts', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });

        Schema::table('orders', function (Blueprint $table): void {
            $table->dropForeign(['customer_id']);
            $table->foreign('customer_id')->references('id')->on('users')->restrictOnDelete();
        });

        Schema::table('addresses', function (Blueprint $table): void {
            $table->dropForeign(['user_id']);
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });
    }
};
