<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Favorite extends \Illuminate\Database\Eloquent\Model
{
    protected $fillable = ['user_id', 'product_id'];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(CustomerUser::class, 'user_id');
    }
}
