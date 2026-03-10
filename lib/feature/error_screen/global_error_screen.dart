import 'package:ascend/core/constants/constants.dart';
import 'package:ascend/core/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class GlobalErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const GlobalErrorScreen({super.key, required this.errorDetails});

  void _logToBackend() {
    AnalyticsService.logError(
      errorDetails.exceptionAsString(),
      errorDetails.stack?.toString() ?? 'No stack trace',
    );
  }

  Future<void> _reportError() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppConstants.email,
      queryParameters: {
        'subject': 'App Bug Report',
        'body':
            'App encountered a fatal error:\n\n'
            'Exception: ${errorDetails.exceptionAsString()}\n'
            'StackTrace:\n${errorDetails.stack}\n',
      },
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      debugPrint('Could not launch email target.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Log silently in the background when the screen is shown
    _logToBackend();

    // We return a completely separated MaterialApp here so that the Error Screen
    // looks correct even if the inherited Theme or Directionality is broken by the crash!
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(
          0xFF1E1E1E,
        ), // Dark safe fallback background
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 96,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oh snap! Something broke.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'An unexpected error occurred. Please report this to help us fix the issue, or try relaunching the application.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _reportError,
                        icon: const Icon(
                          Icons.mail_outline_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Report Error',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Trigger the global restart routine at the root level!
                          Phoenix.rebirth(context);
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Relaunch App',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
