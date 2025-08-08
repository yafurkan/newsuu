import 'package:flutter/material.dart';
import '../../data/services/cloud_sync_service.dart';
import '../../data/models/water_intake_model.dart';
import '../../data/models/badge_model.dart';
import '../../core/utils/debug_logger.dart';
import 'badge_provider.dart';
import '../widgets/badges/festival_badge_celebration.dart';
import '../widgets/badges/badge_notification_overlay.dart';
import 'user_provider.dart';

/// Su tüketim verilerini yöneten Provider sınıfı (Firebase entegreli)
class WaterProvider extends ChangeNotifier {
  final CloudSyncService _cloudSyncService;

  // State variables
  List<WaterIntakeModel> _todayIntakes = [];
  double _dailyGoal = 2000.0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;
  
  // Offline queue for pending operations
  final List<Map<String, dynamic>> _pendingOperations = [];

  // Statistics update callback
  Function(double amount, String type, String source)? _onStatsUpdate;
  
  // Badge provider reference
  BadgeProvider? _badgeProvider;
  
  // Context for showing dialogs
  BuildContext? _context;
  
  // User provider for user name
  UserProvider? _userProvider;

  WaterProvider(this._cloudSyncService) {
    _loadTodayIntakes();
  }

  // Setters
  void setStatsUpdateCallback(
    Function(double amount, String type, String source)? callback,
  ) {
    _onStatsUpdate = callback;
  }
  
  /// Badge provider'ı ayarla
  void setBadgeProvider(BadgeProvider badgeProvider) {
    _badgeProvider = badgeProvider;
  }
  
  /// Context'i ayarla (dialog göstermek için)
  void setContext(BuildContext context) {
    _context = context;
  }
  
  /// User provider'ı ayarla
  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  // Getters
  List<WaterIntakeModel> get todayIntakes => _todayIntakes;
  double get dailyGoal => _dailyGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOfflineMode => _isOfflineMode;
  int get pendingOperationsCount => _pendingOperations.length;

  double get todayIntake =>
      _todayIntakes.fold(0.0, (sum, intake) => sum + intake.amount);
  double get progress =>
      dailyGoal > 0 ? (todayIntake / dailyGoal).clamp(0.0, 1.0) : 0.0;
  double get remainingAmount =>
      (dailyGoal - todayIntake).clamp(0.0, double.infinity);
  bool get isGoalCompleted => todayIntake >= dailyGoal;

  /// Bugünün su tüketim verilerini yükle
  Future<void> _loadTodayIntakes() async {
    try {
      _setLoading(true);
      _clearError();

      final today = DateTime.now();
      final intakes = await _cloudSyncService.getDailyWaterIntake(today);

      _todayIntakes = intakes;
      DebugLogger.info(
        '✅ Bugünün su verileri yüklendi: ${_todayIntakes.length} kayıt',
        tag: 'WATER_PROVIDER',
      );

      notifyListeners();
    } catch (e) {
      _setError('Su verileri yüklenirken hata: $e');
      DebugLogger.info(
        '❌ Su verileri yükleme hatası: $e',
        tag: 'WATER_PROVIDER',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Su tüketimi ekle - Hybrid yaklaşım: Optimistic UI + Güvenilir Firebase sync
  Future<void> addWaterIntake(double amount, {String note = ''}) async {
    final now = DateTime.now();
    final intake = WaterIntakeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: now,
      note: note,
    );

    // 1. Anında local state'i güncelle (optimistic update)
    _todayIntakes.add(intake);
    notifyListeners();

    // 2. Statistics'i anında güncelle
    _onStatsUpdate?.call(amount, 'add', 'quick_button');

    // 3. Rozet kontrolü yap (offline'da da çalışır)
    try {
      DebugLogger.info('🏆 Rozet kontrolü başlatılıyor...', tag: 'WATER_PROVIDER');
      await _checkBadgeAchievements(amount);
    } catch (e) {
      DebugLogger.error('Rozet kontrolü hatası: $e', tag: 'WATER_PROVIDER');
    }

    // 4. Firebase'e kaydet - Güvenilir sync ile
    _saveToFirebaseReliably(intake, now);

    DebugLogger.info(
      '✅ Su tüketimi anında eklendi: ${amount}ml (hybrid)',
      tag: 'WATER_PROVIDER',
    );
  }

  /// Güvenilir Firebase sync - Hata durumunda retry yapar
  void _saveToFirebaseReliably(WaterIntakeModel intake, DateTime timestamp) {
    Future.microtask(() async {
      try {
        // Kısa timeout ile Firebase'e kaydet
        await _cloudSyncService.syncDailyWaterIntake(timestamp, _todayIntakes)
            .timeout(const Duration(seconds: 3));

        DebugLogger.success(
          '🔄 Firebase sync başarılı: ${intake.amount}ml',
          tag: 'WATER_PROVIDER',
        );
        
        // Başarılı olursa offline mode'dan çık
        if (_isOfflineMode) {
          _setOfflineMode(false);
          await _processPendingOperations();
        }
      } catch (e) {
        // Hata durumunda offline mode'a geç ve pending'e ekle
        if (_isFirebaseError(e)) {
          _setOfflineMode(true);
          _addToPendingOperations('add_water', {'intake': intake.toJson()});
          
          DebugLogger.warning(
            '📱 Firebase sync hatası, offline mode aktif: ${intake.amount}ml - $e',
            tag: 'WATER_PROVIDER',
          );
        } else {
          DebugLogger.error(
            'Firebase sync kritik hatası: $e',
            tag: 'WATER_PROVIDER',
          );
        }
      }
    });
  }

  /// Su tüketimi sil - Optimistic UI ile
  Future<void> removeWaterIntake(String intakeId) async {
    // Silinecek kaydı bul
    final index = _todayIntakes.indexWhere((intake) => intake.id == intakeId);
    if (index == -1) return;

    final removedIntake = _todayIntakes[index];

    // 1. Anında local state'den sil (optimistic update)
    _todayIntakes.removeAt(index);
    notifyListeners();

    // 2. Statistics'i anında güncelle
    _onStatsUpdate?.call(removedIntake.amount, 'remove', 'manual');

    // 3. Background'da Firebase'i güncelle
    _removeFromFirebaseInBackground(removedIntake, index);

    DebugLogger.info(
      '✅ Su tüketimi anında silindi: ${removedIntake.amount}ml (optimistic)',
      tag: 'WATER_PROVIDER',
    );
  }

  /// Background'da Firebase'den sil - kullanıcı deneyimini etkilemez
  void _removeFromFirebaseInBackground(WaterIntakeModel removedIntake, int originalIndex) {
    Future.microtask(() async {
      try {
        // Firebase'i güncelle - kısa timeout ile
        await _cloudSyncService.syncDailyWaterIntake(
          DateTime.now(),
          _todayIntakes,
        ).timeout(const Duration(seconds: 3));

        DebugLogger.success(
          '🔄 Background Firebase silme başarılı: ${removedIntake.amount}ml',
          tag: 'WATER_PROVIDER',
        );
      } catch (e) {
        // Background hatası - kullanıcıyı rahatsız etme ama kaydı geri ekle
        if (_isFirebaseError(e)) {
          // Silinen kaydı geri ekle
          _todayIntakes.insert(originalIndex, removedIntake);
          notifyListeners();
          
          // Statistics'i geri al
          _onStatsUpdate?.call(removedIntake.amount, 'add', 'restore');
          
          DebugLogger.warning(
            '📱 Background silme hatası, kayıt geri eklendi: ${removedIntake.amount}ml - $e',
            tag: 'WATER_PROVIDER',
          );
        } else {
          DebugLogger.error(
            'Background Firebase silme hatası: $e',
            tag: 'WATER_PROVIDER',
          );
        }
      }
    });
  }

  /// Günlük hedefi güncelle
  Future<void> updateDailyGoal(double newGoal) async {
    try {
      _dailyGoal = newGoal;
      notifyListeners();

      DebugLogger.info(
        '✅ Günlük hedef güncellendi: ${newGoal}ml',
        tag: 'WATER_PROVIDER',
      );
    } catch (e) {
      _setError('Günlük hedef güncellenirken hata: $e');
      DebugLogger.info(
        '❌ Günlük hedef güncelleme hatası: $e',
        tag: 'WATER_PROVIDER',
      );
    }
  }

  /// UserProvider'dan hedef güncelle
  void updateGoalFromUserProvider(double newGoal) {
    if (_dailyGoal != newGoal) {
      _dailyGoal = newGoal;
      notifyListeners();
    }
  }

  /// Verileri yenile
  Future<void> refreshData() async {
    await _loadTodayIntakes();
  }

  /// Gün geçişini kontrol et
  void checkDayTransitionOnResume() {
    final now = DateTime.now();
    if (_todayIntakes.isNotEmpty) {
      final lastIntakeDate = _todayIntakes.last.timestamp;

      // Farklı gün ise verileri yenile
      if (now.day != lastIntakeDate.day ||
          now.month != lastIntakeDate.month ||
          now.year != lastIntakeDate.year) {
        DebugLogger.info(
          '📅 Gün değişti, veriler yenileniyor...',
          tag: 'WATER_PROVIDER',
        );
        _loadTodayIntakes();
      }
    }
  }

  /// Belirli bir tarihteki verileri al
  Future<List<WaterIntakeModel>?> getWaterIntakeForDate(DateTime date) async {
    try {
      return await _cloudSyncService.getDailyWaterIntake(date);
    } catch (e) {
      DebugLogger.info('❌ Tarih verisi alma hatası: $e', tag: 'WATER_PROVIDER');
      return null;
    }
  }

  /// Tarih aralığındaki verileri al
  Future<Map<String, List<WaterIntakeModel>>?> getWaterIntakeRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _cloudSyncService.getWaterIntakeRange(start, end);
    } catch (e) {
      DebugLogger.info(
        '❌ Tarih aralığı verisi alma hatası: $e',
        tag: 'WATER_PROVIDER',
      );
      return null;
    }
  }

  /// Tüm verileri temizle
  Future<void> clearAllData() async {
    try {
      _setLoading(true);
      _clearError();

      _todayIntakes.clear();
      notifyListeners();

      DebugLogger.info('✅ Tüm su verileri temizlendi', tag: 'WATER_PROVIDER');
    } catch (e) {
      _setError('Veriler temizlenirken hata: $e');
      DebugLogger.info('❌ Veri temizleme hatası: $e', tag: 'WATER_PROVIDER');
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcı verilerini temizle (çıkış yapıldığında)
  void clearUserData() {
    _todayIntakes.clear();
    _dailyGoal = 2000.0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
  
  void _setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    notifyListeners();
  }
  
  /// Firebase hatası olup olmadığını kontrol et
  bool _isFirebaseError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('unavailable') ||
           errorString.contains('timeout') ||
           errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('firestore');
  }
  
  /// Pending operations'a ekle
  void _addToPendingOperations(String operation, Map<String, dynamic> data) {
    _pendingOperations.add({
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }
  
  /// Retry mekanizması ile sync
  Future<void> _syncWithRetry(
    Future<void> Function() operation,
    String operationType,
    Map<String, dynamic> data,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelays = [1, 3, 5]; // saniye
    
    while (retryCount < maxRetries) {
      try {
        await operation();
        
        // Başarılı olursa offline mode'dan çık
        if (_isOfflineMode) {
          _setOfflineMode(false);
          await _processPendingOperations();
        }
        return;
      } catch (e) {
        retryCount++;
        
        if (_isFirebaseError(e)) {
          if (retryCount < maxRetries) {
            DebugLogger.info(
              '🔄 Retry ${retryCount}/${maxRetries} - ${retryDelays[retryCount - 1]}s bekliyor...',
              tag: 'WATER_PROVIDER',
            );
            await Future.delayed(Duration(seconds: retryDelays[retryCount - 1]));
          } else {
            // Max retry'a ulaştı, offline mode'a geç
            _setOfflineMode(true);
            _addToPendingOperations(operationType, data);
            DebugLogger.info(
              '📱 Max retry ulaşıldı, offline mode aktif',
              tag: 'WATER_PROVIDER',
            );
            return;
          }
        } else {
          // Firebase hatası değilse direkt throw et
          rethrow;
        }
      }
    }
  }
  
  /// Pending operations'ları işle
  Future<void> _processPendingOperations() async {
    if (_pendingOperations.isEmpty) return;
    
    DebugLogger.info(
      '🔄 ${_pendingOperations.length} pending operation işleniyor...',
      tag: 'WATER_PROVIDER',
    );
    
    final operationsToProcess = List.from(_pendingOperations);
    _pendingOperations.clear();
    
    for (final operation in operationsToProcess) {
      try {
        switch (operation['operation']) {
          case 'add_water':
            final intakeData = operation['data']['intake'];
            await _cloudSyncService.syncDailyWaterIntake(
              DateTime.now(),
              _todayIntakes,
            );
            break;
          // Diğer operasyonlar buraya eklenebilir
        }
      } catch (e) {
        // Hala hata varsa tekrar pending'e ekle
        _pendingOperations.add(operation);
        DebugLogger.error(
          'Pending operation işlenirken hata: $e',
          tag: 'WATER_PROVIDER',
        );
      }
    }
    
    notifyListeners();
  }
  
  /// Manuel sync tetikle
  Future<void> forceSyncPendingOperations() async {
    if (_isOfflineMode && _pendingOperations.isNotEmpty) {
      try {
        await _processPendingOperations();
        if (_pendingOperations.isEmpty) {
          _setOfflineMode(false);
        }
      } catch (e) {
        DebugLogger.error(
          'Manuel sync hatası: $e',
          tag: 'WATER_PROVIDER',
        );
      }
    }
  }
  
  /// Rozet başarılarını kontrol et
  Future<void> _checkBadgeAchievements(double addedAmount) async {
    if (_badgeProvider == null) return;
    
    try {
      // Buton kullanım istatistiklerini hesapla (basit implementasyon)
      final buttonUsage = <String, int>{
        '250': _todayIntakes.where((i) => i.amount == 250).length,
        '500': _todayIntakes.where((i) => i.amount == 500).length,
        '750': _todayIntakes.where((i) => i.amount == 750).length,
        '1000': _todayIntakes.where((i) => i.amount == 1000).length,
      };
      
      // Ardışık gün sayısını hesapla (basit implementasyon - gerçekte daha karmaşık olmalı)
      final consecutiveDays = await _calculateConsecutiveDays();
      
      final newBadges = await _badgeProvider!.checkWaterAdditionBadges(
        amount: addedAmount.toInt(),
        dailyTotal: todayIntake.toInt(),
        dailyGoal: dailyGoal.toInt(),
        consecutiveDays: consecutiveDays,
        buttonUsage: buttonUsage,
      );
      
      // Yeni rozetler varsa festival kutlaması göster
      if (newBadges.isNotEmpty) {
        DebugLogger.success(
          'Yeni rozetler kazanıldı: ${newBadges.map((b) => b.name).join(', ')}',
          tag: 'WATER_PROVIDER',
        );
        
        // Her yeni rozet için önce overlay notification göster
        for (final badge in newBadges) {
          _showBadgeNotificationOverlay(badge);
        }
      }
    } catch (e) {
      DebugLogger.error('Rozet kontrolü hatası: $e', tag: 'WATER_PROVIDER');
    }
  }
  
  /// Ardışık gün sayısını hesapla (basit implementasyon)
  Future<int> _calculateConsecutiveDays() async {
    try {
      // Son 30 günü kontrol et
      final now = DateTime.now();
      int consecutiveDays = 0;
      
      for (int i = 0; i < 30; i++) {
        final checkDate = now.subtract(Duration(days: i));
        final dayIntakes = await getWaterIntakeForDate(checkDate);
        
        if (dayIntakes != null && dayIntakes.isNotEmpty) {
          consecutiveDays++;
        } else {
          break;
        }
      }
      
      return consecutiveDays;
    } catch (e) {
      DebugLogger.error('Ardışık gün hesaplama hatası: $e', tag: 'WATER_PROVIDER');
      return 1; // En az bugün var
    }
  }
  
  /// Overlay notification göster
  void _showBadgeNotificationOverlay(BadgeModel badge) {
    DebugLogger.info('🎊 Overlay notification gösteriliyor: ${badge.name}', tag: 'WATER_PROVIDER');
    
    if (_context == null || !_context!.mounted) {
      DebugLogger.warning('❌ Context null veya unmounted!', tag: 'WATER_PROVIDER');
      return;
    }
    
    try {
      // Overlay'in mevcut olup olmadığını kontrol et
      final overlay = Overlay.maybeOf(_context!);
      if (overlay == null) {
        DebugLogger.warning('❌ Overlay widget bulunamadı, direkt festival kutlaması gösteriliyor', tag: 'WATER_PROVIDER');
        // Overlay yoksa direkt festival kutlaması göster
        _showFestivalCelebration(badge);
        return;
      }
      
      // Overlay entry oluştur
      late OverlayEntry overlayEntry;
      
      overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: BadgeNotificationOverlay(
            badge: badge,
            onTap: () {
              DebugLogger.info('🎊 Overlay tıklandı, festival kutlaması başlatılıyor', tag: 'WATER_PROVIDER');
              // Overlay'i kapat ve festival kutlaması göster
              overlayEntry.remove();
              _showFestivalCelebration(badge);
            },
            onDismiss: () {
              DebugLogger.info('🎊 Overlay kapatıldı', tag: 'WATER_PROVIDER');
              // Sadece overlay'i kapat
              overlayEntry.remove();
            },
          ),
        ),
      );
      
      // Overlay'i güvenli şekilde göster
      overlay.insert(overlayEntry);
      DebugLogger.success('✅ Overlay başarıyla gösterildi', tag: 'WATER_PROVIDER');
    } catch (e) {
      DebugLogger.error('❌ ❌ Overlay gösterme hatası: $e', tag: 'WATER_PROVIDER');
      // Hata durumunda direkt festival kutlaması göster
      _showFestivalCelebration(badge);
    }
  }
  
  /// Festival kutlaması göster
  void _showFestivalCelebration(BadgeModel badge) {
    if (_context == null || !_context!.mounted) return;
    
    // Biraz gecikme ile dialog göster (animasyonların tamamlanması için)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_context != null && _context!.mounted) {
        showDialog(
          context: _context!,
          barrierDismissible: false,
          builder: (context) => FestivalBadgeCelebration(
            badge: badge,
            userName: _userProvider?.firstName ?? 'Kahraman',
            onContinue: () {
              // Dialog kapandıktan sonra yapılacak işlemler
              DebugLogger.info(
                'Festival kutlaması tamamlandı: ${badge.name}',
                tag: 'WATER_PROVIDER',
              );
            },
          ),
        );
      }
    });
  }
}
