import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/admin_data_service.dart';
import '../../theme/app_theme.dart';

class KelolaUser extends StatefulWidget {
  const KelolaUser({super.key});

  @override
  State<KelolaUser> createState() => _KelolaUserState();
}

class _KelolaUserState extends State<KelolaUser> {
  @override
  Widget build(BuildContext context) {
    final users = AdminDataService.users;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kelola User'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editUser(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah User'),
      ),
      body: users.isEmpty
          ? const Center(child: Text('Belum ada user.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  color: AppTheme.surface,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      '@${user.username} · ${_roleName(user.role)}${user.className == null ? '' : ' · ${user.className}'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _editUser(index: index, user: user);
                        }
                        if (action == 'delete') {
                          _deleteUser(index, user);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Ubah')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _editUser({int? index, UserModel? user}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name ?? '');
    final usernameController = TextEditingController(
      text: user?.username ?? '',
    );
    var role = user?.role ?? 'siswa';
    var className =
        user?.className ??
        (AdminDataService.kelas.isEmpty ? null : AdminDataService.kelas.first);

    final result = await showDialog<UserModel>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(user == null ? 'Tambah User' : 'Ubah User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nama wajib diisi.'
                        : null,
                  ),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Username wajib diisi.'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
                      DropdownMenuItem(value: 'guru', child: Text('Guru')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => role = value ?? 'siswa'),
                  ),
                  if (role == 'siswa' && AdminDataService.kelas.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: AdminDataService.kelas.contains(className)
                          ? className
                          : AdminDataService.kelas.first,
                      decoration: const InputDecoration(labelText: 'Kelas'),
                      items: AdminDataService.kelas
                          .map(
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => className = value,
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(
                  dialogContext,
                  UserModel(
                    name: nameController.text.trim(),
                    username: usernameController.text.trim(),
                    role: role,
                    className: role == 'siswa' ? className : null,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    usernameController.dispose();

    if (result != null && mounted) {
      final duplicate = AdminDataService.users.indexed.any(
        (entry) => entry.$2.username == result.username && entry.$1 != index,
      );
      if (duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username sudah digunakan.')),
        );
        return;
      }
      setState(() {
        if (index == null) {
          AdminDataService.addUser(result);
        } else {
          AdminDataService.updateUser(index, result);
        }
      });
    }
  }

  Future<void> _deleteUser(int index, UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Hapus ${user.name} dari daftar user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => AdminDataService.removeUser(index));
    }
  }

  String _roleName(String role) => switch (role) {
    'siswa' => 'Siswa',
    'guru' => 'Guru',
    _ => 'Admin',
  };
}
