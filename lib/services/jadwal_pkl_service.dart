class JadwalPklService {
  JadwalPklService._();

  static DateTime? tanggalMulaiPkl;

  static const Map<String, int> _bulanIndonesia = {
    'januari': 1,
    'februari': 2,
    'maret': 3,
    'april': 4,
    'mei': 5,
    'juni': 6,
    'juli': 7,
    'agustus': 8,
    'september': 9,
    'oktober': 10,
    'november': 11,
    'desember': 12,
  };

  static bool isHariWajib(DateTime date) =>
      date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;

  static DateTime? parseTanggalJurnal(String value) {
    final isoDate = DateTime.tryParse(value.trim());
    if (isoDate != null) return _tanggalSaja(isoDate);

    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = _bulanIndonesia[parts[1].toLowerCase()];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  static int? periodeKe(DateTime kegiatan, DateTime mulaiPkl) {
    final activityDate = _tanggalSaja(kegiatan);
    final startDate = _tanggalSaja(mulaiPkl);
    if (activityDate.isBefore(startDate)) return null;

    for (var month = 0; month < 3; month++) {
      final periodStart = _tambahBulanKlem(mulaiPkl, month);
      final periodEnd = _tambahBulanKlem(mulaiPkl, month + 1);
      if (!activityDate.isBefore(periodStart) &&
          activityDate.isBefore(periodEnd)) {
        return month + 1;
      }
    }
    return null;
  }

  static DateTime _tambahBulanKlem(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }

  static DateTime _tanggalSaja(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
