<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Cart extends \Illuminate\Database\Eloquent\Model
{
    protected $fillable = ['user_id', 'product_id', 'quantity'];

    protected function casts(): array
    {
        return ['quantity' => 'integer'];
    }

    public function user(): BelongsTo { return $this->belongsTo(CustomerUser::class, 'user_id'); }
    public function product(): BelongsTo { return $this->belongsTo(Product::class); }
}
