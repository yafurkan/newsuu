import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../data/models/statistics_models.dart';

class StatsDailyView extends StatelessWidget {
  final DailyStats? dailyStats;
  final bool isLoading;

  const StatsDailyView({super.key, this.dailyStats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
        ),
      );
    }

    if (dailyStats == null) {
      return _buildNoDataView();
    }

    return Column(
      children: [
        // Main stats card
        _buildMainStatsCard(),
        const SizedBox(height: 16),

        // Achievement progress
        _buildAchievementCard(),
        const SizedBox(height: 16),

        // Hourly breakdown chart
        _buildHourlyChart(),
        const SizedBox(height: 16),

        // Water entries timeline
        _buildEntriesTimeline(),
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
          Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Bu gün için veri yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Su tüketimi kaydedilmeye başlandığında\nveriler burada görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard() {
    final percentage = dailyStats!.achievementPercentage.clamp(0.0, 100.0);

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
                    '${dailyStats!.totalWater.toInt()} ml',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Text(
                    'Toplam Su Tüketimi',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage >= 100 ? Colors.green : const Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Hedef',
                  '${dailyStats!.goalWater.toInt()} ml',
                  Icons.flag,
                  const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Kalan',
                  '${(dailyStats!.goalWater - dailyStats!.totalWater).clamp(0, double.infinity).toInt()} ml',
                  Icons.schedule,
                  const Color(0xFFFF9800),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Başarı',
                  '${percentage.toInt()}%',
                  Icons.trending_up,
                  percentage >= 100 ? Colors.green : const Color(0xFF2196F3),
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAchievementCard() {
    final percentage = dailyStats!.achievementPercentage.clamp(0.0, 100.0);
    String message;
    Color messageColor;
    IconData messageIcon;

    if (percentage >= 100) {
      message = 'Tebrikler! Günlük hedefinizi tamamladınız! 🎉';
      messageColor = Colors.green;
      messageIcon = Icons.celebration;
    } else if (percentage >= 75) {
      message = 'Harika gidiyorsunuz! Az kaldı! 💪';
      messageColor = const Color(0xFF4CAF50);
      messageIcon = Icons.thumb_up;
    } else if (percentage >= 50) {
      message = 'İyi başladınız, devam edin! 👍';
      messageColor = const Color(0xFFFF9800);
      messageIcon = Icons.trending_up;
    } else {
      message = 'Hadi başlayalım! Su içmeyi unutmayın! 💧';
      messageColor = const Color(0xFF2196F3);
      messageIcon = Icons.water_drop;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: messageColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: messageColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(messageIcon, color: messageColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: messageColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyChart() {
    if (dailyStats!.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group entries by hour
    Map<int, double> hourlyData = {};
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0.0;
    }

    for (final entry in dailyStats!.entries) {
      final hour = entry.timestamp.hour;
      if (entry.type == 'add') {
        hourlyData[hour] = (hourlyData[hour] ?? 0) + entry.amount;
      } else {
        hourlyData[hour] = (hourlyData[hour] ?? 0) - entry.amount;
      }
    }

    final maxValue = hourlyData.values.isNotEmpty
        ? hourlyData.values.reduce((a, b) => a > b ? a : b)
        : 1.0;

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
            'Saatlik Dağılım',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxValue * 1.2,
                barGroups: List.generate(24, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: hourlyData[index] ?? 0,
                        color: const Color(0xFF2196F3),
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
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
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
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
                        '${group.x}:00\n${rod.toY.toInt()} ml',
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

  Widget _buildEntriesTimeline() {
    if (dailyStats!.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedEntries = List<WaterEntry>.from(dailyStats!.entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
                'Su İçme Geçmişi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '${sortedEntries.length} giriş',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedEntries.take(10).map((entry) => _buildEntryItem(entry)),
          if (sortedEntries.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${sortedEntries.length - 10} daha...',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(WaterEntry entry) {
    final isAdd = entry.type == 'add';
    final time = DateFormat('HH:mm').format(entry.timestamp);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isAdd ? const Color(0xFF4CAF50) : const Color(0xFFFF5722))
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isAdd ? Icons.add : Icons.remove,
              color: isAdd ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isAdd ? '+' : '-'}${entry.amount.toInt()} ml',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isAdd
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5722),
                  ),
                ),
                Text(
                  _getSourceLabel(entry.source),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  String _getSourceLabel(String source) {
    switch (source) {
      case 'quick_button':
        return 'Hızlı Buton';
      case 'manual':
        return 'Manuel Giriş';
      case 'preset':
        return 'Ön Ayar';
      default:
        return 'Bilinmeyen';
    }
  }
}
