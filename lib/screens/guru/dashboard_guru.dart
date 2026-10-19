import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/jurnal_model.dart';
import '../../models/user_model.dart';
import '../../services/foto_profil_guru_service.dart';
import '../../services/jadwal_pkl_service.dart';
import '../../services/jurnal_service.dart';
import '../../services/nama_profil_akun_service.dart';
import '../../theme/app_theme.dart';
import 'profil_guru.dart';
import 'validasi_jurnal.dart';

class DashboardGuru extends StatefulWidget {
  const DashboardGuru({required this.user, super.key});

  final UserModel user;

  @override
  State<DashboardGuru> createState() => _DashboardGuruState();
}

class _DashboardGuruState extends State<DashboardGuru> {
  static const Color _blue = AppTheme.accent;
  static const int _targetJurnal = 5;
  static const String _allClasses = 'Semua Kelas';
  static const String _allStatuses = 'Semua Status';
  static const String _allPeriods = 'Semua Periode';
  static const List<String> _periodOptions = [
    _allPeriods,
    'Bulan ke-1',
    'Bulan ke-2',
    'Bulan ke-3',
  ];
  late List<JurnalModel> _jurnals;
  late final TextEditingController _searchController;
  String _selectedClass = _allClasses;
  String _selectedStatus = _allStatuses;
  String _selectedPeriod = _allPeriods;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _jurnals = JurnalService.semuaJurnal;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _classes {
    final classes =
        _jurnals
            .map((journal) => journal.className)
            .whereType<String>()
            .where((className) => className.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return classes;
  }

  List<int> get _filteredJournalIndices {
    final query = _searchController.text.trim().toLowerCase();
    return [
      for (var index = 0; index < _jurnals.length; index++)
        if (_matchesFilters(_jurnals[index], query)) index,
    ];
  }

  bool _matchesFilters(JurnalModel journal, String query) {
    final journalStatus = journal.status.trim().toLowerCase();
    final classMatches =
        _selectedClass == _allClasses ||
        journal.className?.trim().toLowerCase() ==
            _selectedClass.trim().toLowerCase();
    final statusMatches =
        _selectedStatus == _allStatuses ||
        journalStatus == _selectedStatus.toLowerCase();
    final periodNumber = switch (_selectedPeriod) {
      'Bulan ke-1' => 1,
      'Bulan ke-2' => 2,
      'Bulan ke-3' => 3,
      _ => null,
    };
    final startDate = JadwalPklService.tanggalMulaiPkl;
    final activityDate = JadwalPklService.parseTanggalJurnal(journal.date);
    final periodMatches =
        periodNumber == null ||
        (startDate != null &&
            activityDate != null &&
            JadwalPklService.periodeKe(activityDate, startDate) ==
                periodNumber);
    final tabMatches = _showHistory
        ? journalStatus == 'disetujui' || journalStatus == 'ditolak'
        : journalStatus == 'pending';
    final queryMatches =
        query.isEmpty ||
        journal.studentName.toLowerCase().contains(query) ||
        (journal.className?.toLowerCase().contains(query) ?? false) ||
        journal.activity.toLowerCase().contains(query);

    return tabMatches &&
        classMatches &&
        statusMatches &&
        periodMatches &&
        queryMatches;
  }

  @override
  Widget build(BuildContext context) {
    final filteredJournalIndices = _filteredJournalIndices;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('PKLTrack'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: FotoProfilGuruService.sedangMemilih,
            builder: (context, isPicking, _) => IconButton(
              tooltip: 'Tambah atau ganti foto profil Guru',
              onPressed: isPicking ? null : _selectProfilePhoto,
              icon: isPicking
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_outlined),
            ),
          ),
          ValueListenableBuilder<Uint8List?>(
            valueListenable: FotoProfilGuruService.fotoBytes,
            builder: (context, photoBytes, _) => IconButton(
              tooltip: 'Profil Guru',
              icon: CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.surface,
                backgroundImage: photoBytes == null
                    ? null
                    : MemoryImage(photoBytes),
                child: photoBytes == null
                    ? const Icon(
                        Icons.person_outline,
                        size: 19,
                        color: AppTheme.onPrimary,
                      )
                    : null,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ProfilGuru(user: widget.user),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ValueListenableBuilder<String>(
              valueListenable:
                  NamaProfilAkunService.untukRole(widget.user.role),
              builder: (context, name, _) => Text(
                'Halo, $name!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pantau dan validasi jurnal kegiatan siswa.',
              style: TextStyle(color: AppTheme.muted),
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
            _buildJournalFilters(),
            const SizedBox(height: 12),
            _buildJournalTabs(),
            const SizedBox(height: 12),
            if (filteredJournalIndices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(_emptyJournalMessage)),
              )
            else
              ...filteredJournalIndices.map(
                (index) => _buildJournalCard(index, _jurnals[index]),
              ),
          ],
        ),
      ),
    );
  }

  String get _emptyJournalMessage =>
      _selectedPeriod != _allPeriods && JadwalPklService.tanggalMulaiPkl == null
      ? 'Tanggal mulai PKL belum dikonfigurasi.'
      : 'Jurnal tidak ditemukan';

  Widget _buildJournalTabs() {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: false, label: Text('Perlu Validasi')),
        ButtonSegment(value: true, label: Text('Riwayat Jurnal')),
      ],
      selected: {_showHistory},
      onSelectionChanged: (selection) {
        setState(() => _showHistory = selection.first);
      },
    );
  }

  Widget _buildJournalFilters() {
    final classes = [_allClasses, ..._classes];
    const statuses = [_allStatuses, 'Pending', 'Disetujui', 'Ditolak'];

    Widget classFilter() {
      return DropdownButtonFormField<String>(
        initialValue: _selectedClass,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Kelas',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: classes
            .map(
              (className) => DropdownMenuItem(
                value: className,
                child: Text(className, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedClass = value);
        },
      );
    }

    Widget statusFilter() {
      return DropdownButtonFormField<String>(
        initialValue: _selectedStatus,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: statuses
            .map(
              (status) => DropdownMenuItem(
                value: status,
                child: Text(status, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedStatus = value);
        },
      );
    }

    Widget periodFilter() {
      return DropdownButtonFormField<String>(
        initialValue: _selectedPeriod,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Periode PKL',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: _periodOptions
            .map(
              (period) => DropdownMenuItem(
                value: period,
                child: Text(period, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedPeriod = value);
        },
      );
    }

    return Column(
      children: [
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            setState(() {});
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            hintText: 'Cari nama, kelas, atau kegiatan jurnal',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus pencarian',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 440) {
              return Column(
                children: [
                  classFilter(),
                  const SizedBox(height: 10),
                  statusFilter(),
                  const SizedBox(height: 10),
                  periodFilter(),
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: classFilter()),
                    const SizedBox(width: 10),
                    Expanded(child: statusFilter()),
                  ],
                ),
                const SizedBox(height: 10),
                periodFilter(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
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
          color: AppTheme.surface,
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
              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
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
        color: AppTheme.surface,
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
              style: TextStyle(color: AppTheme.muted),
            )
          else
            ...counts.entries.map((entry) {
              final progress = (entry.value / _targetJurnal)
                  .clamp(0.0, 1.0)
                  .toDouble();
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
                      backgroundColor: AppTheme.progressTrack,
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
    final className = journal.className?.trim();
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
            if (className != null && className.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                'Kelas: $className',
                style: const TextStyle(color: AppTheme.muted),
              ),
            ],
            const SizedBox(height: 5),
            Text(journal.date, style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 8),
            Text(
              journal.activity,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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

  Future<void> _selectProfilePhoto() async {
    try {
      await FotoProfilGuruService.pilihDariGaleri();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil tidak dapat dibuka. Silakan coba lagi.'),
          ),
        );
      }
    }
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
