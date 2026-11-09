import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'admin_data_service.dart';
import 'nama_profil_akun_service.dart';
import 'nama_profil_siswa_service.dart';

class AkunLokalService {
  AkunLokalService._();

  static const String _keyAkun = 'akun_lokal';
  static const int _hashIterations = 120000;
  static const Set<String> _accountRoles = {'admin', 'guru', 'siswa'};
  static const Set<String> _registrationRoles = {'guru', 'siswa'};

  static Future<void> daftar({
    required String nama,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final trimmedName = nama.trim();
    final trimmedUsername = username.trim();
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) throw ArgumentError('Nama wajib diisi.');
    if (trimmedUsername.isEmpty || trimmedUsername.contains(RegExp(r'\s'))) {
      throw ArgumentError('Username tidak valid.');
    }
    if (!_isValidEmail(trimmedEmail)) {
      throw ArgumentError('Format email tidak valid.');
    }
    if (password.length < 6) {
      throw ArgumentError('Password minimal 6 karakter.');
    }
    if (!_registrationRoles.contains(role)) {
      throw ArgumentError.value(role, 'role', 'Role tidak didukung.');
    }

    final preferences = await SharedPreferences.getInstance();
    final accounts = await _loadAccounts(preferences);
    final usernames = <String>{
      'siswa',
      'guru',
      'admin',
      NamaProfilSiswaService.username.value.toLowerCase(),
      NamaProfilAkunService.usernameGuru.value.toLowerCase(),
      NamaProfilAkunService.usernameAdmin.value.toLowerCase(),
      ...AdminDataService.users.map((user) => user.username.toLowerCase()),
      ...accounts.map((account) => account.user.username.toLowerCase()),
    };
    if (usernames.contains(trimmedUsername.toLowerCase())) {
      throw ArgumentError('Username sudah digunakan.');
    }
    if (accounts.any((account) => account.email == trimmedEmail)) {
      throw ArgumentError('Email sudah digunakan.');
    }

    final salt = _newSalt();
    final passwordHash = await _hashPassword(password, salt);

    accounts.add(
      _LocalAccount(
        user: UserModel(
          name: trimmedName,
          username: trimmedUsername,
          role: role,
        ),
        email: trimmedEmail,
        passwordSalt: base64Encode(salt),
        passwordHash: base64Encode(passwordHash),
      ),
    );
    await _saveAccounts(preferences, accounts);
  }

  static Future<UserModel?> autentikasi({
    required String username,
    required String password,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final accounts = await _loadAccounts(preferences);
    for (final account in accounts) {
      if (account.user.username.toLowerCase() ==
              username.trim().toLowerCase() &&
          await _matchesPassword(
            password,
            account.passwordSalt,
            account.passwordHash,
          )) {
        return account.user;
      }
    }
    return null;
  }

  static bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  static List<int> _newSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  static Future<List<int>> _hashPassword(
    String password,
    List<int> salt,
  ) async {
    final derivation = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _hashIterations,
      bits: 256,
    );
    final key = await derivation.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  static Future<bool> _matchesPassword(
    String password,
    String encodedSalt,
    String encodedHash,
  ) async {
    final salt = base64Decode(encodedSalt);
    final expectedHash = base64Decode(encodedHash);
    final actualHash = await _hashPassword(password, salt);
    if (actualHash.length != expectedHash.length) return false;

    var difference = 0;
    for (var index = 0; index < actualHash.length; index++) {
      difference |= actualHash[index] ^ expectedHash[index];
    }
    return difference == 0;
  }

  static Future<List<_LocalAccount>> _loadAccounts(
    SharedPreferences preferences,
  ) async {
    final encodedAccounts = preferences.getString(_keyAkun);
    if (encodedAccounts == null) return [];

    final decoded = jsonDecode(encodedAccounts);
    if (decoded is! List) {
      throw const FormatException('Data akun lokal tidak valid.');
    }
    var migratedLegacyAccounts = false;
    final accounts = await Future.wait(
      decoded.map((entry) async {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Data akun lokal tidak valid.');
        }
        final name = entry['name'];
        final username = entry['username'];
        final role = entry['role'];
        final email = entry['email'];
        final passwordSalt = entry['passwordSalt'];
        final passwordHash = entry['passwordHash'];
        final legacyPassword = entry['password'];
        if (name is! String || username is! String || role is! String) {
          throw const FormatException('Data akun lokal tidak valid.');
        }
        if (!_accountRoles.contains(role)) {
          throw const FormatException(
            'Data akun lokal memiliki role tidak valid.',
          );
        }
        if (email != null && email is! String) {
          throw const FormatException('Data email akun lokal tidak valid.');
        }

        final List<int> salt;
        final List<int> hash;
        if (passwordSalt is String && passwordHash is String) {
          salt = base64Decode(passwordSalt);
          hash = base64Decode(passwordHash);
        } else if (legacyPassword is String) {
          salt = _newSalt();
          hash = await _hashPassword(legacyPassword, salt);
          migratedLegacyAccounts = true;
        } else {
          throw const FormatException('Password akun lokal tidak valid.');
        }
        return _LocalAccount(
          user: UserModel(name: name, username: username, role: role),
          email: (email as String? ?? '').toLowerCase(),
          passwordSalt: base64Encode(salt),
          passwordHash: base64Encode(hash),
        );
      }),
    );
    if (migratedLegacyAccounts) {
      await _saveAccounts(preferences, accounts);
    }
    return accounts;
  }

  static Future<void> _saveAccounts(
    SharedPreferences preferences,
    List<_LocalAccount> accounts,
  ) async {
    final saved = await preferences.setString(
      _keyAkun,
      jsonEncode(
        accounts
            .map(
              (account) => {
                ...account.user.toJson(),
                'email': account.email,
                'passwordSalt': account.passwordSalt,
                'passwordHash': account.passwordHash,
              },
            )
            .toList(),
      ),
    );
    if (!saved) throw StateError('Akun gagal disimpan.');
  }
}

class _LocalAccount {
  const _LocalAccount({
    required this.user,
    required this.email,
    required this.passwordSalt,
    required this.passwordHash,
  });

  final UserModel user;
  final String email;
  final String passwordSalt;
  final String passwordHash;
}
