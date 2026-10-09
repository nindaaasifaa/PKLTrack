import 'package:flutter/material.dart';

import '../../services/admin_data_service.dart';
import '../../services/jurnal_service.dart';

class StatistikAdmin extends StatelessWidget {
  const StatistikAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final users = AdminDataService.users;
    final journals = JurnalService.semuaJurnal;
    final stats = [
      ('Jumlah Siswa', users.where((user) => user.role == 'siswa').length),
      ('Jumlah Guru', users.where((user) => user.role == 'guru').length),
      ('Jumlah Kelas', AdminDataService.kelas.length),
      ('Jumlah Jurnal', journals.length),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Statistik'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final stat in stats)
            Card(
              color: Colors.white,
              child: ListTile(
                title: Text(stat.$1),
                trailing: Text(
                  '${stat.$2}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 8),
            child: Text(
              'Kegiatan Berdasarkan Kelas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          for (final className in AdminDataService.kelas)
            _ClassJournalCount(
              className: className,
              count: journals
                  .where(
                    (journal) =>
                        (journal.className ??
                            AdminDataService.classForStudent(
                              journal.studentName,
                            )) ==
                        className,
                  )
                  .length,
              total: journals.length,
            ),
        ],
      ),
    );
  }
}

class _ClassJournalCount extends StatelessWidget {
  const _ClassJournalCount({
    required this.className,
    required this.count,
    required this.total,
  });

  final String className;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : count / total;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(className), Text('$count jurnal')],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              color: const Color(0xFF1565C0),
            ),
          ],
        ),
      ),
    );
  }
}
