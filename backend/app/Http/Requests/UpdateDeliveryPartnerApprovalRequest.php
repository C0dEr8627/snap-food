<?php

namespace App\Http\Requests;

use App\Models\AdminUser;
use Illuminate\Foundation\Http\FormRequest;

class UpdateDeliveryPartnerApprovalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->is_active === true
            && $this->user() instanceof AdminUser;
    }

    public function rules(): array
    {
        return [
            'approved' => ['required', 'boolean'],
        ];
    }
}
