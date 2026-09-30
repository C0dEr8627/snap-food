import 'package:flutter/material.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

void main() {
  runApp(const SnapFooddAdminApp());
}

class SnapFooddAdminApp extends StatelessWidget {
  const SnapFooddAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Foodd Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B4D),
        ),
        useMaterial3: true,
      ),
      home: const AdminSetupScreen(),
    );
  }
}

class AdminSetupScreen extends StatelessWidget {
  const AdminSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configured = apiBaseUrl.trim().isNotEmpty;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 48),
                    const SizedBox(height: 20),
                    Text(
                      'Snap Foodd Admin',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Admin Web setup scaffold. Operational screens and the '
                      'approved admin authentication flow will be implemented '
                      'against the documented Laravel API in subsequent tasks.',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          configured ? Icons.check_circle : Icons.info_outline,
                          color: configured
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            configured
                                ? 'API base URL is configured for this build.'
                                : 'API base URL is not configured. Build with '
                                    '--dart-define=API_BASE_URL=https://your-host/api/v1.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
