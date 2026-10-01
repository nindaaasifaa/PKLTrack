import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('aplikasi dimulai pada halaman login', (WidgetTester tester) async {
    await tester.pumpWidget(const PKLTrackApp());

    expect(find.text('PKLTrack'), findsOneWidget);
    expect(find.text('Jurnal Kegiatan PKL Siswa'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Halo, Siswa!'), findsNothing);
    expect(find.text('Halo, Guru!'), findsNothing);
  });

  testWidgets('login dengan akun demo membuka dashboard siswa', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'siswa');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Siswa!'), findsOneWidget);
    expect(find.text('Progress Jurnal'), findsOneWidget);
  });

  testWidgets('login dengan password salah menampilkan pesan error', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'siswa');
    await tester.enterText(find.byType(TextField).at(1), 'salah');
    await tester.tap(find.text('LOGIN'));
    await tester.pump();

    expect(find.text('Username atau password salah'), findsOneWidget);
    expect(find.text('Halo, Siswa!'), findsNothing);
  });

  testWidgets('profil siswa dapat logout kembali ke halaman login', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), 'siswa');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Profil Siswa'));
    await tester.pumpAndSettle();
    expect(find.text('Profil Siswa'), findsOneWidget);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Jurnal Kegiatan PKL Siswa'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('login akun guru membuka Dashboard Guru', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsGuru(tester);

    expect(find.text('Halo, Guru!'), findsOneWidget);
    expect(find.text('Jumlah Jurnal Siswa'), findsOneWidget);
    expect(find.text('Progress Pengisian Jurnal'), findsOneWidget);
    expect(find.text('Lihat & Validasi'), findsWidgets);
    expect(find.byTooltip('Profil Guru'), findsOneWidget);
  });

  testWidgets('guru dapat memvalidasi jurnal dan menyimpan komentar', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsGuru(tester);

    final validationButton = find.text('Lihat & Validasi').first;
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(validationButton);
    await tester.pumpAndSettle();

    expect(find.text('Validasi Jurnal'), findsOneWidget);
    expect(find.text('Informasi Siswa'), findsOneWidget);
    expect(find.text('Foto Dokumentasi'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Kegiatan sudah sesuai.');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('approve-journal')));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Guru!'), findsOneWidget);
    expect(find.text('0'), findsWidgets);

    final updatedValidationButton = find.text('Lihat & Validasi').first;
    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(updatedValidationButton);
    await tester.pumpAndSettle();
    expect(find.text('Kegiatan sudah sesuai.'), findsOneWidget);
  });

  testWidgets('profil guru membatalkan atau mengonfirmasi logout', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsGuru(tester);
    await tester.tap(find.byTooltip('Profil Guru'));
    await tester.pumpAndSettle();

    expect(find.text('Bapak/Ibu Guru'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('guru'), findsOneWidget);
    expect(find.text('Role: Guru'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Apakah Anda yakin ingin keluar?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Profil Guru'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Jurnal Kegiatan PKL Siswa'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Halo, Guru!'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Halo, Guru!'), findsNothing);
  });
}

Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const PKLTrackApp());
  await tester.pumpAndSettle();
}

Future<void> _loginAsGuru(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'guru');
  await tester.enterText(find.byType(TextField).at(1), 'guru123');
  await tester.tap(find.text('LOGIN'));
  await tester.pumpAndSettle();
}