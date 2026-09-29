<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('delivery_locations', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('assignment_id')->constrained('order_assignments')->cascadeOnDelete();
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->decimal('accuracy', 8, 2)->nullable();
            $table->timestamp('recorded_at');
            $table->timestamps();

            $table->index(['assignment_id', 'recorded_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('delivery_locations');
    }
};
