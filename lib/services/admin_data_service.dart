import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AdminDataService {
  AdminDataService._();

  static const String _usersKey = 'admin_managed_users';
  static final List<String> kelas = ['RPL', 'TKJ'];

  static final List<UserModel> _users = [
    const UserModel(name: 'Admin PKL', username: 'admin', role: 'admin'),
    const UserModel(name: 'Bapak/Ibu Guru', username: 'guru', role: 'guru'),
    const UserModel(name: 'Siswa PKL', username: 'siswa', role: 'siswa'),
    const UserModel(
      name: 'Siswa RPL 1',
      username: 'siswa.rpl1',
      role: 'siswa',
      className: 'RPL',
    ),
    const UserModel(
      name: 'Siswa RPL 2',
      username: 'siswa.rpl2',
      role: 'siswa',
      className: 'RPL',
    ),
    const UserModel(
      name: 'Siswa TKJ 1',
      username: 'siswa.tkj1',
      role: 'siswa',
      className: 'TKJ',
    ),
    const UserModel(
      name: 'Siswa TKJ 2',
      username: 'siswa.tkj2',
      role: 'siswa',
      className: 'TKJ',
    ),
  ];

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedUsers = preferences.getString(_usersKey);
    if (savedUsers == null) return;

    try {
      final decoded = jsonDecode(savedUsers) as List<dynamic>;
      final users = decoded
          .map((value) => UserModel.fromJson(value as Map<String, dynamic>))
          .toList();
      _users
        ..clear()
        ..addAll(users);
    } on FormatException {
      await preferences.remove(_usersKey);
    } on TypeError {
      await preferences.remove(_usersKey);
    }
  }

  static List<UserModel> get users => List.unmodifiable(_users);

  static List<UserModel> get students =>
      _users.where((user) => user.role == 'siswa').toList(growable: false);

  static Future<void> addUser(UserModel user) async {
    _users.add(user);
    await _saveUsers();
  }

  static Future<void> updateUser(int index, UserModel user) async {
    _users[index] = user;
    await _saveUsers();
  }

  static Future<void> removeUser(int index) async {
    _users.removeAt(index);
    await _saveUsers();
  }

  static Future<void> _saveUsers() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _usersKey,
      jsonEncode(_users.map((user) => user.toJson()).toList()),
    );
    if (!saved) throw StateError('Daftar user gagal disimpan.');
  }

  static void addClass(String name) => kelas.add(name);

  static void updateClass(int index, String name) => kelas[index] = name;

  static void removeClass(int index) => kelas.removeAt(index);

  static String? classForStudent(String studentName) {
    for (final user in students) {
      if (user.name == studentName) return user.className;
    }
    return null;
  }
}
