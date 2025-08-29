import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../presentation/providers/badge_provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../data/models/badge_model.dart';
import '../presentation/widgets/badges/badge_card.dart';
import '../presentation/widgets/badges/badge_stats_card.dart';
import '../presentation/widgets/badges/badge_category_tabs.dart';
import '../presentation/widgets/badges/badge_achievement_dialog.dart';
import '../core/constants/colors.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  void _loadBadges() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final badgeProvider = context.read<BadgeProvider>();
      badgeProvider.loadBadges();
      
      // Kategorileri yükledikten sonra tab controller'ı başlat
      final categories = ['all', ...badgeProvider.categories];
      _tabController = TabController(
        length: categories.length,
        vsync: this,
      );
      
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          setState(() {
            _selectedCategory = categories[_tabController.index];
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.background,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // İstatistik Kartı
              _buildStatsSection(),
              
              // Kategori Tabları
              _buildCategoryTabs(),
              
              // Rozet Listesi
              Expanded(
                child: _buildBadgesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              '🏆 Rozetlerim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _showShareOptions,
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3);
  }

  Widget _buildStatsSection() {
    return Consumer<BadgeProvider>(
      builder: (context, badgeProvider, child) {
        if (badgeProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BadgeStatsCard(stats: badgeProvider.stats),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<BadgeProvider>(
      builder: (context, badgeProvider, child) {
        if (badgeProvider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return BadgeCategoryTabs(
          categories: ['all', ...badgeProvider.categories],
          selectedCategory: _selectedCategory,
          onCategoryChanged: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ).animate().fadeIn(delay: 400.ms);
      },
    );
  }

  Widget _buildBadgesList() {
    return Consumer<BadgeProvider>(
      builder: (context, badgeProvider, child) {
        if (badgeProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Rozetler yükleniyor...'),
              ],
            ),
          );
        }

        if (badgeProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${badgeProvider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => badgeProvider.loadBadges(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        final badges = _getFilteredBadges(badgeProvider);

        if (badges.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedCategory == 'all'
                      ? 'Henüz rozet yok'
                      : 'Bu kategoride rozet yok',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return BadgeCard(
                badge: badge,
                onTap: () => _showBadgeDetails(badge),
              ).animate(delay: (index * 100).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
            },
          ),
        );
      },
    );
  }

  List<BadgeModel> _getFilteredBadges(BadgeProvider badgeProvider) {
    if (_selectedCategory == 'all') {
      return badgeProvider.badges;
    }
    return badgeProvider.getBadgesByCategory(_selectedCategory);
  }

  void _showBadgeDetails(BadgeModel badge) {
    showDialog(
      context: context,
      builder: (context) => BadgeAchievementDialog(
        badge: badge,
        userName: context.read<AuthProvider>().userEmail?.split('@')[0] ?? 'Kullanıcı',
      ),
    );
  }

  void _showShareOptions() {
    final badgeProvider = context.read<BadgeProvider>();
    final authProvider = context.read<AuthProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Paylaşım Seçenekleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.collections, color: AppColors.primary),
              title: const Text('Rozet Koleksiyonumu Paylaş'),
              subtitle: const Text('Tüm rozetlerini sosyal medyada paylaş'),
              onTap: () {
                Navigator.pop(context);
                _shareCollection(badgeProvider, authProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.today, color: AppColors.secondary),
              title: const Text('Bugünkü Başarımı Paylaş'),
              subtitle: const Text('Günlük su takip başarını paylaş'),
              onTap: () {
                Navigator.pop(context);
                _shareDailyAchievement(authProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareCollection(BadgeProvider badgeProvider, AuthProvider authProvider) {
    // Koleksiyon paylaşım implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rozet koleksiyonu paylaşım özelliği yakında!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _shareDailyAchievement(AuthProvider authProvider) {
    // Günlük başarı paylaşım implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Günlük başarı paylaşım özelliği yakında!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
