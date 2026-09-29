<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Snap Foodd Admin — Sign in</title>
</head>
<body>
    <main>
        <h1>Snap Foodd Admin</h1>
        <p>Sign in with an approved Google account.</p>

        @if ($errors->any())
            <div role="alert">
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form method="POST" action="{{ route('admin.login.store') }}" id="admin-login-form">
            @csrf
            <label for="credential">Google ID token</label>
            <input id="credential" name="credential" type="password" autocomplete="off" required>
            <button type="submit">Sign in</button>
        </form>

        <p>For the production web login, configure Google Identity Services and submit its ID-token credential to this endpoint.</p>
    </main>
</body>
</html>
