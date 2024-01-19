import 'package:voter_app/storage/mobile_storage_service.dart'
    if (dart.library.html) 'package:voter_app/storage/web_storage_service.dart'
    as storage;
import 'storage_service.dart';

class StorageServiceFactory {
  static StorageService create() {
    return storage.ImplementStorageService();
  }
}
