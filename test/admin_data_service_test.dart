import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/admin/kelola_user.dart';
import 'package:flutter_application_1/services/admin_data_service.dart';

void main() {
  test(
    'user yang ditambahkan tetap tersedia setelah data dimuat ulang',
    () async {
      SharedPreferences.setMockInitialValues({});
      await AdminDataService.initialize();
      const user = UserModel(
        name: 'User Uji',
        username: 'user.uji',
        role: 'siswa',
        className: 'RPL',
      );

      await AdminDataService.addUser(user);
      await AdminDataService.initialize();

      final restoredUser = AdminDataService.users.singleWhere(
        (item) => item.username == user.username,
      );
      expect(restoredUser.name, user.name);
      expect(restoredUser.role, user.role);
      expect(restoredUser.className, user.className);

      final index = AdminDataService.users.indexWhere(
        (item) => item.username == user.username,
      );
      await AdminDataService.removeUser(index);
    },
  );

  testWidgets('form kelola user menambahkan user ke daftar', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await AdminDataService.initialize();
    await tester.pumpWidget(const MaterialApp(home: KelolaUser()));

    await tester.tap(find.text('Tambah User'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Siswa Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'siswa.baru');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pumpAndSettle();

    expect(
      AdminDataService.users.any((user) => user.username == 'siswa.baru'),
      isTrue,
    );
    await tester.scrollUntilVisible(
      find.text('Siswa Baru'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Siswa Baru'), findsOneWidget);
    expect(find.text('@siswa.baru · Siswa · RPL'), findsOneWidget);
  });
}
