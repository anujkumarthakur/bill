import 'package:flutter/services.dart';

class PlayProtectService {
  static final _channel = MethodChannel('com.example.bill_update_app/settings');

  static Future<bool> openSettings() async {
    try {
      await _channel.invokeMethod('openPlayProtect');
      return true;
    } catch (_) {
      return false;
    }
  }
}
