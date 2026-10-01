import 'package:flutter/material.dart';

import '../../models/jurnal_model.dart';
import '../../services/jurnal_service.dart';
import 'detail_jurnal.dart';

class RiwayatJurnal extends StatelessWidget {
	const RiwayatJurnal({super.key});

	@override
	Widget build(BuildContext context) {
		final journals = JurnalService.semuaJurnal;

		return Scaffold(
			backgroundColor: const Color(0xFFF5F7FA),
			appBar: AppBar(
				backgroundColor: const Color(0xFF1565C0),
				foregroundColor: Colors.white,
				title: const Text('Riwayat Jurnal'),
			),
			body: journals.isEmpty
					? const Center(child: Text('Belum ada jurnal.'))
					: ListView.builder(
							padding: const EdgeInsets.all(16),
							itemCount: journals.length,
							itemBuilder: (context, index) => _buildJournalCard(
								context,
								journals[index],
							),
							),
		);
	}

	Widget _buildJournalCard(BuildContext context, JurnalModel journal) {
		final statusColor = switch (journal.status) {
			'Disetujui' => Colors.green.shade700,
			'Ditolak' => Colors.red.shade700,
			_ => Colors.orange.shade800,
		};

		return Card(
			margin: const EdgeInsets.only(bottom: 10),
			color: Colors.white,
			elevation: 0,
			child: ListTile(
				title: Text(journal.activity),
				subtitle: Padding(
					padding: const EdgeInsets.only(top: 6),
					child: Text('${journal.date}  •  ${journal.status}'),
				),
				trailing: Icon(Icons.chevron_right, color: statusColor),
				onTap: () {
					Navigator.push(
						context,
						MaterialPageRoute<void>(
							builder: (_) => DetailJurnal(
								date: journal.date,
								activity: journal.activity,
								status: journal.status,
							),
						),
					);
				},
			),
		);
	}
}
