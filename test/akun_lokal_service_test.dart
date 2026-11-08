import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/services/akun_lokal_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('akun guru dan siswa bisa didaftarkan dan dipakai masuk', () async {
    for (final role in ['guru', 'siswa']) {
      final username = 'akun.$role';
      final email = 'akun.$role@example.com';
      await AkunLokalService.daftar(
        nama: 'Pengguna ${role.toUpperCase()}',
        username: username,
        email: email,
        password: 'rahasia123',
        role: role,
      );

      final user = await AkunLokalService.autentikasi(
        username: username,
        password: 'rahasia123',
      );
      expect(user?.role, role);
      expect(user?.name, 'Pengguna ${role.toUpperCase()}');
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('akun_lokal'),
        isNot(contains('rahasia123')),
      );
      expect(
        await AkunLokalService.autentikasi(
          username: username,
          password: 'password-salah',
        ),
        isNull,
      );
    }
  });

  test('username tidak boleh dipakai ulang tanpa membedakan kapital', () async {
    await AkunLokalService.daftar(
      nama: 'Pengguna Baru',
      username: 'pengguna.baru',
      email: 'baru@example.com',
      password: 'rahasia123',
      role: 'siswa',
    );

    await expectLater(
      AkunLokalService.daftar(
        nama: 'Pengguna Lain',
        username: 'PENGGUNA.BARU',
        email: 'lain@example.com',
        password: 'rahasia123',
        role: 'guru',
      ),
      throwsArgumentError,
    );
  });

  test('email tidak boleh dipakai ulang tanpa membedakan kapital', () async {
    await AkunLokalService.daftar(
      nama: 'Pengguna Pertama',
      username: 'pengguna.pertama',
      email: 'sama@example.com',
      password: 'rahasia123',
      role: 'siswa',
    );

    await expectLater(
      AkunLokalService.daftar(
        nama: 'Pengguna Kedua',
        username: 'pengguna.kedua',
        email: 'SAMA@example.com',
        password: 'rahasia123',
        role: 'guru',
      ),
      throwsArgumentError,
    );
  });

  test('akun lama bermigrasi dari password polos ke hash saat login', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'akun_lokal',
      jsonEncode([
        {
          'name': 'Akun Lama',
          'username': 'akun.lama',
          'role': 'siswa',
          'password': 'password-lama',
        },
      ]),
    );

    final user = await AkunLokalService.autentikasi(
      username: 'akun.lama',
      password: 'password-lama',
    );

    expect(user?.name, 'Akun Lama');
    expect(
      preferences.getString('akun_lokal'),
      isNot(contains('password-lama')),
    );
    expect(
      await AkunLokalService.autentikasi(
        username: 'akun.lama',
        password: 'password-salah',
      ),
      isNull,
    );
  });

  testWidgets('daftar akun berhasil lalu bisa login sebagai guru', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Belum punya akun? Daftar di sini'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(find.text('Daftar sebagai'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Guru'), findsOneWidget);
    expect(find.text('Siswa'), findsWidgets);

    await tester.tap(find.text('Guru'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Guru Baru');
    await tester.enterText(find.byType(TextField).at(1), 'guru.baru');
    await tester.enterText(find.byType(TextField).at(2), 'guru@example.com');
    await tester.enterText(find.byType(TextField).at(3), 'rahasia123');
    await tester.enterText(find.byType(TextField).at(4), 'rahasia123');
    await tester.ensureVisible(find.text('DAFTAR'));
    await tester.tap(find.text('DAFTAR'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.textContaining('Pendaftaran berhasil'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'guru.baru');
    await tester.enterText(find.byType(TextField).at(1), 'rahasia123');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Guru Baru!'), findsOneWidget);
  });
}
