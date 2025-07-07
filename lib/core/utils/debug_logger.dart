import 'package:flutter/foundation.dart';

/// Debug logging utility for development
class DebugLogger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logTag = tag ?? 'DEBUG';
      // ignore: avoid_print
      print('[$timestamp] [$logTag] $message');
    }
  }

  static void info(String message, {String? tag}) {
    log('ℹ️ $message', tag: tag ?? 'INFO');
  }

  static void success(String message, {String? tag}) {
    log('✅ $message', tag: tag ?? 'SUCCESS');
  }

  static void warning(String message, {String? tag}) {
    log('⚠️ $message', tag: tag ?? 'WARNING');
  }

  static void error(String message, {String? tag}) {
    log('❌ $message', tag: tag ?? 'ERROR');
  }
}
