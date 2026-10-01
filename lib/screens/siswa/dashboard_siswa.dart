import 'package:flutter/material.dart';

import '../../models/jurnal_model.dart';
import '../../services/jurnal_service.dart';
import 'detail_jurnal.dart';
import 'profil_siswa.dart';
import 'riwayat_jurnal.dart';
import 'tambah_jurnal.dart';

class DashboardSiswa extends StatefulWidget {
  const DashboardSiswa({super.key});

  @override
  State<DashboardSiswa> createState() => _DashboardSiswaState();
}

class _DashboardSiswaState extends State<DashboardSiswa> {
  static const Color _blue = Color(0xFF1565C0);
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
            tooltip: 'Riwayat Jurnal',
            icon: const Icon(Icons.history),
            onPressed: () => _openHistory(context),
          ),
          IconButton(
            tooltip: 'Profil Siswa',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const ProfilSiswa()),
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
              'Halo, Siswa!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pantau jurnal kegiatan PKL kamu.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildProgressCard(),
            const SizedBox(height: 16),
            _buildStatusSummary(),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _openAddJournal(context),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Jurnal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jurnal Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _openHistory(context),
                  child: const Text('Riwayat Jurnal'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ..._jurnals.map(
              (journal) => _buildJournalTile(context, journal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = (_jurnals.length / 5).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Jurnal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${_jurnals.length} jurnal',
                style: const TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Color(0xFFE3EAF2),
              color: _blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_jurnals.length} dari 5 jurnal',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary() {
    final counts = <String, int>{
      'Pending': _countStatus('Pending'),
      'Disetujui': _countStatus('Disetujui'),
      'Ditolak': _countStatus('Ditolak'),
    };

    return Row(
      children: counts.entries
          .map(
            (entry) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: entry.key == 'Ditolak' ? 0 : 10),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildJournalTile(BuildContext context, JurnalModel journal) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        title: Text(
          journal.activity,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Row(
            children: [
              Expanded(child: Text(journal.date)),
              Text(
                journal.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade600),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => DetailJurnal(
                date: journal.date,
                activity: journal.activity,
                status: journal.status,
              ),
            ),
          );
        },
      ),
    );
  }

  int _countStatus(String status) =>
      _jurnals.where((journal) => journal.status == status).length;

  Future<void> _openAddJournal(BuildContext context) async {
    final wasSaved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const TambahJurnal()),
    );
    if (wasSaved == true && mounted) {
      setState(() => _jurnals = JurnalService.semuaJurnal);
    }
  }

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const RiwayatJurnal()),
    );
  }
}
