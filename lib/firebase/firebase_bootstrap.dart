import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gsma/core/config/env_config.dart';
import 'package:gsma/core/utils/app_logger.dart';
import 'package:gsma/firebase_options.dart';

class FirebaseBootstrapResult {
  FirebaseBootstrapResult({
    required this.initialized,
    this.analytics,
  });

  final bool initialized;
  final FirebaseAnalytics? analytics;
}

Future<FirebaseBootstrapResult> initializeFirebase(EnvConfig env) async {
  if (!env.enableFirebase) {
    AppLogger.warning('Firebase disabled by config', tag: 'Firebase');
    return FirebaseBootstrapResult(initialized: false);
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info(
      'Firebase initialized (${DefaultFirebaseOptions.currentPlatform.projectId})',
      tag: 'Firebase',
    );

    FirebaseAnalytics? analytics;
    if (env.enableAnalytics) {
      analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
    }

    if (env.enableCrashlytics && !kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
    return FirebaseBootstrapResult(
      initialized: true,
      analytics: analytics,
    );
  } on UnsupportedError catch (e) {
    AppLogger.warning(
      'Firebase not configured: ${e.message}. Running local-only.',
      tag: 'Firebase',
    );
    return FirebaseBootstrapResult(initialized: false);
  } catch (e) {
    AppLogger.warning(
      'Firebase init failed: $e. Running local-only.',
      tag: 'Firebase',
    );
    return FirebaseBootstrapResult(initialized: false);
  }
}
