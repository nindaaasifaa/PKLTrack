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
    final result = await showDialog<UserModel>(
      context: context,
      builder: (_) => _UserFormDialog(user: user),
    );

    if (result != null && mounted) {
      final duplicate = AdminDataService.users.indexed.any(
        (entry) =>
            entry.$2.username.toLowerCase() == result.username.toLowerCase() &&
            entry.$1 != index,
      );
      if (duplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username sudah digunakan.')),
        );
        return;
      }
      try {
        if (index == null) {
          await AdminDataService.addUser(result);
        } else {
          await AdminDataService.updateUser(index, result);
        }
        if (mounted) setState(() {});
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User gagal disimpan: $error')));
      }
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
      try {
        await AdminDataService.removeUser(index);
        if (mounted) setState(() {});
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User gagal dihapus: $error')));
      }
    }
  }

  String _roleName(String role) => switch (role) {
    'siswa' => 'Siswa',
    'guru' => 'Guru',
    _ => 'Admin',
  };
}

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({this.user});

  final UserModel? user;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late String _role;
  String? _className;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _role = widget.user?.role ?? 'siswa';
    _className =
        widget.user?.className ??
        (AdminDataService.kelas.isEmpty ? null : AdminDataService.kelas.first);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.user == null ? 'Tambah User' : 'Ubah User'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama wajib diisi.'
                  : null,
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Username wajib diisi.'
                  : null,
            ),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
                DropdownMenuItem(value: 'guru', child: Text('Guru')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) => setState(() => _role = value ?? 'siswa'),
            ),
            if (_role == 'siswa' && AdminDataService.kelas.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: AdminDataService.kelas.contains(_className)
                    ? _className
                    : AdminDataService.kelas.first,
                decoration: const InputDecoration(labelText: 'Kelas'),
                items: AdminDataService.kelas
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (value) => _className = value,
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            UserModel(
              name: _nameController.text.trim(),
              username: _usernameController.text.trim(),
              role: _role,
              className: _role == 'siswa' ? _className : null,
            ),
          );
        },
        child: const Text('Simpan'),
      ),
    ],
  );
}
