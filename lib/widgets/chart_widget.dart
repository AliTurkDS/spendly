import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

class ChartWidget extends StatefulWidget {
  final List<TransactionModel> transactions;
  const ChartWidget({super.key, required this.transactions});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  int _touchedIndex = -1;
  bool _showPie = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenses = widget.transactions.where((t) => !t.isIncome).toList();

    Map<String, double> catData = {};
    for (var t in expenses) {
      catData[t.category] = (catData[t.category] ?? 0) + t.amount;
    }
    double total = catData.values.fold(0, (a, b) => a + b);

    final colorList = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFFFFBE0B),
      const Color(0xFFBB8FCE),
      const Color(0xFF00E5A0),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Analytics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    _buildChartToggle(context, true, Icons.pie_chart_rounded, isDark),
                    _buildChartToggle(context, false, Icons.bar_chart_rounded, isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (catData.isEmpty)
            _buildEmptyChart(context, isDark)
          else if (_showPie)
            _buildPieChart(context, catData, total, colorList, isDark)
          else
            _buildBarChart(context, catData, colorList, isDark),
        ],
      ),
    );
  }

  Widget _buildChartToggle(BuildContext context, bool isPie, IconData icon, bool isDark) {
    final isActive = _showPie == isPie;
    final primaryColor = isDark ? AppTheme.accentCyan : AppTheme.lightPrimary;
    return GestureDetector(
      onTap: () => setState(() => _showPie = isPie),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? primaryColor : (isDark ? Colors.white38 : Colors.black.withOpacity(0.38)),
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, double> catData,
      double total, List<Color> colorList, bool isDark) {
    final entries = catData.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 65,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex = response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              sections: entries.asMap().entries.map((e) {
                final index = e.key;
                final entry = e.value;
                final isTouched = index == _touchedIndex;
                final pct = total > 0 ? (entry.value / total * 100) : 0.0;
                final color = colorList[index % colorList.length];

                return PieChartSectionData(
                  value: entry.value,
                  color: color,
                  title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
                  radius: isTouched ? 70 : 58,
                  titleStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  badgeWidget: isTouched ? null : null,
                );
              }).toList(),
            ),
          ),
        ),
        // Center label
        if (_touchedIndex >= 0 && _touchedIndex < catData.length)
          Text(
            catData.keys.toList()[_touchedIndex],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black.withOpacity(0.54),
            ),
          ),
        const SizedBox(height: 20),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: entries.asMap().entries.map((e) {
            final color = colorList[e.key % colorList.length];
            final pct = total > 0 ? (e.value.value / total * 100) : 0.0;
            return GestureDetector(
              onTap: () => setState(() => _touchedIndex = _touchedIndex == e.key ? -1 : e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _touchedIndex == e.key
                      ? color.withOpacity(0.15)
                      : (isDark ? AppTheme.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _touchedIndex == e.key
                        ? color
                        : (isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${e.value.key} ${pct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _touchedIndex == e.key
                            ? color
                            : (isDark ? Colors.white70 : Colors.black.withOpacity(0.54)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, Map<String, double> catData,
      List<Color> colorList, bool isDark) {
    final entries = catData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = entries.first.value * 1.2;

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => isDark ? AppTheme.darkCardElevated : Colors.white,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${entries[groupIndex].key}\nRs.${entries[groupIndex].value.toStringAsFixed(0)}',
                  TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[idx].key.substring(0, entries[idx].key.length > 4 ? 4 : entries[idx].key.length),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white54 : Colors.black.withOpacity(0.45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (val, meta) => Text(
                  val >= 1000 ? '${(val / 1000).toStringAsFixed(0)}K' : val.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
                  ),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (val) => FlLine(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((e) {
            final color = colorList[e.key % colorList.length];
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: color,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 40, color: isDark ? Colors.white12 : Colors.black.withOpacity(0.12)),
            const SizedBox(height: 12),
            Text(
              'No expense data yet',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black.withOpacity(0.38),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
