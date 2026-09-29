<?php

namespace App\Services\Auth;

use Google\Client as GoogleClient;
use RuntimeException;

class GoogleCredentialVerifier
{
    public function verify(string $credential): array
    {
        $clientId = config('services.google.client_id');

        if (! is_string($clientId) || $clientId === '') {
            throw new RuntimeException('Google OAuth client ID is not configured.');
        }

        $client = new GoogleClient;
        $client->setClientId($clientId);

        $payload = $client->verifyIdToken($credential);

        if (! is_array($payload)) {
            throw new RuntimeException('Invalid Google credential.');
        }

        $subject = $payload['sub'] ?? null;
        $name = $payload['name'] ?? null;
        $email = $payload['email'] ?? null;

        if (! is_string($subject) || $subject === '' || ! is_string($name) || $name === '') {
            throw new RuntimeException('Google credential is missing required identity claims.');
        }

        return [
            'sub' => $subject,
            'name' => $name,
            'email' => is_string($email) && $email !== '' ? $email : null,
        ];
    }
}
