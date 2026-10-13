import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/foto_profil_guru_service.dart';
import '../../theme/app_theme.dart';

class ProfilGuru extends StatelessWidget {
  const ProfilGuru({required this.user, super.key});

  final UserModel user;

  static const Color _blue = AppTheme.accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil Guru'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outline),
            ),
            child: Row(
              children: [
                _buildPhotoAvatar(context),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROFIL GURU',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Akun Guru',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Informasi Akun',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outline),
            ),
            child: Column(
              children: [
                _ProfileInfo(
                  icon: Icons.alternate_email,
                  label: 'Username',
                  value: user.username,
                ),
                const Divider(height: 1),
                const _ProfileInfo(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: 'Guru',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoAvatar(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: FotoProfilGuruService.fotoBytes,
      builder: (context, photoBytes, _) => Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppTheme.surface,
            backgroundImage: photoBytes == null
                ? null
                : MemoryImage(photoBytes),
            child: photoBytes == null
                ? const Icon(Icons.person_outline, color: _blue, size: 36)
                : null,
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: ValueListenableBuilder<bool>(
              valueListenable: FotoProfilGuruService.sedangMemilih,
              builder: (context, isPicking, _) => IconButton.filled(
                tooltip: photoBytes == null
                    ? 'Tambah foto profil guru'
                    : 'Ganti foto profil guru',
                onPressed: isPicking
                    ? null
                    : () => _selectProfilePhoto(context),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.onPrimary,
                ),
                icon: isPicking
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.camera_alt_outlined, size: 19),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectProfilePhoto(BuildContext context) async {
    try {
      await FotoProfilGuruService.pilihDariGaleri();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil tidak dapat dibuka. Silakan coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
  const _ProfileInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 15),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: AppTheme.muted)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
