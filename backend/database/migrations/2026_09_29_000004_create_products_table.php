<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('category_id')->constrained()->restrictOnDelete();
            $table->string('name', 180);
            $table->string('slug', 200)->unique();
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->string('image', 2048)->nullable();
            $table->unsignedInteger('stock_quantity')->default(0);
            $table->boolean('is_available')->default(true)->index();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();

            $table->index(['category_id', 'is_active', 'is_available']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
