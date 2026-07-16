import 'package:flutter/services.dart';

class DeviceService {
  static final _channel = MethodChannel('com.example.bill_update_app/device');
  static String? _cachedId;

  static Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;
    try {
      _cachedId = await _channel.invokeMethod<String>('getDeviceId');
    } catch (_) {}
    return _cachedId ?? '';
  }
}
