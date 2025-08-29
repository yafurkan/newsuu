import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../data/models/statistics_models.dart';

class StatsWeeklyView extends StatelessWidget {
  final WeeklyStats? weeklyStats;
  final bool isLoading;

  const StatsWeeklyView({super.key, this.weeklyStats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
        ),
      );
    }

    if (weeklyStats == null) {
      return _buildNoDataView();
    }

    return Column(
      children: [
        // Main stats card
        _buildMainStatsCard(),
        const SizedBox(height: 16),

        // Weekly progress chart
        _buildWeeklyChart(),
        const SizedBox(height: 16),

        // Daily breakdown
        _buildDailyBreakdown(),
        const SizedBox(height: 16),

        // Achievement summary
        _buildAchievementSummary(),
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
          Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Bu hafta için veri yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haftalık istatistikler su tüketimi\nkaydedilmeye başlandığında görünecek.',
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
                    '${weeklyStats!.totalWater.toInt()} ml',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Text(
                    'Haftalık Toplam',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weeklyStats!.averageDaily.toInt()} ml',
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
                  '${_getBestDayAmount()} ml',
                  Icons.star,
                  const Color(0xFFFFD700),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Başarı Oranı',
                  '${weeklyStats!.goalAchievementRate.toInt()}%',
                  Icons.trending_up,
                  weeklyStats!.goalAchievementRate >= 80
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Aktif Günler',
                  '${_getActiveDays()}/7',
                  Icons.calendar_today,
                  const Color(0xFF2196F3),
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

  Widget _buildWeeklyChart() {
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
            'Günlük Su Tüketimi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                  },
                ),
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
                        final weekdays = [
                          'Pzt',
                          'Sal',
                          'Çar',
                          'Per',
                          'Cum',
                          'Cmt',
                          'Paz',
                        ];
                        final index = value.toInt();
                        if (index >= 0 && index < weekdays.length) {
                          return Text(
                            weekdays[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getWeeklySpots(),
                    isCurved: true,
                    color: const Color(0xFF2196F3),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF2196F3),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final weekdays = [
                          'Pazartesi',
                          'Salı',
                          'Çarşamba',
                          'Perşembe',
                          'Cuma',
                          'Cumartesi',
                          'Pazar',
                        ];
                        final day = weekdays[spot.x.toInt()];
                        return LineTooltipItem(
                          '$day\n${spot.y.toInt()} ml',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
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

  List<FlSpot> _getWeeklySpots() {
    if (weeklyStats?.dailyStats == null || weeklyStats!.dailyStats.isEmpty) {
      return List.generate(7, (index) => FlSpot(index.toDouble(), 0));
    }

    // dailyStats'dan günlük miktarları çıkar
    final amounts = List.generate(7, (index) {
      if (index < weeklyStats!.dailyStats.length) {
        return weeklyStats!.dailyStats[index].totalWater;
      }
      return 0.0;
    });

    return amounts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  double _getBestDayAmount() {
    if (weeklyStats?.dailyStats == null || weeklyStats!.dailyStats.isEmpty) {
      return 0.0;
    }

    return weeklyStats!.dailyStats
        .map((stats) => stats.totalWater)
        .reduce((a, b) => a > b ? a : b);
  }

  int _getActiveDays() {
    if (weeklyStats?.dailyStats == null) return 0;

    return weeklyStats!.dailyStats
        .where((stats) => stats.totalWater > 0)
        .length;
  }

  Widget _buildDailyBreakdown() {
    if (weeklyStats?.dailyStats == null || weeklyStats!.dailyStats.isEmpty) {
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
            'Günlük Detaylar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...List.generate(7, (index) {
            final weekdays = [
              'Pazartesi',
              'Salı',
              'Çarşamba',
              'Perşembe',
              'Cuma',
              'Cumartesi',
              'Pazar',
            ];
            final amount = index < weeklyStats!.dailyStats.length
                ? weeklyStats!.dailyStats[index].totalWater
                : 0.0;
            return _buildDayItem(weekdays[index], amount);
          }),
        ],
      ),
    );
  }

  Widget _buildDayItem(String day, double amount) {
    final percentage = amount > 0
        ? (amount / 2500 * 100).clamp(0.0, 100.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: percentage >= 100
                        ? const Color(0xFF4CAF50)
                        : percentage >= 75
                        ? const Color(0xFF2196F3)
                        : const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              '${amount.toInt()} ml',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: percentage >= 100
                    ? const Color(0xFF4CAF50)
                    : percentage >= 75
                    ? const Color(0xFF2196F3)
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSummary() {
    final rate = weeklyStats!.goalAchievementRate;
    String message;
    Color messageColor;
    IconData messageIcon;

    if (rate >= 90) {
      message =
          'Muhteşem! Bu hafta neredeyse mükemmel bir performans gösterdiniz! 🏆';
      messageColor = const Color(0xFF4CAF50);
      messageIcon = Icons.emoji_events;
    } else if (rate >= 75) {
      message = 'Harika! Bu hafta çok iyi bir performans sergiledikz! 💪';
      messageColor = const Color(0xFF4CAF50);
      messageIcon = Icons.thumb_up;
    } else if (rate >= 60) {
      message = 'İyi başlangıç! Biraz daha gayret edelim! 👍';
      messageColor = const Color(0xFF2196F3);
      messageIcon = Icons.trending_up;
    } else {
      message = 'Bu hafta daha fazla su içmeye odaklanalım! 💧';
      messageColor = const Color(0xFFFF9800);
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
}
