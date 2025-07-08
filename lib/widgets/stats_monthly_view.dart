import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../data/models/statistics_models.dart';

class StatsMonthlyView extends StatelessWidget {
  final MonthlyStats? monthlyStats;
  final bool isLoading;

  const StatsMonthlyView({
    super.key,
    this.monthlyStats,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
        ),
      );
    }

    if (monthlyStats == null) {
      return _buildNoDataView();
    }

    return Column(
      children: [
        // Main stats card
        _buildMainStatsCard(),
        const SizedBox(height: 16),

        // Achievement breakdown
        _buildAchievementBreakdown(),
        const SizedBox(height: 16),

        // Monthly trend chart
        _buildMonthlyChart(),
        const SizedBox(height: 16),

        // Weekly summary
        _buildWeeklySummary(),
      ],
    );
  }

  Widget _buildNoDataView() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Bu ay için veri yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aylık istatistikler su tüketimi\nkaydedilmeye başlandığında görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${monthlyStats!.totalWater.toInt()} ml',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Text(
                    'Aylık Toplam',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${monthlyStats!.averageDaily.toInt()} ml',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    'Günlük Ortalama',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'En İyi Gün',
                  '${monthlyStats!.bestDayAmount.toInt()} ml',
                  Icons.star,
                  const Color(0xFFFFD700),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Başarı Oranı',
                  '${monthlyStats!.goalAchievementRate.toInt()}%',
                  Icons.trending_up,
                  monthlyStats!.goalAchievementRate >= 80
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Mükemmel Günler',
                  '${monthlyStats!.perfectDays}',
                  Icons.emoji_events,
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAchievementBreakdown() {
    final totalDays =
        monthlyStats!.perfectDays +
        monthlyStats!.goodDays +
        monthlyStats!.badDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performans Dağılımı',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: monthlyStats!.perfectDays.toDouble(),
                          color: const Color(0xFF4CAF50),
                          title: '${monthlyStats!.perfectDays}',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: monthlyStats!.goodDays.toDouble(),
                          color: const Color(0xFF2196F3),
                          title: '${monthlyStats!.goodDays}',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: monthlyStats!.badDays.toDouble(),
                          color: const Color(0xFFFF9800),
                          title: '${monthlyStats!.badDays}',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (totalDays < 31) // Show empty days
                          PieChartSectionData(
                            value: (31 - totalDays).toDouble(),
                            color: Colors.grey[300]!,
                            title: '${31 - totalDays}',
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                      startDegreeOffset: -90,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildLegendItem(
                      'Mükemmel (100%)',
                      monthlyStats!.perfectDays,
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      'İyi (75%+)',
                      monthlyStats!.goodDays,
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      'Zayıf (<50%)',
                      monthlyStats!.badDays,
                      const Color(0xFFFF9800),
                    ),
                    if (totalDays < 31) ...[
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        'Veri Yok',
                        31 - totalDays,
                        Colors.grey[300]!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(
          '$value gün',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    if (monthlyStats?.weeklyStats == null ||
        monthlyStats!.weeklyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haftalık Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(monthlyStats!.weeklyStats.length, (
                  index,
                ) {
                  final weekStats = monthlyStats!.weeklyStats[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weekStats.totalWater,
                        color: const Color(0xFF2196F3),
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'H${value.toInt() + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Hafta ${group.x + 1}\n${rod.toY.toInt()} ml',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary() {
    if (monthlyStats?.weeklyStats == null ||
        monthlyStats!.weeklyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Haftalık Özet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '${monthlyStats!.weeklyStats.length} hafta',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...monthlyStats!.weeklyStats.asMap().entries.map((entry) {
            final index = entry.key;
            final weekStats = entry.value;
            return _buildWeekItem(index + 1, weekStats);
          }),
        ],
      ),
    );
  }

  Widget _buildWeekItem(int weekNumber, WeeklyStats weekStats) {
    final percentage = weekStats.goalAchievementRate.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: percentage >= 80
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                  : percentage >= 60
                  ? const Color(0xFF2196F3).withValues(alpha: 0.1)
                  : const Color(0xFFFF9800).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                'H$weekNumber',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: percentage >= 80
                      ? const Color(0xFF4CAF50)
                      : percentage >= 60
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFFF9800),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weekStats.totalWater.toInt()} ml',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Günlük ort: ${weekStats.averageDaily.toInt()} ml',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: percentage >= 80
                      ? const Color(0xFF4CAF50)
                      : percentage >= 60
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFFF9800),
                ),
              ),
              Icon(
                percentage >= 80
                    ? Icons.trending_up
                    : percentage >= 60
                    ? Icons.trending_flat
                    : Icons.trending_down,
                size: 16,
                color: percentage >= 80
                    ? const Color(0xFF4CAF50)
                    : percentage >= 60
                    ? const Color(0xFF2196F3)
                    : const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
