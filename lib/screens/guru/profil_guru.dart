import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/foto_profil_guru_service.dart';
import '../../services/nama_profil_akun_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile_widgets.dart';

class ProfilGuru extends StatelessWidget {
  const ProfilGuru({required this.user, super.key});

  final UserModel user;

  static const Color _blue = AppTheme.accent;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      title: const Text('Profil Guru'),
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.onPrimary,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        ProfileHeader(
          name: NamaProfilAkunService.untukRole(user.role),
          role: 'Guru',
          avatar: _buildPhotoAvatar(context),
          onEditName: () => _editName(context),
        ),
        const SizedBox(height: 26),
        const ProfileSectionTitle(
          title: 'Informasi akun',
          subtitle: 'Username dan peran yang Anda gunakan',
        ),
        const SizedBox(height: 12),
        ProfileInfoCard(
          children: [
            ValueListenableBuilder<String>(
              valueListenable: NamaProfilAkunService.usernameUntukRole(
                user.role,
              ),
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
              icon: Icons.badge_outlined,
              label: 'Peran',
              value: 'Guru',
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
      text: NamaProfilAkunService.untukRole(user.role).value,
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Nama Profil'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nama guru'),
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
      await NamaProfilAkunService.ubahNama(user.role, newName);
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

  Future<void> _editUsername(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text: NamaProfilAkunService.usernameUntukRole(user.role).value,
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
      await NamaProfilAkunService.ubahUsername(user.role, newUsername);
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
