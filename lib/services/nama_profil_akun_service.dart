import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NamaProfilAkunService {
  NamaProfilAkunService._();

  static const String _guruKey = 'nama_profil_guru';
  static const String _adminKey = 'nama_profil_admin';
  static const String _guruUsernameKey = 'username_profil_guru';
  static const String _adminUsernameKey = 'username_profil_admin';
  static final ValueNotifier<String> namaGuru = ValueNotifier('Bapak/Ibu Guru');
  static final ValueNotifier<String> namaAdmin = ValueNotifier('Admin PKL');
  static final ValueNotifier<String> usernameGuru = ValueNotifier('guru');
  static final ValueNotifier<String> usernameAdmin = ValueNotifier('admin');

  static ValueNotifier<String> untukRole(String role) => switch (role) {
    'guru' => namaGuru,
    'admin' => namaAdmin,
    _ => throw ArgumentError.value(role, 'role', 'Role tidak didukung.'),
  };

  static ValueNotifier<String> usernameUntukRole(String role) => switch (role) {
    'guru' => usernameGuru,
    'admin' => usernameAdmin,
    _ => throw ArgumentError.value(role, 'role', 'Role tidak didukung.'),
  };

  static Future<void> inisialisasi() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTeacherName = preferences.getString(_guruKey)?.trim();
    final savedAdminName = preferences.getString(_adminKey)?.trim();
    final savedTeacherUsername = preferences
      .getString(_guruUsernameKey)
      ?.trim();
    final savedAdminUsername = preferences.getString(_adminUsernameKey)?.trim();
    if (savedTeacherName != null && savedTeacherName.isNotEmpty) {
      namaGuru.value = savedTeacherName;
    }
    if (savedAdminName != null && savedAdminName.isNotEmpty) {
      namaAdmin.value = savedAdminName;
    }
    if (savedTeacherUsername != null && savedTeacherUsername.isNotEmpty) {
      usernameGuru.value = savedTeacherUsername;
    }
    if (savedAdminUsername != null && savedAdminUsername.isNotEmpty) {
      usernameAdmin.value = savedAdminUsername;
    }
  }

  static Future<void> ubahNama(String role, String value) async {
    final newName = value.trim();
    if (newName.isEmpty) throw ArgumentError('Nama wajib diisi.');

    final key = switch (role) {
      'guru' => _guruKey,
      'admin' => _adminKey,
      _ => throw ArgumentError.value(role, 'role', 'Role tidak didukung.'),
    };
    final saved = await (await SharedPreferences.getInstance()).setString(
      key,
      newName,
    );
    if (!saved) throw StateError('Nama gagal disimpan.');

    untukRole(role).value = newName;
  }

  static Future<void> ubahUsername(String role, String value) async {
    final newUsername = value.trim();
    if (newUsername.isEmpty || newUsername.contains(RegExp(r'\s'))) {
      throw ArgumentError('Username tidak valid.');
    }

    final preferences = await SharedPreferences.getInstance();
    final studentUsername =
        preferences.getString('username_profil_siswa')?.trim() ?? 'siswa';
    final otherUsernames = <String>{
      studentUsername.toLowerCase(),
      if (role != 'guru') usernameGuru.value.toLowerCase(),
      if (role != 'admin') usernameAdmin.value.toLowerCase(),
    };
    if (otherUsernames.contains(newUsername.toLowerCase())) {
      throw ArgumentError('Username sudah digunakan.');
    }

    final key = switch (role) {
      'guru' => _guruUsernameKey,
      'admin' => _adminUsernameKey,
      _ => throw ArgumentError.value(role, 'role', 'Role tidak didukung.'),
    };
    final saved = await preferences.setString(key, newUsername);
    if (!saved) throw StateError('Username gagal disimpan.');

    usernameUntukRole(role).value = newUsername;
  }
}