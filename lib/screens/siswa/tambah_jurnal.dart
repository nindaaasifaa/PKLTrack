import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/jurnal_model.dart';
import '../../services/jurnal_service.dart';

class TambahJurnal extends StatefulWidget {
  const TambahJurnal({super.key});

  @override
  State<TambahJurnal> createState() => _TambahJurnalState();
}

class _TambahJurnalState extends State<TambahJurnal> {
  static const Color _blue = Color(0xFF1565C0);
  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final _formKey = GlobalKey<FormState>();
  final _activityController = TextEditingController();
  final _imagePicker = ImagePicker();
  DateTime? _selectedDate;
  XFile? _selectedImage;
  bool _isPickingImage = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        title: const Text('Tambah Jurnal'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildDateField(),
              const SizedBox(height: 18),
              _buildActivityField(),
              const SizedBox(height: 18),
              _buildPhotoField(),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveJournal,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Jurnal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return FormField<DateTime>(
      validator: (value) =>
          value == null ? 'Tanggal kegiatan wajib dipilih.' : null,
      builder: (field) => _FormSection(
        title: 'Tanggal Kegiatan',
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _selectDate(field),
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              errorText: field.errorText,
              suffixIcon: const Icon(Icons.calendar_month_outlined),
            ),
            child: Text(
              field.value == null
                  ? 'Pilih tanggal kegiatan'
                  : _formatDate(field.value!),
              style: TextStyle(
                color: field.value == null ? Colors.black54 : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityField() {
    return _FormSection(
      title: 'Kegiatan PKL',
      child: TextFormField(
        controller: _activityController,
        minLines: 5,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Tuliskan kegiatan yang dilakukan hari ini...',
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.all(14),
        ),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Kegiatan PKL wajib diisi.'
            : null,
      ),
    );
  }

  Widget _buildPhotoField() {
    return FormField<XFile>(
      validator: (value) =>
          value == null ? 'Foto dokumentasi wajib dipilih.' : null,
      builder: (field) => _FormSection(
        title: 'Foto Dokumentasi',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (field.value != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(field.value!.path),
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: _isPickingImage ? null : () => _pickImage(field),
              icon: _isPickingImage
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      field.value == null
                          ? Icons.add_photo_alternate_outlined
                          : Icons.edit,
                    ),
              label: Text(
                field.value == null ? 'Pilih Foto dari Galeri' : 'Ganti Foto',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (field.errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: field.value ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      field.didChange(selectedDate);
      _selectedDate = selectedDate;
    }
  }

  Future<void> _pickImage(FormFieldState<XFile> field) async {
    setState(() => _isPickingImage = true);
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        field.didChange(image);
        _selectedImage = image;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto tidak dapat dibuka. Silakan coba lagi.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _saveJournal() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);
    JurnalService.tambahJurnal(
      JurnalModel(
        date: _formatDate(_selectedDate!),
        activity: _activityController.text.trim(),
        status: 'Pending',
        imagePath: _selectedImage?.path,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Jurnal berhasil disimpan')));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
