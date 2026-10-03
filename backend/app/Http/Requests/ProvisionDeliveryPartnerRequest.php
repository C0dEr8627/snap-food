<?php

namespace App\Http\Requests;

use App\Models\AdminUser;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ProvisionDeliveryPartnerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->is_active === true
            && $this->user() instanceof AdminUser;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:150'],
            'email' => ['required', 'email', 'max:255', Rule::unique('delivery_partner_users', 'email')],
            'phone' => ['nullable', 'regex:/^\+91[6-9][0-9]{9}$/', Rule::unique('delivery_partner_users', 'phone')],
            'password' => ['required', 'string', 'min:8', 'max:255', 'confirmed'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'name' => trim((string) $this->input('name')),
            'email' => strtolower(trim((string) $this->input('email'))),
            'phone' => $this->filled('phone') ? trim((string) $this->input('phone')) : null,
        ]);
    }
}
