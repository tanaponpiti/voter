import 'dart:html';
import 'package:voter_app/storage/storage_service.dart';
class ImplementStorageService implements StorageService {
  @override
  Future<String?> read(String key) async {
    return window.localStorage[key];
  }

  @override
  Future<void> write(String key, String value) async {
    window.localStorage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    window.localStorage.remove(key);
  }
}

