<?php

namespace App\Exceptions;

use RuntimeException;

class OrderStateConflictException extends RuntimeException
{
    public function __construct(string $message = 'The order state has changed or does not allow the requested transition.')
    {
        parent::__construct($message);
    }
}
