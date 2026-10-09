import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/admin_data_service.dart';
import '../../services/jurnal_service.dart';
import 'jurnal_admin.dart';
import 'kelola_kelas.dart';
import 'kelola_user.dart';
import 'laporan_admin.dart';
import 'profil_admin.dart';
import 'statistik_admin.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({required this.user, super.key});

  final UserModel user;

  static const Color _blue = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final summary = [
      ('User', AdminDataService.users.length, Icons.people_outline),
      ('Kelas', AdminDataService.kelas.length, Icons.class_outlined),
      ('Jurnal', JurnalService.semuaJurnal.length, Icons.menu_book_outlined),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () => _open(context, ProfilAdmin(user: user)),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Halo, ${user.name}',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Admin / Staf TIK',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            children: summary
                .map(
                  (item) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: item == summary.last ? 0 : 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item.$3, color: _blue),
                          const SizedBox(height: 10),
                          Text(
                            '${item.$2}',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.$1,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          _MenuRow(
            icon: Icons.people_outline,
            title: 'Kelola User',
            onTap: () => _open(context, const KelolaUser()),
          ),
          _MenuRow(
            icon: Icons.class_outlined,
            title: 'Kelola Kelas',
            onTap: () => _open(context, const KelolaKelas()),
          ),
          _MenuRow(
            icon: Icons.menu_book_outlined,
            title: 'Data Jurnal',
            onTap: () => _open(context, const JurnalAdmin()),
          ),
          _MenuRow(
            icon: Icons.bar_chart_outlined,
            title: 'Statistik',
            onTap: () => _open(context, const StatistikAdmin()),
          ),
          _MenuRow(
            icon: Icons.description_outlined,
            title: 'Laporan',
            onTap: () => _open(context, const LaporanAdmin()),
          ),
          _MenuRow(
            icon: Icons.person_outline,
            title: 'Profil',
            onTap: () => _open(context, ProfilAdmin(user: user)),
          ),
          _MenuRow(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => ProfilAdmin.konfirmasiLogout(context),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFFE7ECF2)),
    ),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF1565C0)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
