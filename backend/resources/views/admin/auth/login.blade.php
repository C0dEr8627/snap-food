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
            <input id="credential" name="credential" type="hidden">
            <div id="google-sign-in"></div>
        </form>

        <noscript>
            <p>JavaScript is required for Google sign-in.</p>
        </noscript>
    </main>

    <script src="https://accounts.google.com/gsi/client" async defer></script>
    <script>
        window.onload = function () {
            const signIn = document.getElementById('google-sign-in');
            const form = document.getElementById('admin-login-form');
            const credential = document.getElementById('credential');

            if (!signIn || !form || !credential) {
                return;
            }

            const clientId = @json(config('services.google.client_id'));

            if (!clientId) {
                signIn.textContent = 'Google sign-in is not configured.';
                return;
            }

            const initializeGoogleSignIn = function () {
                if (!window.google || !window.google.accounts || !window.google.accounts.id) {
                    return;
                }

                window.google.accounts.id.initialize({
                    client_id: clientId,
                    callback: function (response) {
                        credential.value = response.credential;
                        form.submit();
                    },
                });

                window.google.accounts.id.renderButton(signIn, {
                    type: 'standard',
                    theme: 'outline',
                    size: 'large',
                    text: 'signin_with',
                });
            };

            if (window.google && window.google.accounts && window.google.accounts.id) {
                initializeGoogleSignIn();
            } else {
                const interval = window.setInterval(function () {
                    if (window.google && window.google.accounts && window.google.accounts.id) {
                        window.clearInterval(interval);
                        initializeGoogleSignIn();
                    }
                }, 100);
            }
        };
    </script>
</body>
</html>
