<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use RuntimeException;

return new class extends Migration
{
    /**
     * Finalize the account split:
     * - give status-history rows an explicit account model type;
     * - repoint existing Sanctum tokens to their dedicated account model;
     * - remove the legacy users table.
     *
     * This migration is intentionally irreversible because the old users table
     * cannot be reconstructed safely when independent account tables reuse IDs.
     */
    public function up(): void
    {
        Schema::table('order_status_histories', function (Blueprint $table): void {
            $table->string('actor_type', 255)->nullable()->after('actor_id');
            $table->index(['actor_type', 'actor_id']);
        });

        DB::table('users')
            ->orderBy('id')
            ->chunk(500, function ($users): void {
                foreach ($users as $user) {
                    $model = match ($user->role) {
                        'CUSTOMER' => 'App\\Models\\CustomerUser',
                        'DELIVERY_PARTNER' => 'App\\Models\\DeliveryPartnerUser',
                        'ADMIN' => 'App\\Models\\AdminUser',
                        default => null,
                    };

                    if ($model === null) {
                        continue;
                    }

                    DB::table('order_status_histories')
                        ->where('actor_id', $user->id)
                        ->whereNull('actor_type')
                        ->update(['actor_type' => $model]);

                    DB::table('personal_access_tokens')
                        ->where('tokenable_type', 'App\\Models\\User')
                        ->where('tokenable_id', $user->id)
                        ->update(['tokenable_type' => $model]);
                }
            });

        $unmappedHistoryCount = DB::table('order_status_histories')
            ->whereNotNull('actor_id')
            ->whereNull('actor_type')
            ->count();

        if ($unmappedHistoryCount > 0) {
            throw new RuntimeException(
                "Cannot remove legacy users: {$unmappedHistoryCount} order-status actors could not be mapped."
            );
        }

        $legacyTokenCount = DB::table('personal_access_tokens')
            ->where('tokenable_type', 'App\\Models\\User')
            ->count();

        if ($legacyTokenCount > 0) {
            throw new RuntimeException(
                "Cannot remove legacy users: {$legacyTokenCount} Sanctum tokens still reference App\\Models\\User."
            );
        }

        Schema::dropIfExists('users');
    }

    public function down(): void
    {
        throw new RuntimeException(
            'The legacy users table was intentionally removed and cannot be reconstructed safely. Restore from a database backup instead.'
        );
    }
};
