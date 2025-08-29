import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../presentation/providers/statistics_provider.dart';
import '../widgets/stats_period_selector.dart';
import '../widgets/stats_daily_view.dart';
import '../widgets/stats_weekly_view.dart';
import '../widgets/stats_monthly_view.dart';
import '../widgets/stats_performance_view.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Widget'ı bellekte tut

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().initializeStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'İstatistikler',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, child) {
          if (statsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            );
          }

          return Column(
            children: [
              // Header with period selector and navigation
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Period selector
                    StatsPeriodSelector(
                      selectedPeriod: statsProvider.selectedPeriod,
                      onPeriodChanged: (period) {
                        statsProvider.changePeriod(period);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date navigation
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              statsProvider.navigateToPrevious();
                            },
                          ),
                          Text(
                            _formatDateHeader(
                              statsProvider.selectedDate,
                              statsProvider.selectedPeriod,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              if (_canNavigateNext(
                                statsProvider.selectedDate,
                                statsProvider.selectedPeriod,
                              )) {
                                statsProvider.navigateToNext();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => statsProvider.refreshAll(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Main stats view
                            _buildStatsView(statsProvider),
                            const SizedBox(height: 20),

                            // Performance metrics (Lazy loading)
                            if (statsProvider.currentPerformanceMetrics != null)
                              _buildPerformanceSection(statsProvider)
                            else if (statsProvider.isLoadingPerformance)
                              _buildLoadingCard(
                                'Performans metrikleri yükleniyor...',
                              ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsView(StatisticsProvider statsProvider) {
    switch (statsProvider.selectedPeriod) {
      case StatsPeriod.daily:
        return StatsDailyView(
          dailyStats: statsProvider.currentDailyStats,
          isLoading: statsProvider.isLoadingDaily,
        );
      case StatsPeriod.weekly:
        return StatsWeeklyView(
          weeklyStats: statsProvider.currentWeeklyStats,
          isLoading: statsProvider.isLoadingWeekly,
        );
      case StatsPeriod.monthly:
        return StatsMonthlyView(
          monthlyStats: statsProvider.currentMonthlyStats,
          isLoading: statsProvider.isLoadingMonthly,
        );
    }
  }

  String _formatDateHeader(DateTime date, StatsPeriod period) {
    try {
      switch (period) {
        case StatsPeriod.daily:
          if (_isToday(date)) return 'Bugün';
          if (_isYesterday(date)) return 'Dün';
          return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
        case StatsPeriod.weekly:
          final weekStart = _getWeekStart(date);
          final weekEnd = weekStart.add(const Duration(days: 6));
          return '${DateFormat('d MMM', 'tr_TR').format(weekStart)} - ${DateFormat('d MMM', 'tr_TR').format(weekEnd)}';
        case StatsPeriod.monthly:
          return DateFormat('MMMM yyyy', 'tr_TR').format(date);
      }
    } catch (e) {
      // Fallback to basic formatting if locale data is not available
      switch (period) {
        case StatsPeriod.daily:
          if (_isToday(date)) return 'Bugün';
          if (_isYesterday(date)) return 'Dün';
          return '${date.day}/${date.month}/${date.year}';
        case StatsPeriod.weekly:
          final weekStart = _getWeekStart(date);
          final weekEnd = weekStart.add(const Duration(days: 6));
          return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
        case StatsPeriod.monthly:
          return '${date.month}/${date.year}';
      }
    }
  }

  bool _canNavigateNext(DateTime date, StatsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case StatsPeriod.daily:
        return date.isBefore(DateTime(now.year, now.month, now.day));
      case StatsPeriod.weekly:
        final weekStart = _getWeekStart(date);
        final currentWeekStart = _getWeekStart(now);
        return weekStart.isBefore(currentWeekStart);
      case StatsPeriod.monthly:
        return date.isBefore(DateTime(now.year, now.month));
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Performans bölümü widget'ı
  Widget _buildPerformanceSection(StatisticsProvider statsProvider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: StatsPerformanceView(
        performanceMetrics: statsProvider.currentPerformanceMetrics!,
      ),
    );
  }

  /// Loading kartı widget'ı
  Widget _buildLoadingCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
