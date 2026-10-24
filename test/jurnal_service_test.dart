import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/jurnal_model.dart';
import 'package:flutter_application_1/services/jurnal_service.dart';

void main() {
  test('jurnal yang disimpan tetap muncul setelah data dimuat ulang', () async {
    SharedPreferences.setMockInitialValues({});
    await JurnalService.initialize();
    final imageBytes = Uint8List.fromList([1, 2, 3, 4]);
    final journal = JurnalModel(
      date: '20 Oktober 2026',
      activity: 'Mencatat hasil pekerjaan',
      status: 'Pending',
      studentName: 'Siswa Uji',
      className: 'RPL',
      imageBytes: imageBytes,
    );

    await JurnalService.tambahJurnal(journal);
    await JurnalService.initialize();

    final restoredJournal = JurnalService.semuaJurnal.first;
    expect(restoredJournal.activity, journal.activity);
    expect(restoredJournal.studentName, journal.studentName);
    expect(restoredJournal.className, journal.className);
    expect(restoredJournal.imageBytes, orderedEquals(imageBytes));
  });
}
