import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/foto_profil_siswa_service.dart';
import '../../services/nama_profil_siswa_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile_widgets.dart';

class ProfilSiswa extends StatelessWidget {
  const ProfilSiswa({super.key});

  static const Color _blue = AppTheme.accent;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      title: const Text('Profil Siswa'),
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.onPrimary,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        ProfileHeader(
          name: NamaProfilSiswaService.nama,
          role: 'Siswa',
          avatar: _buildPhotoAvatar(context),
          onEditName: () => _editName(context),
        ),
        const SizedBox(height: 26),
        const ProfileSectionTitle(
          title: 'Informasi akun',
          subtitle: 'Username dan jenis akun yang Anda gunakan',
        ),
        const SizedBox(height: 12),
        ProfileInfoCard(
          children: [
            ValueListenableBuilder<String>(
              valueListenable: NamaProfilSiswaService.username,
              builder: (context, username, _) => ProfileInfoRow(
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
            const ProfileInfoRow(
              icon: Icons.school_outlined,
              label: 'Jenis akun',
              value: 'Siswa',
            ),
          ],
        ),
        const SizedBox(height: 28),
        ProfileLogoutButton(onPressed: () => _confirmLogout(context)),
      ],
    ),
  );

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
