<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AssignOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->hasRole('ADMIN') === true;
    }

    public function rules(): array
    {
        return [
            'delivery_partner_id' => ['required', 'integer', 'exists:delivery_partner_users,id'],
        ];
    }
}
