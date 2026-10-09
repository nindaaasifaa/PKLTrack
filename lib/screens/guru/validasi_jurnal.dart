import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/jurnal_model.dart';
import '../../services/jurnal_service.dart';
import '../../theme/app_theme.dart';

class ValidasiJurnal extends StatefulWidget {
  const ValidasiJurnal({
    required this.jurnalIndex,
    required this.jurnal,
    super.key,
  });

  final int jurnalIndex;
  final JurnalModel jurnal;

  @override
  State<ValidasiJurnal> createState() => _ValidasiJurnalState();
}

class _ValidasiJurnalState extends State<ValidasiJurnal> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.jurnal.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.jurnal.imagePath;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Validasi Jurnal'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              title: 'Informasi Siswa',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jurnal.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tanggal: ${widget.jurnal.date}',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Kegiatan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.jurnal.activity),
                  const SizedBox(height: 14),
                  Text('Status saat ini: ${widget.jurnal.status}'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSection(
              title: 'Foto Dokumentasi',
              child: imagePath == null
                  ? Container(
                      height: 170,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 38,
                            color: AppTheme.accent,
                          ),
                          SizedBox(height: 8),
                          Text('Tidak ada foto dokumentasi'),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(imagePath),
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 170,
                              child: Center(child: Text('Foto tidak tersedia')),
                            ),
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            _buildSection(
              title: 'Komentar Guru',
              child: TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar untuk siswa...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('reject-journal'),
                    onPressed: () => _saveValidation('Ditolak'),
                    icon: const Icon(Icons.close),
                    label: const Text('Ditolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key('approve-journal'),
                    onPressed: () => _saveValidation('Disetujui'),
                    icon: const Icon(Icons.check),
                    label: const Text('Disetujui'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _saveValidation(String status) {
    JurnalService.validasiJurnal(
      index: widget.jurnalIndex,
      status: status,
      comment: _commentController.text.trim(),
    );
    Navigator.pop(context, true);
  }
}
