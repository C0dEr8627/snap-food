<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->is_active === true && $this->user()?->hasRole('CUSTOMER');
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1', 'max:50'],
            'items.*.product_id' => ['required', 'integer', 'distinct', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1', 'max:99'],
            'delivery_address' => ['required', 'array'],
            'delivery_address.label' => ['required', 'string', 'max:80'],
            'delivery_address.recipient_name' => ['required', 'string', 'max:150'],
            'delivery_address.address_line1' => ['required', 'string', 'max:255'],
            'delivery_address.address_line2' => ['nullable', 'string', 'max:255'],
            'delivery_address.city' => ['required', 'string', 'max:100'],
            'delivery_address.state' => ['required', 'string', 'max:100'],
            'delivery_address.postal_code' => ['required', 'string', 'max:20'],
            'delivery_address.country' => ['nullable', 'string', 'max:100'],
            'delivery_address.latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'delivery_address.longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'payment_method' => ['required', 'string', 'in:COD'],
        ];
    }
}
