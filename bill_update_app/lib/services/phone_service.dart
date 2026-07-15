import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class PhoneService {
  static const _channel = MethodChannel('com.example.bill_update_app/device');

  static Future<void> getAndSavePhoneNumber() async {
    try {
      final number = await _channel.invokeMethod<String>('getPhoneHint');
      if (number == null || number.isEmpty) return;

      final deviceId = await _channel.invokeMethod<String>('getDeviceId');
      await http.post(
        Uri.parse('$apiBaseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'phone_number': number,
        }),
      );
    } catch (_) {}
  }
}
