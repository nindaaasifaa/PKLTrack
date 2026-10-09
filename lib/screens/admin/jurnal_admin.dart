import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/jurnal_model.dart';
import '../../services/admin_data_service.dart';
import '../../services/jurnal_service.dart';
import '../../theme/app_theme.dart';

class JurnalAdmin extends StatelessWidget {
  const JurnalAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final journals = JurnalService.semuaJurnal;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Data Jurnal'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
      ),
      body: journals.isEmpty
          ? const Center(child: Text('Belum ada jurnal siswa.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: journals.length,
              itemBuilder: (context, index) =>
                  _JournalTile(journal: journals[index]),
            ),
    );
  }
}

class _JournalTile extends StatelessWidget {
  const _JournalTile({required this.journal});

  final JurnalModel journal;

  @override
  Widget build(BuildContext context) {
    final className =
        journal.className ??
        AdminDataService.classForStudent(journal.studentName) ??
        'Kelas belum diatur';
    final statusColor = switch (journal.status) {
      'Disetujui' => Colors.green.shade700,
      'Ditolak' => Colors.red.shade700,
      _ => Colors.orange.shade800,
    };
    return Card(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    journal.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  journal.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$className · ${journal.date}',
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 10),
            Text(journal.activity),
            if (journal.imagePath != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(journal.imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Text('Foto dokumentasi tidak dapat ditampilkan.'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
