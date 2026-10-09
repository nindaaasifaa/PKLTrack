class JadwalPklService {
  JadwalPklService._();

  static bool isHariWajib(DateTime date) =>
      date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
}