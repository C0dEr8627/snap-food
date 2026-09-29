<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminWebUser
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user('web');

        if ($user === null) {
            return redirect()->route('admin.login');
        }

        if (! $user->is_active) {
            $request->session()->invalidate();

            return redirect()->route('admin.login')->withErrors([
                'credential' => 'This admin account is inactive.',
            ]);
        }

        if (! $user->hasRole('ADMIN')) {
            abort(403);
        }

        return $next($request);
    }
}
