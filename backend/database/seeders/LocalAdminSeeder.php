<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class LocalAdminSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment('local')) {
            return;
        }

        $email = env('ADMIN_BOOTSTRAP_EMAIL');

        if (! is_string($email) || $email === '') {
            return;
        }

        User::updateOrCreate(
            ['email' => $email],
            [
                'name' => 'Local Admin',
                'role' => User::ROLE_ADMIN,
                'is_active' => true,
            ],
        );
    }
}
