<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        return [
            'google_subject' => 'factory-' . $this->faker->unique()->uuid(),
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'role' => User::ROLE_CUSTOMER,
            'is_active' => true,
        ];
    }

    public function admin(): static
    {
        return $this->state(fn (): array => [
            'role' => User::ROLE_ADMIN,
        ]);
    }

    public function deliveryPartner(): static
    {
        return $this->state(fn (): array => [
            'role' => User::ROLE_DELIVERY_PARTNER,
        ]);
    }
}
