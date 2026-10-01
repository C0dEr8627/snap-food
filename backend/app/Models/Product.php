<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Product extends Model
{
    protected $appends = ['image_url'];
    protected $fillable = [
        'category_id',
        'name',
        'slug',
        'description',
        'price',
        'image',
        'stock_quantity',
        'is_available',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'stock_quantity' => 'integer',
            'is_available' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function getImageUrlAttribute(): ?string
    {
        $image = $this->image;
        if (! is_string($image) || trim($image) === '') return null;
        if (preg_match('#^https?://#i', $image)) return $image;
        return url('/' . ltrim($image, '/'));
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
