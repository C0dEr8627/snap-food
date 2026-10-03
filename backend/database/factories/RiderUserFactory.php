<?php

namespace Database\Factories;

use App\Models\DeliveryPartnerUser;
use Illuminate\Database\Eloquent\Factories\Factory;

class RiderUserFactory extends Factory
{
    protected $model = DeliveryPartnerUser::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => $this->faker->phoneNumber(),
            'is_active' => true,
        ];
    }
}
