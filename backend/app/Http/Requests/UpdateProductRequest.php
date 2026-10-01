<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('update', $this->route('product')) ?? false;
    }

    public function rules(): array
    {
        $productId = $this->route('product')?->id;

        return [
            'category_id' => ['sometimes', 'required', 'integer', 'exists:categories,id'],
            'name' => ['sometimes', 'required', 'string', 'max:180'],
            'slug' => ['sometimes', 'required', 'string', 'max:200', 'alpha_dash', Rule::unique('products', 'slug')->ignore($productId)],
            'description' => ['sometimes', 'nullable', 'string'],
            'price' => ['sometimes', 'required', 'numeric', 'decimal:0,2', 'min:0'],
            'image' => ['sometimes', 'nullable', 'url', 'max:2048'],
            'stock_quantity' => ['sometimes', 'nullable', 'integer', 'min:0'],
            'is_available' => ['sometimes', 'boolean'],
            'is_active' => ['sometimes', 'boolean'],
            'dietary' => ['sometimes', 'nullable', 'string', 'max:40'],
            'tags' => ['sometimes', 'nullable', 'array', 'max:30'],
            'tags.*' => ['string', 'max:60'],
        ];
    }
}
