<?php

namespace App\Http\Requests;

use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateOrderStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->is_active === true
            && $this->user()->hasRole(User::ROLE_ADMIN);
    }

    public function rules(): array
    {
        return [
            'status' => ['required', 'string', Rule::in([
                'ACCEPTED', 'PREPARING', 'READY_FOR_PICKUP', 'ASSIGNED',
                'PICKED_UP', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED',
            ])],
        ];
    }
}
