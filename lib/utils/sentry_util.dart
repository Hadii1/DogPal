//Sentry is an error reporting platforms where we send uncought errors to the console and even some specific handled error to get a feel of what's happening

import 'package:dog_pal/utils/app_secrets.dart';
import 'package:sentry/sentry.dart';

final SentryClient sentry = SentryClient(
  dsn: SENTRY_DSN,
);

Future<void> reportError(dynamic error, dynamic stackTrace) async {
  // Print the exception to the console.
  print('Caught error: $error');

  // Send the Exception and Stacktrace to Sentry in Production mode.

  if (_isInDebugMode) {
    print(stackTrace);
  } else {
    try {
      sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    } catch (_) {}
  }
}

bool get _isInDebugMode {
  // Assume we're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);

  return inDebugMode;
}
