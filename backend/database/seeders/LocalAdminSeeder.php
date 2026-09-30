<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class LocalAdminSeeder extends Seeder
{
    public function run(): void
    {
        if (! app()->environment('local')) {
            return;
        }

        $email = env('ADMIN_BOOTSTRAP_EMAIL');
        $password = env('ADMIN_BOOTSTRAP_PASSWORD');

        if (! is_string($email) || $email === '' || ! is_string($password) || $password === '') {
            return;
        }

        User::updateOrCreate(
            ['email' => $email],
            [
                'name' => 'Local Admin',
                'role' => User::ROLE_ADMIN,
                'is_active' => true,
                'password' => Hash::make($password),
            ],
        );
    }
}
