import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class ProfilAdmin extends StatelessWidget {
  const ProfilAdmin({required this.user, super.key});

  final UserModel user;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      title: const Text('Profil Admin'),
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.onPrimary,
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: AppTheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ProfileInfo(label: 'Username', value: user.username),
                const Divider(height: 24),
                const _ProfileInfo(label: 'Role', value: 'Admin / Staf TIK'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => konfirmasiLogout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    ),
  );

  static Future<void> konfirmasiLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: AppTheme.muted)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
