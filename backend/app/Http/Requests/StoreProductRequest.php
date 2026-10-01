<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role === 'ADMIN';
    }

    public function rules(): array
    {
        return [
            'category_id' => ['required', 'integer', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:180'],
            'slug' => ['required', 'string', 'max:200', 'alpha_dash'],
            'description' => ['nullable', 'string'],
            'price' => ['required', 'numeric', 'decimal:0,2', 'min:0'],
            'image' => ['nullable', 'url', 'max:2048'],
            'stock_quantity' => ['nullable', 'integer', 'min:0'],
            'is_available' => ['nullable', 'boolean'],
            'is_active' => ['nullable', 'boolean'],
            'dietary' => ['nullable', 'string', 'max:40'],
            'tags' => ['nullable', 'array', 'max:30'],
            'tags.*' => ['string', 'max:60'],
        ];
    }
}
