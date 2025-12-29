import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:async';

// 1. Define the external JavaScript function/method on the global 'window' object.
@JS()
external void triggerGoogleSignIn();

class WebGoogleSignIn {
  static Future<void> signIn() async {
    // Get the global window object from package:web
    final window = web.window;

    // Create a completer to handle the async result
    final completer = Completer<void>();

    // Dart functions passed to JS must be static/top-level or use Function.toJS
    // and correctly define the signature for JS interop.

    // Define the event listener using Function.toJS.
    final listener = ((web.Event event) {
      // FIX: Use 'isA' from dart:js_interop for reliable type checking of JS objects.
      if (event.isA<web.CustomEvent>()) {
        // Safely cast to the CustomEvent type
        final customEvent = event as web.CustomEvent;

        if (customEvent.type == 'gis-signed-in') {
          completer.complete();
        } else if (customEvent.type == 'gis-error') {
          // You might get the error details from event.detail
          // Note: .dartify() is correct for converting JS types to Dart.
          final errorDetail = customEvent.detail.dartify() as String?;
          completer.completeError(
            'Google Sign In failed: ${errorDetail ?? 'Unknown error'}',
          );
        }
      }
    }).toJS; // Convert the Dart function to a callable JSFunction

    // Add event listeners for our custom events
    window.addEventListener('gis-signed-in', listener);
    window.addEventListener('gis-error', listener);

    // 2. Directly call the external function
    triggerGoogleSignIn();

    try {
      await completer.future;
    } finally {
      // Clean up event listeners
      window.removeEventListener('gis-signed-in', listener);
      window.removeEventListener('gis-error', listener);
    }
  }
}
