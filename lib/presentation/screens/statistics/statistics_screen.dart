import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../providers/water_provider.dart';
import '../../providers/user_provider.dart';

/// İstatistik ekranı - Su içme geçmişi ve analizleri
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 0; // 0: 7 gün, 1: 30 gün, 2: 90 gün

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        title: const Text(
          '📊 İstatistikler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dönem seçici
                _buildPeriodSelector(),

                const SizedBox(height: AppDimensions.spacingLarge),

                // Özet kartlar
                _buildSummaryCards(waterProvider, userProvider),

                const SizedBox(height: AppDimensions.spacingLarge),

                // Grafik
                _buildChart(waterProvider),

                const SizedBox(height: AppDimensions.spacingLarge),

                // Günlük detaylar
                _buildDailyDetails(waterProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildPeriodButton('7 Gün', 0),
          _buildPeriodButton('30 Gün', 1),
          _buildPeriodButton('90 Gün', 2),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.3);
  }

  Widget _buildPeriodButton(String text, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    WaterProvider waterProvider,
    UserProvider userProvider,
  ) {
    final days = _selectedPeriod == 0 ? 7 : (_selectedPeriod == 1 ? 30 : 90);
    final intakes = waterProvider.getIntakesForLastDays(days);

    final totalAmount = intakes.fold<double>(
      0.0,
      (sum, intake) => sum + intake.amount,
    );
    final avgDaily = intakes.isEmpty ? 0.0 : totalAmount / days;
    final targetDaily = userProvider.dailyWaterGoal;
    final achievedDays = _getAchievedDays(waterProvider, days, targetDaily);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            '💧',
            'Toplam',
            '${totalAmount.toInt()} ml',
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        Expanded(
          child: _buildSummaryCard(
            '📈',
            'Günlük Ort.',
            '${avgDaily.toInt()} ml',
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        Expanded(
          child: _buildSummaryCard(
            '🎯',
            'Hedef Tuttu',
            '$achievedDays gün',
            AppColors.success,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.3);
  }

  Widget _buildSummaryCard(
    String icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(WaterProvider waterProvider) {
    final days = _selectedPeriod == 0 ? 7 : (_selectedPeriod == 1 ? 30 : 90);
    final chartData = _getChartData(waterProvider, days);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.spacingSmall),
              Text(
                'Su İçme Grafiği',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              chartData[index].date,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      reservedSize: 42,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}ml',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (chartData.length - 1).toDouble(),
                minY: 0,
                maxY: chartData.isEmpty
                    ? 3000
                    : chartData
                              .map((e) => e.amount)
                              .reduce((a, b) => a > b ? a : b) *
                          1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.amount);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildDailyDetails(WaterProvider waterProvider) {
    final days = _selectedPeriod == 0 ? 7 : (_selectedPeriod == 1 ? 30 : 90);
    final dailyData = _getDailyData(waterProvider, days);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.spacingSmall),
              Text(
                'Günlük Detaylar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          ...dailyData.take(10).map((data) => _buildDailyItem(data)).toList(),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.3);
  }

  Widget _buildDailyItem(DailyData data) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final progress = data.amount / userProvider.dailyWaterGoal;
    final isAchieved = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: isAchieved
            ? AppColors.success.withOpacity(0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: isAchieved
              ? AppColors.success.withOpacity(0.3)
              : AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(isAchieved ? '✅' : '⭕', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.date,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${data.amount.toInt()} ml / ${userProvider.dailyWaterGoal.toInt()} ml',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAchieved ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _getAchievedDays(
    WaterProvider waterProvider,
    int days,
    double targetDaily,
  ) {
    int achieved = 0;
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayIntakes = waterProvider.getIntakesForDate(date);
      final totalAmount = dayIntakes.fold<double>(
        0.0,
        (sum, intake) => sum + intake.amount,
      );
      if (totalAmount >= targetDaily) achieved++;
    }
    return achieved;
  }

  List<ChartData> _getChartData(WaterProvider waterProvider, int days) {
    List<ChartData> data = [];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayIntakes = waterProvider.getIntakesForDate(date);
      final totalAmount = dayIntakes.fold<double>(
        0.0,
        (sum, intake) => sum + intake.amount,
      );

      data.add(
        ChartData(date: '${date.day}/${date.month}', amount: totalAmount),
      );
    }
    return data;
  }

  List<DailyData> _getDailyData(WaterProvider waterProvider, int days) {
    List<DailyData> data = [];
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayIntakes = waterProvider.getIntakesForDate(date);
      final totalAmount = dayIntakes.fold<double>(
        0.0,
        (sum, intake) => sum + intake.amount,
      );

      data.add(DailyData(date: _formatDate(date), amount: totalAmount));
    }
    return data;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDate).inDays;

    switch (difference) {
      case 0:
        return 'Bugün';
      case 1:
        return 'Dün';
      default:
        return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ChartData {
  final String date;
  final double amount;

  ChartData({required this.date, required this.amount});
}

class DailyData {
  final String date;
  final double amount;

  DailyData({required this.date, required this.amount});
}
