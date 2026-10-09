import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/admin_data_service.dart';
import '../../services/jurnal_service.dart';

class StatistikAdmin extends StatefulWidget {
  const StatistikAdmin({super.key});

  @override
  State<StatistikAdmin> createState() => _StatistikAdminState();
}

class _StatistikAdminState extends State<StatistikAdmin> {
  static const Color _blue = Color(0xFF1565C0);
  static const Color _ink = Color(0xFF172B4D);
  static const Color _muted = Color(0xFF667085);
  static const Color _line = Color(0xFFE6EBF2);
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
  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  late final List<_DatedJournal> _datedJournals = JurnalService.semuaJurnal
      .map((journal) => _DatedJournal(journal.date, _parseDate(journal.date)))
      .where((entry) => entry.date != null)
      .toList(growable: false);
  late final List<_PklPeriod> _periods = _buildPeriods();
  late _PklPeriod _selectedPeriod = _initialPeriod();

  @override
  Widget build(BuildContext context) {
    final users = AdminDataService.users;
    final journals = JurnalService.semuaJurnal;
    final stats = [
      ('Jumlah Siswa', users.where((user) => user.role == 'siswa').length, Icons.school_outlined),
      ('Jumlah Guru', users.where((user) => user.role == 'guru').length, Icons.co_present_outlined),
      ('Jumlah Kelas', AdminDataService.kelas.length, Icons.class_outlined),
      ('Total Jurnal Kegiatan', journals.length, Icons.menu_book_outlined),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Statistik PKL'),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth >= 720 ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: constraints.maxWidth >= 720 ? 1.45 : 1.3,
                  ),
                  itemBuilder: (context, index) => _SummaryCard(
                    title: stats[index].$1,
                    value: stats[index].$2,
                    icon: stats[index].$3,
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionHeading(
                  title: 'Statistik Kegiatan PKL 3 Bulan',
                  subtitle: 'Jumlah jurnal berdasarkan tanggal kegiatan',
                ),
                const SizedBox(height: 12),
                _MonthlyJournalChart(
                  period: _selectedPeriod,
                  journals: _datedJournals,
                  periods: _periods,
                  onPeriodChanged: (period) =>
                      setState(() => _selectedPeriod = period),
                  shortMonthNames: _shortMonthNames,
                ),
                const SizedBox(height: 28),
                const _SectionHeading(
                  title: 'Kegiatan Berdasarkan Kelas',
                  subtitle: 'Proporsi jurnal kegiatan di setiap kelas',
                ),
                const SizedBox(height: 12),
                for (final className in AdminDataService.kelas)
                  _ClassJournalCount(
                    className: className,
                    count: journals
                        .where(
                          (journal) =>
                              (journal.className ??
                                  AdminDataService.classForStudent(
                                    journal.studentName,
                                  )) ==
                              className,
                        )
                        .length,
                    total: journals.length,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_PklPeriod> _buildPeriods() {
    final endMonths = <DateTime>{
      for (final entry in _datedJournals)
        DateTime(entry.date!.year, entry.date!.month),
      DateTime(DateTime.now().year, DateTime.now().month),
    }.toList()..sort((first, second) => first.compareTo(second));
    return endMonths.map(_PklPeriod.new).toList(growable: false);
  }

  _PklPeriod _initialPeriod() {
    if (_datedJournals.isNotEmpty) {
      final latest = _datedJournals
          .map((entry) => entry.date!)
          .reduce((first, second) => first.isAfter(second) ? first : second);
      return _periods.firstWhere(
        (period) =>
            period.end.year == latest.year && period.end.month == latest.month,
      );
    }
    return _periods.last;
  }

  DateTime? _parseDate(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return DateTime.tryParse(value);

    final day = int.tryParse(parts[0]);
    final year = int.tryParse(parts[2]);
    final month = _monthNames.indexWhere(
      (name) => name.toLowerCase() == parts[1].toLowerCase(),
    );
    if (day == null || year == null || month < 0) {
      return DateTime.tryParse(value);
    }
    final date = DateTime(year, month + 1, day);
    if (date.year != year || date.month != month + 1 || date.day != day) {
      return null;
    }
    return date;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _StatistikAdminState._line),
      boxShadow: const [
        BoxShadow(color: Color(0x080D1B2A), blurRadius: 12, offset: Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FC),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _StatistikAdminState._blue, size: 20),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: _StatistikAdminState._ink,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _StatistikAdminState._muted,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: _StatistikAdminState._ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(color: _StatistikAdminState._muted, fontSize: 13),
      ),
    ],
  );
}

class _DatedJournal {
  const _DatedJournal(this.originalDate, this.date);

  final String originalDate;
  final DateTime? date;
}

class _PklPeriod {
  const _PklPeriod(this.end);

  final DateTime end;

  DateTime get start => DateTime(end.year, end.month - 2);

  String get label =>
      '${_StatistikAdminState._shortMonthNames[start.month - 1]} '
      '${start.year} – '
      '${_StatistikAdminState._shortMonthNames[end.month - 1]} ${end.year}';
}

class _MonthlyJournalChart extends StatelessWidget {
  const _MonthlyJournalChart({
    required this.period,
    required this.journals,
    required this.periods,
    required this.onPeriodChanged,
    required this.shortMonthNames,
  });

  final _PklPeriod period;
  final List<_DatedJournal> journals;
  final List<_PklPeriod> periods;
  final ValueChanged<_PklPeriod> onPeriodChanged;
  final List<String> shortMonthNames;

  @override
  Widget build(BuildContext context) {
    final months = List<DateTime>.generate(
      3,
      (index) => DateTime(period.start.year, period.start.month + index),
    );
    final counts = months
        .map(
          (month) => journals.where((entry) {
            final date = entry.date!;
            return date.year == month.year && date.month == month.month;
          }).length,
        )
        .toList(growable: false);
    final maxY = (counts.reduce((first, second) => first > second ? first : second) + 1)
        .toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _StatistikAdminState._line),
        boxShadow: const [
          BoxShadow(color: Color(0x080D1B2A), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Periode PKL',
                  style: TextStyle(
                    color: _StatistikAdminState._muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DropdownButton<_PklPeriod>(
                value: period,
                underline: const SizedBox.shrink(),
                isDense: true,
                items: periods
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(
                          option.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onPeriodChanged(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 226,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: const Color(0xFFEDF1F6),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= counts.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${counts[index]}',
                            style: const TextStyle(
                              color: _StatistikAdminState._ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: maxY <= 4 ? 1 : (maxY / 4).ceilToDouble(),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: _StatistikAdminState._muted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            '${shortMonthNames[months[index].month - 1]} ${months[index].year}',
                            style: const TextStyle(
                              color: _StatistikAdminState._muted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var index = 0; index < counts.length; index++)
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: counts[index].toDouble(),
                          width: 34,
                          color: _StatistikAdminState._blue,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: const Color(0xFFF1F5FA),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassJournalCount extends StatelessWidget {
  const _ClassJournalCount({
    required this.className,
    required this.count,
    required this.total,
  });

  final String className;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : count / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _StatistikAdminState._line),
        boxShadow: const [
          BoxShadow(color: Color(0x080D1B2A), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                className,
                style: const TextStyle(
                  color: _StatistikAdminState._ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count jurnal',
                style: const TextStyle(
                  color: _StatistikAdminState._muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEAF0F7),
              color: _StatistikAdminState._blue,
            ),
          ),
        ],
      ),
    );
  }
}
