<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\Auth\GoogleCredentialVerifier;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class AuthController extends Controller
{
    public function create(): View
    {
        return view('admin.auth.login');
    }

    public function store(Request $request, GoogleCredentialVerifier $verifier): RedirectResponse
    {
        $validated = $request->validate([
            'credential' => ['required', 'string', 'max:8192'],
        ]);

        try {
            $identity = $verifier->verify($validated['credential']);
        } catch (RuntimeException) {
            Log::warning('Admin Google credential verification failed.', [
                'route' => $request->route()?->getName(),
            ]);

            return back()
                ->withErrors(['credential' => 'The Google credential could not be verified.'])
                ->withInput($request->except('credential'));
        }

        $user = User::where('google_subject', $identity['sub'])->first();

        if ($user === null || ! $user->is_active || ! $user->hasRole(User::ROLE_ADMIN)) {
            return back()
                ->withErrors(['credential' => 'This account is not authorized for the admin dashboard.'])
                ->withInput($request->except('credential'));
        }

        Auth::guard('web')->login($user);
        $request->session()->regenerate();

        return redirect()->intended(route('admin.dashboard'));
    }

    public function destroy(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }
}
