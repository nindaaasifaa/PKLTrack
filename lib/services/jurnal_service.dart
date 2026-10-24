import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/jurnal_model.dart';

class JurnalService {
  JurnalService._();

  static const String _jurnalsKey = 'jurnal_siswa';
  static final List<JurnalModel> _jurnals = [
    const JurnalModel(
      date: '30 September 2026',
      activity: 'Membantu pemeriksaan perangkat komputer',
      status: 'Pending',
      studentName: 'Siswa RPL 1',
      className: 'RPL',
    ),
    const JurnalModel(
      date: '29 September 2026',
      activity: 'Merapikan dokumentasi kegiatan kantor',
      status: 'Disetujui',
      studentName: 'Siswa RPL 2',
      className: 'RPL',
    ),
    const JurnalModel(
      date: '28 September 2026',
      activity: 'Mempelajari prosedur pelayanan pelanggan',
      status: 'Ditolak',
      studentName: 'Siswa TKJ 1',
      className: 'TKJ',
    ),
  ];

  static List<JurnalModel> get semuaJurnal => List.unmodifiable(_jurnals);

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedJournals = preferences.getString(_jurnalsKey);
    if (savedJournals == null) return;

    final decoded = jsonDecode(savedJournals);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Format data jurnal tidak valid.');
    }

    final journals = decoded.map((value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Format data jurnal tidak valid.');
      }
      return JurnalModel.fromJson(value);
    }).toList();

    _jurnals
      ..clear()
      ..addAll(journals);
  }

  static Future<void> tambahJurnal(JurnalModel jurnal) async {
    final updatedJournals = [jurnal, ..._jurnals];
    await _saveJournals(updatedJournals);
    _jurnals
      ..clear()
      ..addAll(updatedJournals);
  }

  static Future<void> validasiJurnal({
    required int index,
    required String status,
    required String comment,
  }) async {
    final jurnal = _jurnals[index];
    final updatedJournals = List<JurnalModel>.of(_jurnals);
    updatedJournals[index] = JurnalModel(
      date: jurnal.date,
      activity: jurnal.activity,
      status: status,
      studentName: jurnal.studentName,
      className: jurnal.className,
      imagePath: jurnal.imagePath,
      imageBytes: jurnal.imageBytes,
      comment: comment,
    );
    await _saveJournals(updatedJournals);
    _jurnals
      ..clear()
      ..addAll(updatedJournals);
  }

  static Future<void> _saveJournals(List<JurnalModel> journals) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _jurnalsKey,
      jsonEncode(journals.map((journal) => journal.toJson()).toList()),
    );
    if (!saved) throw StateError('Data jurnal gagal disimpan.');
  }
}
