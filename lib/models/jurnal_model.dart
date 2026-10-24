import 'dart:convert';
import 'dart:typed_data';

class JurnalModel {
  const JurnalModel({
    required this.date,
    required this.activity,
    required this.status,
    this.studentName = 'Siswa PKL',
    this.className,
    this.imagePath,
    this.imageBytes,
    this.comment = '',
  });

  final String date;
  final String activity;
  final String status;
  final String studentName;
  final String? className;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String comment;

  factory JurnalModel.fromJson(Map<String, dynamic> json) => JurnalModel(
    date: json['date'] as String,
    activity: json['activity'] as String,
    status: json['status'] as String,
    studentName: json['studentName'] as String? ?? 'Siswa PKL',
    className: json['className'] as String?,
    imagePath: json['imagePath'] as String?,
    imageBytes: json['imageBytes'] == null
        ? null
        : base64Decode(json['imageBytes'] as String),
    comment: json['comment'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'activity': activity,
    'status': status,
    'studentName': studentName,
    'className': className,
    'imagePath': imagePath,
    'imageBytes': imageBytes == null ? null : base64Encode(imageBytes!),
    'comment': comment,
  };
}
