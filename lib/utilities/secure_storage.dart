import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> writeData(String value) async {
    await _storage.write(key: 'token', value: value);
  }

  static Future<String?> readData() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> deleteData() async {
    await _storage.delete(key: 'token');
  }
}