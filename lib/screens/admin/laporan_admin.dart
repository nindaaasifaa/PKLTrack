import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/jurnal_model.dart';
import '../../services/admin_data_service.dart';
import '../../services/jurnal_service.dart';

class LaporanAdmin extends StatefulWidget {
  const LaporanAdmin({super.key});

  @override
  State<LaporanAdmin> createState() => _LaporanAdminState();
}

class _LaporanAdminState extends State<LaporanAdmin> {
  String? _selectedClass;
  String? _selectedStudent;
  DateTimeRange? _period;
  bool _isExporting = false;

  List<JurnalModel> get _filteredJournals =>
      JurnalService.semuaJurnal.where((journal) {
        final className =
            journal.className ??
            AdminDataService.classForStudent(journal.studentName);
        if (_selectedClass != null && className != _selectedClass) return false;
        if (_selectedStudent != null && journal.studentName != _selectedStudent) {
          return false;
        }
        final date = _parseDate(journal.date);
        if (_period != null &&
            date != null &&
            (date.isBefore(_period!.start) || date.isAfter(_period!.end))) {
          return false;
        }
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final classStudents = AdminDataService.students
        .where(
          (user) => _selectedClass == null || user.className == _selectedClass,
        )
        .toList();
    if (_selectedStudent != null &&
        !classStudents.any((user) => user.name == _selectedStudent)) {
      _selectedStudent = null;
    }
    final journals = _filteredJournals;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Laporan Kegiatan Siswa'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String?>(
            initialValue: _selectedClass,
            decoration: const InputDecoration(
              labelText: 'Kelas',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Semua kelas'),
              ),
              ...AdminDataService.kelas.map(
                (name) =>
                    DropdownMenuItem<String?>(value: name, child: Text(name)),
              ),
            ],
            onChanged: (value) => setState(() {
              _selectedClass = value;
              _selectedStudent = null;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _selectedStudent,
            decoration: const InputDecoration(
              labelText: 'Siswa',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Semua siswa'),
              ),
              ...classStudents.map(
                (user) => DropdownMenuItem<String?>(
                  value: user.name,
                  child: Text(user.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedStudent = value),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _selectPeriod,
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              _period == null
                  ? 'Pilih Periode'
                  : '${_formatDate(_period!.start)} - ${_formatDate(_period!.end)}',
            ),
          ),
          if (_period != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _period = null),
                child: const Text('Hapus periode'),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            '${journals.length} kegiatan',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (journals.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('Tidak ada jurnal untuk filter ini.')),
            )
          else
            ...journals.map(
              (journal) => Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(journal.studentName),
                  subtitle: Text('${journal.date}\n${journal.activity}'),
                  isThreeLine: true,
                  trailing: Text(journal.status),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: journals.isEmpty || _isExporting
                      ? null
                      : () => _printReport(journals),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Cetak Laporan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: journals.isEmpty || _isExporting
                      ? null
                      : () => _exportReport(journals),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectPeriod() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _period,
    );
    if (range != null && mounted) setState(() => _period = range);
  }

  Future<void> _printReport(List<JurnalModel> journals) async {
    final bytes = await _buildPdf(journals);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _exportReport(List<JurnalModel> journals) async {
    setState(() => _isExporting = true);
    try {
      final bytes = await _buildPdf(journals);
      await Printing.sharePdf(bytes: bytes, filename: _fileName());
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<Uint8List> _buildPdf(List<JurnalModel> journals) async {
    final pdf = pw.Document();
    final rows = <List<dynamic>>[];
    for (final entry in journals.indexed) {
      dynamic documentation = '-';
      final imagePath = entry.$2.imagePath;
      if (imagePath != null) {
        try {
          final imageBytes = await File(imagePath).readAsBytes();
          documentation = pw.Image(
            pw.MemoryImage(imageBytes),
            height: 34,
            fit: pw.BoxFit.contain,
          );
        } catch (_) {
          documentation = 'Foto tersedia';
        }
      }
      rows.add([
        '${entry.$1 + 1}',
        entry.$2.date,
        '${entry.$2.studentName} (${entry.$2.className ?? AdminDataService.classForStudent(entry.$2.studentName) ?? '-'})\n${entry.$2.activity}',
        entry.$2.status,
        documentation,
      ]);
    }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'LAPORAN KEGIATAN PKL SISWA',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Kelas: ${_selectedClass ?? 'Semua kelas'}'),
          pw.Text('Siswa: ${_selectedStudent ?? 'Semua siswa'}'),
          if (_period != null)
            pw.Text(
              'Periode: ${_formatDate(_period!.start)} - ${_formatDate(_period!.end)}',
            ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['No', 'Tanggal', 'Kegiatan / Siswa', 'Status', 'Foto'],
            data: rows,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(5),
            columnWidths: {
              0: const pw.FixedColumnWidth(24),
              1: const pw.FixedColumnWidth(72),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FixedColumnWidth(58),
              4: const pw.FixedColumnWidth(54),
            },
          ),
        ],
      ),
    );
    return pdf.save();
  }

  String _fileName() {
    final filter = _selectedStudent ?? _selectedClass ?? 'Semua';
    final normalized = filter.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'Laporan_Jurnal_$normalized.pdf';
  }

  DateTime? _parseDate(String value) {
    const months = {
      'Januari': 1,
      'Februari': 2,
      'Maret': 3,
      'April': 4,
      'Mei': 5,
      'Juni': 6,
      'Juli': 7,
      'Agustus': 8,
      'September': 9,
      'Oktober': 10,
      'November': 11,
      'Desember': 12,
    };
    final parts = value.split(' ');
    if (parts.length != 3) return DateTime.tryParse(value);
    final month = months[parts[1]];
    if (month == null) return null;
    return DateTime.tryParse(
      '${parts[2]}-${month.toString().padLeft(2, '0')}-${parts[0].padLeft(2, '0')}',
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
