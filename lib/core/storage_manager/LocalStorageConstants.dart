import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';

class LocalStorage {
  static final GetStorage _box = GetStorage();

  // ================= AUTH TOKENS =================

  static void saveTokens(String access, String refresh) {
    _box.write(LocalStorageConstants.access, access);
    _box.write(LocalStorageConstants.refresh, refresh);
  }

  static String? getAccessToken() {
    return _box.read(LocalStorageConstants.access);
  }

  static String? getRefreshToken() {
    return _box.read(LocalStorageConstants.refresh);
  }

  static bool hasTokens() {
    return getAccessToken() != null && getRefreshToken() != null;
  }

  static void clearTokens() {
    _box.remove(LocalStorageConstants.access);
    _box.remove(LocalStorageConstants.refresh);
  }

  // ================= USER DATA (OPTIONAL) =================

  static void saveUserId(int id) {
    _box.write(LocalStorageConstants.userId, id);
  }

  static int? getUserId() {
    return _box.read(LocalStorageConstants.userId);
  }

  static void clearUserData() {
    _box.remove(LocalStorageConstants.userId);
    _box.remove(LocalStorageConstants.username);
    _box.remove(LocalStorageConstants.userEmail);
    _box.remove(LocalStorageConstants.mobile);
  }

  // ================= FULL LOGOUT =================

  static void clearAll() {
    clearTokens();
    clearUserData();
  }
}
