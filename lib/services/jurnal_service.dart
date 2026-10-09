import '../models/jurnal_model.dart';

class JurnalService {
  JurnalService._();

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

  static void tambahJurnal(JurnalModel jurnal) {
    _jurnals.insert(0, jurnal);
  }

  static void validasiJurnal({
    required int index,
    required String status,
    required String comment,
  }) {
    final jurnal = _jurnals[index];
    _jurnals[index] = JurnalModel(
      date: jurnal.date,
      activity: jurnal.activity,
      status: status,
      studentName: jurnal.studentName,
      className: jurnal.className,
      imagePath: jurnal.imagePath,
      comment: comment,
    );
  }
}
