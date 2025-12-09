import 'package:flutter/material.dart';
import '../errors/failures.dart';

/// Reusable error widget that displays error messages with optional retry button
class AppErrorWidget extends StatelessWidget {
  /// The error message or Failure object to display
  final dynamic error;
  
  /// Optional callback for retry action
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  /// Extracts user-friendly message from error
  String _getErrorMessage() {
    if (error is Failure) {
      return (error as Failure).userMessage;
    }
    if (error is String) {
      return error;
    }
    return 'An unexpected error occurred.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorMessage(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

