import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true));

  static Future<void> saveData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  static Future<String?> readData(String key) async {
    return await storage.read(key: key);
  }

  static Future<Map<String, String>> readAllData(String key) async {
    return await storage.readAll();
  }

  static Future<bool> containsData(String key) async {
    return await storage.containsKey(key: key);
  }

  static Future<void> deleteData(String key) async {
    await storage.delete(key: key);
  }

  static Future<void> deleteAllData() async {
    await storage.deleteAll();
  }
}
