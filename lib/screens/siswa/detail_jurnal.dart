import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DetailJurnal extends StatelessWidget {
  const DetailJurnal({
    required this.date,
    required this.activity,
    required this.status,
    super.key,
  });

  final String date;
  final String activity;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Jurnal')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 12),
            Text(
              activity,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Status: $status'),
          ],
        ),
      ),
    );
  }
}
