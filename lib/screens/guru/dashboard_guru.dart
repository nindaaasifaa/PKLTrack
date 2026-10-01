import 'package:flutter/material.dart';

import '../../models/jurnal_model.dart';
import '../../models/user_model.dart';
import '../../services/jurnal_service.dart';
import 'profil_guru.dart';
import 'validasi_jurnal.dart';

class DashboardGuru extends StatefulWidget {
  const DashboardGuru({required this.user, super.key});

  final UserModel user;

  @override
  State<DashboardGuru> createState() => _DashboardGuruState();
}

class _DashboardGuruState extends State<DashboardGuru> {
  static const Color _blue = Color(0xFF1565C0);
  static const int _targetJurnal = 5;
  late List<JurnalModel> _jurnals;

  @override
  void initState() {
    super.initState();
    _jurnals = JurnalService.semuaJurnal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('PKLTrack'),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Profil Guru',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ProfilGuru(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Halo, Guru!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pantau dan validasi jurnal kegiatan siswa.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildSummary(),
            const SizedBox(height: 20),
            _buildProgress(),
            const SizedBox(height: 24),
            const Text(
              'Jurnal Siswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_jurnals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Belum ada jurnal siswa.')),
              )
            else
              ..._jurnals.asMap().entries.map(
                (entry) => _buildJournalCard(entry.key, entry.value),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah Jurnal Siswa',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${_jurnals.length}',
                style: const TextStyle(
                  color: _blue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatusCount('Pending', Colors.orange.shade800),
            const SizedBox(width: 8),
            _buildStatusCount('Disetujui', Colors.green.shade700),
            const SizedBox(width: 8),
            _buildStatusCount('Ditolak', Colors.red.shade700),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCount(String status, Color color) {
    final count = _jurnals.where((journal) => journal.status == status).length;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final counts = <String, int>{};
    for (final journal in _jurnals) {
      counts.update(
        journal.studentName,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Pengisian Jurnal',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (counts.isEmpty)
            const Text(
              'Belum ada progress jurnal.',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...counts.entries.map((entry) {
              final progress =
                  (entry.value / _targetJurnal).clamp(0.0, 1.0).toDouble();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(entry.key)),
                        Text('${entry.value}/$_targetJurnal jurnal'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE3EAF2),
                      color: _blue,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildJournalCard(int index, JurnalModel journal) {
    final statusColor = switch (journal.status) {
      'Disetujui' => Colors.green.shade700,
      'Ditolak' => Colors.red.shade700,
      _ => Colors.orange.shade800,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE7ECF2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const SizedBox(height: 5),
            Text(journal.date, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(journal.activity, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openValidation(index, journal),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Lihat & Validasi'),
                style: OutlinedButton.styleFrom(foregroundColor: _blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openValidation(int index, JurnalModel journal) async {
    final wasUpdated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => ValidasiJurnal(jurnalIndex: index, jurnal: journal),
      ),
    );
    if (wasUpdated == true && mounted) {
      setState(() => _jurnals = JurnalService.semuaJurnal);
    }
  }
}