class JurnalModel {
  const JurnalModel({
    required this.date,
    required this.activity,
    required this.status,
    this.studentName = 'Siswa PKL',
    this.imagePath,
    this.comment = '',
  });

  final String date;
  final String activity;
  final String status;
  final String studentName;
  final String? imagePath;
  final String comment;
}