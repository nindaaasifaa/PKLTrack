import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/foto_profil_siswa_service.dart';
import '../../services/nama_profil_siswa_service.dart';
import '../../theme/app_theme.dart';

class ProfilSiswa extends StatelessWidget {
  const ProfilSiswa({super.key});

  static const Color _blue = AppTheme.accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil Siswa'),
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
                        'PROFIL SISWA',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: ValueListenableBuilder<String>(
                              valueListenable: NamaProfilSiswaService.nama,
                              builder: (context, name, _) => Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Ubah nama',
                            onPressed: () => _editName(context),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Akun Siswa',
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
                ValueListenableBuilder<String>(
                  valueListenable: NamaProfilSiswaService.username,
                  builder: (context, username, _) => _ProfileInfo(
                    icon: Icons.alternate_email,
                    label: 'Username',
                    value: username,
                    trailing: IconButton(
                      tooltip: 'Ubah username',
                      onPressed: () => _editUsername(context),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
                const Divider(height: 1),
                const _ProfileInfo(
                  icon: Icons.school_outlined,
                  label: 'Jenis akun',
                  value: 'Siswa',
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

  Future<void> _editName(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text: NamaProfilSiswaService.nama.value,
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Nama'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nama siswa'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Nama wajib diisi.'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName == null || !context.mounted) return;
    try {
      await NamaProfilSiswaService.ubahNama(newName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama berhasil diperbarui.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama gagal disimpan. Silakan coba lagi.'),
          ),
        );
      }
    }
  }

  Future<void> _editUsername(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text: NamaProfilSiswaService.username.value,
    );
    final newUsername = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Username'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Username baru'),
            validator: (value) {
              final username = value?.trim() ?? '';
              if (username.isEmpty) return 'Username wajib diisi.';
              if (username.contains(RegExp(r'\s'))) {
                return 'Username tidak boleh mengandung spasi.';
              }
              if (username.toLowerCase() == 'guru' ||
                  username.toLowerCase() == 'admin') {
                return 'Username sudah digunakan.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newUsername == null || !context.mounted) return;
    try {
      await NamaProfilSiswaService.ubahUsername(newUsername);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username berhasil diperbarui.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username gagal disimpan. Silakan coba lagi.'),
          ),
        );
      }
    }
  }

  Widget _buildPhotoAvatar(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: FotoProfilSiswaService.fotoBytes,
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
              valueListenable: FotoProfilSiswaService.sedangMemilih,
              builder: (context, isPicking, _) => IconButton.filled(
                tooltip: photoBytes == null
                    ? 'Tambah foto profil'
                    : 'Ganti foto profil',
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
      await FotoProfilSiswaService.pilihDariGaleri();
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
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppTheme.muted)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}