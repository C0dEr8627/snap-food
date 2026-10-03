<?php

namespace Database\Factories;

use App\Models\CustomerUser;
use Illuminate\Database\Eloquent\Factories\Factory;

class CustomerUserFactory extends Factory
{
    protected $model = CustomerUser::class;

    public function definition(): array
    {
        return [
            'google_subject' => 'google-customer-'.$this->faker->unique()->uuid(),
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => $this->faker->phoneNumber(),
            'is_active' => true,
        ];
    }
}
