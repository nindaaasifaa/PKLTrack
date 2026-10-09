import 'package:flutter/material.dart';

import '../../services/admin_data_service.dart';
import '../../theme/app_theme.dart';

class KelolaKelas extends StatefulWidget {
  const KelolaKelas({super.key});

  @override
  State<KelolaKelas> createState() => _KelolaKelasState();
}

class _KelolaKelasState extends State<KelolaKelas> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      title: const Text('Kelola Kelas'),
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.onPrimary,
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _editClass(),
      icon: const Icon(Icons.add),
      label: const Text('Tambah Kelas'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var index = 0; index < AdminDataService.kelas.length; index++)
          Card(
            color: AppTheme.surface,
            child: ListTile(
              leading: const Icon(Icons.class_outlined, color: AppTheme.accent),
              title: Text(AdminDataService.kelas[index]),
              trailing: PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    _editClass(
                      index: index,
                      name: AdminDataService.kelas[index],
                    );
                  }
                  if (action == 'delete') {
                    _deleteClass(index);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Ubah')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Future<void> _editClass({int? index, String? name}) async {
    final controller = TextEditingController(text: name ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name == null ? 'Tambah Kelas' : 'Ubah Kelas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Nama kelas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty || !mounted) return;
    final duplicate = AdminDataService.kelas.indexed.any(
      (entry) =>
          entry.$2.toLowerCase() == value.toLowerCase() && entry.$1 != index,
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kelas sudah tersedia.')),
      );
      return;
    }
    setState(() {
      if (index == null) {
        AdminDataService.addClass(value);
      } else {
        AdminDataService.updateClass(index, value);
      }
    });
  }

  Future<void> _deleteClass(int index) async {
    final name = AdminDataService.kelas[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: Text('Hapus kelas $name?'),
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
      setState(() => AdminDataService.removeClass(index));
    }
  }
}
