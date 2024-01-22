import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voter_app/storage/storage_service.dart';

class ImplementStorageService implements StorageService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => secureStorage.read(key: key);

  @override
  Future<void> write(String key, String value) => secureStorage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => secureStorage.delete(key: key);
}

