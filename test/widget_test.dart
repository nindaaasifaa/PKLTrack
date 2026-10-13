import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/jurnal_model.dart';
import 'package:flutter_application_1/services/foto_profil_siswa_service.dart';
import 'package:flutter_application_1/screens/guru/validasi_jurnal.dart';
import 'package:flutter_application_1/screens/siswa/tambah_jurnal.dart';
import 'package:flutter_application_1/services/jadwal_pkl_service.dart';

void main() {
  test('jadwal pengisian berlaku Senin sampai Jumat', () {
    expect(JadwalPklService.isHariWajib(DateTime(2026, 10, 5)), isTrue);
    expect(JadwalPklService.isHariWajib(DateTime(2026, 10, 9)), isTrue);
    expect(JadwalPklService.isHariWajib(DateTime(2026, 10, 10)), isFalse);
    expect(JadwalPklService.isHariWajib(DateTime(2026, 10, 11)), isFalse);
  });

  test('periode PKL mengikuti tanggal mulai dan batas tiga bulan', () {
    final startDate = DateTime(2027, 1, 15);
    expect(
      JadwalPklService.periodeKe(DateTime(2027, 1, 14), startDate),
      isNull,
    );
    expect(JadwalPklService.periodeKe(DateTime(2027, 1, 15), startDate), 1);
    expect(JadwalPklService.periodeKe(DateTime(2027, 2, 14), startDate), 1);
    expect(JadwalPklService.periodeKe(DateTime(2027, 2, 15), startDate), 2);
    expect(JadwalPklService.periodeKe(DateTime(2027, 3, 15), startDate), 3);
    expect(
      JadwalPklService.periodeKe(DateTime(2027, 4, 15), startDate),
      isNull,
    );
  });

  test('batas periode mengakomodasi akhir bulan dan tahun kabisat', () {
    final januaryEnd = DateTime(2027, 1, 31);
    expect(JadwalPklService.periodeKe(DateTime(2027, 2, 27), januaryEnd), 1);
    expect(JadwalPklService.periodeKe(DateTime(2027, 2, 28), januaryEnd), 2);
    expect(JadwalPklService.periodeKe(DateTime(2027, 3, 30), januaryEnd), 2);
    expect(JadwalPklService.periodeKe(DateTime(2027, 3, 31), januaryEnd), 3);

    final leapYearStart = DateTime(2024, 1, 31);
    expect(JadwalPklService.periodeKe(DateTime(2024, 2, 28), leapYearStart), 1);
    expect(JadwalPklService.periodeKe(DateTime(2024, 2, 29), leapYearStart), 2);
  });

  test('parser membaca tanggal jurnal lama berbahasa Indonesia', () {
    expect(
      JadwalPklService.parseTanggalJurnal('30 September 2026'),
      DateTime(2026, 9, 30),
    );
    expect(
      JadwalPklService.parseTanggalJurnal('2026-09-30'),
      DateTime(2026, 9, 30),
    );
    expect(JadwalPklService.parseTanggalJurnal('31 Februari 2026'), isNull);
  });

  testWidgets('form jurnal memungkinkan siswa memilih kelas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TambahJurnal()));

    final classDropdown = find.byType(DropdownButtonFormField<String>);
    expect(classDropdown, findsOneWidget);
    expect(find.text('Pilih kelas'), findsOneWidget);

    await tester.tap(classDropdown);
    await tester.pumpAndSettle();
    expect(find.text('RPL'), findsOneWidget);
    expect(find.text('TKJ'), findsOneWidget);

    await tester.tap(find.text('TKJ').last);
    await tester.pumpAndSettle();
    expect(find.text('TKJ'), findsOneWidget);
  });

  testWidgets('aplikasi dimulai pada halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PKLTrackApp());

    expect(find.text('PKLTrack'), findsOneWidget);
    expect(find.text('Jurnal Kegiatan PKL Siswa'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Halo, Siswa!'), findsNothing);
    expect(find.text('Halo, Guru!'), findsNothing);
  });

  testWidgets('validasi guru menampilkan foto jurnal dari bytes', (
    WidgetTester tester,
  ) async {
    final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
    final journal = JurnalModel(
      date: '14 Oktober 2026',
      activity: 'Membuat aplikasi sederhana',
      status: 'Pending',
      imagePath: 'blob:foto-dokumentasi',
      imageBytes: imageBytes,
    );

    await tester.pumpWidget(
      MaterialApp(home: ValidasiJurnal(jurnalIndex: 0, jurnal: journal)),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
    expect((image.image as MemoryImage).bytes, same(imageBytes));
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
    expect(find.text('Pengingat Jurnal'), findsOneWidget);
    expect(find.text('Isi Jurnal'), findsNothing);
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
    expect(find.byTooltip('Tambah foto profil'), findsOneWidget);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Apakah Anda yakin ingin keluar?'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Profil Siswa'), findsOneWidget);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Jurnal Kegiatan PKL Siswa'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('foto profil terlihat di dashboard dan halaman profil siswa', (
    WidgetTester tester,
  ) async {
    final photoBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jfS8AAAAASUVORK5CYII=',
    );
    FotoProfilSiswaService.fotoBytes.value = photoBytes;
    addTearDown(() => FotoProfilSiswaService.fotoBytes.value = null);

    await _openLogin(tester);
    await tester.enterText(find.byType(TextField).at(0), 'siswa');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Tambah atau ganti foto profil'), findsOneWidget);
    final dashboardAvatar = tester.widget<CircleAvatar>(
      find.descendant(
        of: find.byTooltip('Profil Siswa'),
        matching: find.byType(CircleAvatar),
      ),
    );
    expect(dashboardAvatar.backgroundImage, isA<MemoryImage>());

    await tester.tap(find.byTooltip('Profil Siswa'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ganti foto profil'), findsOneWidget);
  });

  testWidgets('login akun guru membuka Dashboard Guru', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsGuru(tester);

    expect(find.text('Halo, Guru!'), findsOneWidget);
    expect(find.text('Jumlah Jurnal Siswa'), findsOneWidget);
    expect(find.text('Progress Pengisian Jurnal'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lihat & Validasi'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lihat & Validasi'), findsWidgets);
    expect(find.byTooltip('Profil Guru'), findsOneWidget);
  });

  testWidgets('guru dapat mencari jurnal dengan filter kelas dan status', (
    WidgetTester tester,
  ) async {
    JadwalPklService.tanggalMulaiPkl = DateTime(2026, 9, 28);
    addTearDown(() => JadwalPklService.tanggalMulaiPkl = null);
    await _openLogin(tester);
    await _loginAsGuru(tester);

    final searchField = find.byType(TextField).first;
    final filters = find.byType(DropdownButtonFormField<String>);
    final statusFilter = filters.at(1);
    await tester.scrollUntilVisible(
      find.text('Riwayat Jurnal'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Riwayat Jurnal'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(searchField);
    await tester.enterText(searchField, 'rPl');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Kelas: RPL'), findsWidgets);
    await tester.tap(filters.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('RPL').last);
    await tester.pumpAndSettle();

    await tester.tap(statusFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disetujui').last);
    await tester.pumpAndSettle();

    await tester.tap(filters.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulan ke-1').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.widgetWithText(Card, 'Siswa RPL 2'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.widgetWithText(Card, 'Siswa RPL 2'), findsOneWidget);
    expect(find.text('Kelas: RPL'), findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa RPL 1'), findsNothing);
    expect(find.widgetWithText(Card, 'Siswa TKJ 1'), findsNothing);

    await tester.ensureVisible(filters.last);
    await tester.tap(filters.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulan ke-2').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Jurnal tidak ditemukan'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Jurnal tidak ditemukan'), findsOneWidget);

    await tester.ensureVisible(filters.last);
    await tester.tap(filters.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Semua Periode').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(Card, 'Siswa RPL 2'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.widgetWithText(Card, 'Siswa RPL 2'), findsOneWidget);

    await tester.ensureVisible(searchField);
    await tester.enterText(searchField, 'dOkumentasi');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Merapikan dokumentasi kegiatan kantor'), findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa RPL 2'), findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa TKJ 1'), findsNothing);

    await tester.ensureVisible(searchField);
    await tester.enterText(searchField, 'tidak-ada');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Jurnal tidak ditemukan'), findsOneWidget);

    await tester.ensureVisible(searchField);
    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Card, 'Siswa RPL 2'), findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa RPL 1'), findsNothing);
    expect(find.widgetWithText(Card, 'Siswa TKJ 1'), findsNothing);
  });

  testWidgets('filter periode menjelaskan konfigurasi tanggal mulai kosong', (
    WidgetTester tester,
  ) async {
    JadwalPklService.tanggalMulaiPkl = null;
    addTearDown(() => JadwalPklService.tanggalMulaiPkl = null);
    await _openLogin(tester);
    await _loginAsGuru(tester);

    final periodFilter = find.byType(DropdownButtonFormField<String>).last;
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(periodFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulan ke-1').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Tanggal mulai PKL belum dikonfigurasi.'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Tanggal mulai PKL belum dikonfigurasi.'), findsOneWidget);
  });

  testWidgets('guru memisahkan jurnal pending dan riwayat', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsGuru(tester);

    final pendingJournal = find.widgetWithText(Card, 'Siswa RPL 1');
    await tester.scrollUntilVisible(
      pendingJournal,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(pendingJournal, findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa RPL 2'), findsNothing);
    expect(find.widgetWithText(Card, 'Siswa TKJ 1'), findsNothing);

    final historyTab = find.text('Riwayat Jurnal');
    await tester.ensureVisible(historyTab);
    await tester.tap(historyTab);
    await tester.pumpAndSettle();

    final approvedJournal = find.widgetWithText(Card, 'Siswa RPL 2');
    await tester.scrollUntilVisible(
      approvedJournal,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(approvedJournal, findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa RPL 1'), findsNothing);

    final rejectedJournal = find.widgetWithText(Card, 'Siswa TKJ 1');
    await tester.scrollUntilVisible(
      rejectedJournal,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(rejectedJournal, findsOneWidget);
    expect(find.text('Ditolak'), findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa RPL 1'), findsNothing);

    final pendingTab = find.text('Perlu Validasi');
    await tester.scrollUntilVisible(
      pendingTab,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(pendingTab);
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField).first;
    await tester.scrollUntilVisible(
      searchField,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(searchField, 'rPl');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    final filters = find.byType(DropdownButtonFormField<String>);
    final statusFilter = filters.at(1);
    await tester.scrollUntilVisible(
      filters.first,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(filters.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('RPL').last);
    await tester.pumpAndSettle();
    await tester.tap(statusFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending').last);
    await tester.pumpAndSettle();

    final filteredPendingJournal = find.widgetWithText(Card, 'Siswa RPL 1');
    await tester.scrollUntilVisible(
      filteredPendingJournal,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(filteredPendingJournal, findsOneWidget);
    expect(find.widgetWithText(Card, 'Siswa RPL 2'), findsNothing);
    expect(find.widgetWithText(Card, 'Siswa TKJ 1'), findsNothing);
  });

  testWidgets('admin dapat membuka menu dan memfilter laporan jurnal', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsAdmin(tester);

    expect(find.text('Dashboard Admin'), findsOneWidget);
    expect(find.text('Halo, Admin PKL'), findsOneWidget);
    expect(find.text('Admin / Staf TIK'), findsOneWidget);

    for (final menu in [
      ('Kelola User', 'Kelola User'),
      ('Kelola Kelas', 'Kelola Kelas'),
      ('Data Jurnal', 'Data Jurnal'),
      ('Statistik', 'Statistik PKL'),
      ('Laporan', 'Laporan Kegiatan Siswa'),
    ]) {
      await tester.ensureVisible(find.text(menu.$1).first);
      await tester.tap(find.text(menu.$1).first);
      await tester.pumpAndSettle();
      expect(find.text(menu.$2), findsWidgets);
      if (menu.$1 == 'Data Jurnal') {
        expect(find.text('Setujui'), findsNothing);
        expect(find.text('Tolak'), findsNothing);
        expect(find.text('Validasi'), findsNothing);
        expect(find.text('Lihat & Validasi'), findsNothing);
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.ensureVisible(find.text('Laporan').first);
    await tester.tap(find.text('Laporan').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String?>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('TKJ').last);
    await tester.pumpAndSettle();
    expect(find.text('1 kegiatan'), findsOneWidget);
    expect(find.text('Siswa RPL 1'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String?>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siswa TKJ 1').last);
    await tester.pumpAndSettle();
    expect(find.text('1 kegiatan'), findsOneWidget);
    expect(
      find.textContaining('Mempelajari prosedur pelayanan pelanggan'),
      findsOneWidget,
    );
    expect(find.text('Siswa TKJ 2'), findsNothing);
    expect(find.text('Cetak Laporan'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Dashboard Admin'), findsNothing);
  });

  testWidgets('admin dapat membuka rincian dari setiap kartu statistik', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsAdmin(tester);

    await tester.ensureVisible(find.text('Statistik').first);
    await tester.tap(find.text('Statistik').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jumlah Siswa'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Siswa'), findsOneWidget);
    expect(find.text('Siswa RPL 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jumlah Guru'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Guru'), findsOneWidget);
    expect(find.text('Bapak/Ibu Guru'), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jumlah Kelas'));
    await tester.pumpAndSettle();
    expect(find.text('Rincian Kelas'), findsOneWidget);
    expect(find.text('2 siswa • 2 jurnal'), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Total Jurnal Kegiatan'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Jurnal Kegiatan'), findsOneWidget);
    expect(
      find.text('Membantu pemeriksaan perangkat komputer'),
      findsOneWidget,
    );
  });

  testWidgets('guru dapat memvalidasi jurnal dan menyimpan komentar', (
    WidgetTester tester,
  ) async {
    await _openLogin(tester);
    await _loginAsGuru(tester);

    final validationButton = find.text('Lihat & Validasi').first;
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
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

    await tester.scrollUntilVisible(
      find.text('Riwayat Jurnal'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Riwayat Jurnal'));
    await tester.pumpAndSettle();
    final updatedValidationButton = find.text('Lihat & Validasi').first;
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
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

Future<void> _loginAsAdmin(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'admin');
  await tester.enterText(find.byType(TextField).at(1), 'admin123');
  await tester.tap(find.text('LOGIN'));
  await tester.pumpAndSettle();
}
