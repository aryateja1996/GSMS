import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, critical }

/// Structured logging — never log secrets or payment credentials.
abstract final class AppLogger {
  static LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void debug(String message, {String? tag}) =>
      _log(LogLevel.debug, message, tag: tag);

  static void info(String message, {String? tag}) =>
      _log(LogLevel.info, message, tag: tag);

  static void warning(String message, {String? tag}) =>
      _log(LogLevel.warning, message, tag: tag);

  static void error(String message, {Object? error, String? tag}) {
    _log(LogLevel.error, message, tag: tag, error: error);
  }

  static void critical(String message, {Object? error, String? tag}) {
    _log(LogLevel.error, message, tag: tag, error: error);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
  }) {
    if (level.index < minLevel.index) return;
    final prefix = tag != null ? '[$tag] ' : '';
    final line = '${level.name.toUpperCase()}: $prefix$message';
    if (level.index >= LogLevel.error.index) {
      debugPrint(line);
      if (error != null) debugPrint(error.toString());
    } else {
      debugPrint(line);
    }
  }
}
