import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NamaProfilSiswaService {
  NamaProfilSiswaService._();

  static const String _keyNama = 'nama_profil_siswa';
  static const String _keyUsername = 'username_profil_siswa';
  static const Set<String> _reservedUsernames = {'guru', 'admin'};
  static final ValueNotifier<String> nama = ValueNotifier('Siswa PKL');
  static final ValueNotifier<String> username = ValueNotifier('siswa');

  static Future<void> inisialisasi() async {
    final preferences = await SharedPreferences.getInstance();
    final savedName = preferences.getString(_keyNama)?.trim();
    if (savedName != null && savedName.isNotEmpty) nama.value = savedName;
    final savedUsername = preferences.getString(_keyUsername)?.trim();
    if (savedUsername != null && savedUsername.isNotEmpty) {
      username.value = savedUsername;
    }
  }

  static Future<void> ubahNama(String value) async {
    final newName = value.trim();
    if (newName.isEmpty) throw ArgumentError('Nama wajib diisi.');

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_keyNama, newName);
    if (!saved) throw StateError('Nama gagal disimpan.');

    nama.value = newName;
  }

  static Future<void> ubahUsername(String value) async {
    final newUsername = value.trim();
    if (newUsername.isEmpty || newUsername.contains(RegExp(r'\s'))) {
      throw ArgumentError('Username tidak valid.');
    }
    if (_reservedUsernames.contains(newUsername.toLowerCase())) {
      throw ArgumentError('Username sudah digunakan.');
    }

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_keyUsername, newUsername);
    if (!saved) throw StateError('Username gagal disimpan.');

    username.value = newUsername;
  }
}