import 'package:flutter/material.dart';

import '../../models/jurnal_model.dart';
import '../../services/jurnal_service.dart';
import '../../theme/app_theme.dart';
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
  late List<JurnalModel> _jurnals;

  @override
  void initState() {
    super.initState();
    _jurnals = JurnalService.semuaJurnal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('PKLTrack'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
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
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 20),
            _buildReminderCard(),
            const SizedBox(height: 16),
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
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
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
            ..._jurnals.map((journal) => _buildJournalTile(context, journal)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_today_outlined, color: AppTheme.accent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengingat belum tersedia',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Jadwal PKL dan jurnal akun siswa belum terhubung, jadi kewajiban hari ini belum dapat ditentukan.',
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppTheme.accent),
              SizedBox(width: 8),
              Text(
                'Progress Jurnal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Belum tersedia',
            style: TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Data jurnal belum terhubung ke akun siswa. Progres belum dapat dihitung.',
            style: TextStyle(fontSize: 12, color: AppTheme.muted),
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
                  color: AppTheme.surface,
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.muted,
                      ),
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
      color: AppTheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.outline),
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
        trailing: const Icon(Icons.chevron_right, color: AppTheme.muted),
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
