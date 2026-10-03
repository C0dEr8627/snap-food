<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Collapse delivery-partner operational state into delivery_partner_users.
     *
     * A delivery partner is an account in this architecture, so a second
     * delivery_partners row only duplicated identity/state and created an
     * unnecessary join. Existing state is copied before the legacy table and
     * its foreign key are removed.
     */
    public function up(): void
    {
        Schema::table('delivery_partner_users', function (Blueprint $table): void {
            $table->boolean('is_approved')->default(false)->after('is_active');
            $table->boolean('is_available')->default(false)->after('is_approved');
            $table->timestamp('approved_at')->nullable()->after('is_available');
            $table->foreignId('approved_by')->nullable()->after('approved_at')
                ->constrained('admin_users')
                ->nullOnDelete();

            $table->index(['is_approved', 'is_active', 'is_available']);
        });

        DB::table('delivery_partners')
            ->orderBy('id')
            ->chunkById(500, function ($partners): void {
                foreach ($partners as $partner) {
                    $exists = DB::table('delivery_partner_users')
                        ->where('id', $partner->user_id)
                        ->exists();

                    if (! $exists) {
                        throw new RuntimeException(
                            "Cannot normalize delivery partner {$partner->id}: delivery_partner_users row {$partner->user_id} was not found."
                        );
                    }

                    DB::table('delivery_partner_users')
                        ->where('id', $partner->user_id)
                        ->update([
                            'is_approved' => $partner->is_approved,
                            'is_active' => $partner->is_active,
                            'is_available' => $partner->is_available,
                            'approved_at' => $partner->approved_at,
                            'approved_by' => $partner->approved_by,
                        ]);
                }
            });

        Schema::table('order_assignments', function (Blueprint $table): void {
            $table->dropForeign(['delivery_partner_id']);
            $table->foreign('delivery_partner_id')
                ->references('id')
                ->on('delivery_partner_users')
                ->restrictOnDelete();
        });

        Schema::dropIfExists('delivery_partners');
    }

    public function down(): void
    {
        Schema::create('delivery_partners', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->unique()
                ->constrained('delivery_partner_users')
                ->cascadeOnDelete();
            $table->boolean('is_approved')->default(false);
            $table->boolean('is_active')->default(true);
            $table->boolean('is_available')->default(false);
            $table->timestamp('approved_at')->nullable();
            $table->foreignId('approved_by')->nullable()
                ->constrained('admin_users')
                ->nullOnDelete();
            $table->timestamps();

            $table->index(['is_approved', 'is_active', 'is_available']);
        });

        DB::table('delivery_partner_users')
            ->orderBy('id')
            ->chunkById(500, function ($partners): void {
                DB::table('delivery_partners')->insert(
                    collect($partners)->map(fn ($partner): array => [
                        'user_id' => $partner->id,
                        'is_approved' => $partner->is_approved,
                        'is_active' => $partner->is_active,
                        'is_available' => $partner->is_available,
                        'approved_at' => $partner->approved_at,
                        'approved_by' => $partner->approved_by,
                        'created_at' => $partner->created_at,
                        'updated_at' => $partner->updated_at,
                    ])->all()
                );
            });

        Schema::table('order_assignments', function (Blueprint $table): void {
            $table->dropForeign(['delivery_partner_id']);
            $table->foreign('delivery_partner_id')
                ->references('id')
                ->on('delivery_partners')
                ->restrictOnDelete();
        });

        Schema::table('delivery_partner_users', function (Blueprint $table): void {
            $table->dropForeign(['approved_by']);
            $table->dropIndex(['is_approved', 'is_active', 'is_available']);
            $table->dropColumn(['approved_by', 'approved_at', 'is_available', 'is_approved']);
        });
    }
};
