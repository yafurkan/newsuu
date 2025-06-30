import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/calculations.dart';
import '../../providers/user_provider.dart';
import '../../providers/water_provider.dart';
import '../home/home_screen.dart';

/// Kullanıcı profili oluşturma ekranı
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedActivityLevel = 'medium';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty;
      case 1:
        final age = int.tryParse(_ageController.text);
        final weight = double.tryParse(_weightController.text);
        final height = double.tryParse(_heightController.text);
        return age != null &&
            age >= 18 &&
            age <= 100 &&
            weight != null &&
            weight >= 30 &&
            weight <= 300 &&
            height != null &&
            height >= 100 &&
            height <= 250;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _completeSetup() {
    if (!_isCurrentPageValid()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);

    // Kullanıcı bilgilerini kaydet
    userProvider.updatePersonalInfo(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      age: int.parse(_ageController.text),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
    );

    // Günlük su hedefini hesapla
    final dailyGoal = WaterCalculations.calculateDailyWaterNeed(
      weight: double.parse(_weightController.text),
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
    );

    userProvider.setDailyWaterGoal(dailyGoal);
    waterProvider.updateDailyGoal(dailyGoal);
    userProvider.completeOnboarding();

    // Ana ekrana geç
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        title: Text(
          AppStrings.createProfile,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < 2 ? AppDimensions.paddingS : 0,
                    ),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Sayfa içeriği
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPersonalInfoPage(),
                _buildPhysicalInfoPage(),
                _buildActivityLevelPage(),
              ],
            ),
          ),

          // Alt butonlar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                      ),
                      child: const Text(AppStrings.back),
                    ),
                  ),
                if (_currentPage > 0)
                  const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  flex: _currentPage == 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: _isCurrentPageValid() ? _nextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                    ),
                    child: Text(
                      _currentPage == 2
                          ? AppStrings.getStarted
                          : AppStrings.next,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.paddingL),

          Text(
                'Merhaba! 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: AppDimensions.paddingS),

          Text(
                'Size özel su takibi için önce sizi tanıyalım',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
              )
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: AppDimensions.paddingXXL),

          _buildTextField(
            controller: _firstNameController,
            label: AppStrings.firstName,
            icon: Icons.person_outline,
            delay: 400,
          ),

          const SizedBox(height: AppDimensions.paddingL),

          _buildTextField(
            controller: _lastNameController,
            label: AppStrings.lastName,
            icon: Icons.person_outline,
            delay: 600,
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.paddingL),

          Text(
                'Fiziksel Bilgiler 📏',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: AppDimensions.paddingS),

          Text(
                'Günlük su ihtiyacınızı hesaplayabilmemiz için',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
              )
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: AppDimensions.paddingXXL),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ageController,
                  label: AppStrings.age,
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  delay: 400,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(child: _buildGenderSelector()),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: '${AppStrings.weight}',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: TextInputType.number,
                  delay: 600,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: _buildTextField(
                  controller: _heightController,
                  label: '${AppStrings.height}',
                  icon: Icons.height_outlined,
                  keyboardType: TextInputType.number,
                  delay: 800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.paddingL),

          Text(
                'Aktivite Seviyesi 🏃‍♂️',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: AppDimensions.paddingS),

          Text(
                'Günlük aktivite seviyenizi seçin',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 600),
              )
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: AppDimensions.paddingXXL),

          _buildActivityOption(
            value: 'low',
            title: 'Düşük',
            description: 'Masa başı iş, az hareket',
            icon: Icons.chair_outlined,
            delay: 400,
          ),

          const SizedBox(height: AppDimensions.paddingM),

          _buildActivityOption(
            value: 'medium',
            title: 'Orta',
            description: 'Haftalık 2-3 kez spor',
            icon: Icons.directions_walk_outlined,
            delay: 600,
          ),

          const SizedBox(height: AppDimensions.paddingM),

          _buildActivityOption(
            value: 'high',
            title: 'Yüksek',
            description: 'Düzenli spor, aktif yaşam',
            icon: Icons.fitness_center_outlined,
            delay: 800,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required int delay,
  }) {
    return TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: const Duration(milliseconds: 600),
        )
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildGenderSelector() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.gender,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = 'male'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedGender == 'male'
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        border: Border.all(
                          color: _selectedGender == 'male'
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.male,
                            color: _selectedGender == 'male'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.male,
                            style: TextStyle(
                              color: _selectedGender == 'male'
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = 'female'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedGender == 'female'
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        border: Border.all(
                          color: _selectedGender == 'female'
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.female,
                            color: _selectedGender == 'female'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.female,
                            style: TextStyle(
                              color: _selectedGender == 'female'
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 500),
          duration: const Duration(milliseconds: 600),
        )
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActivityOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
    required int delay,
  }) {
    final isSelected = _selectedActivityLevel == value;

    return GestureDetector(
          onTap: () => setState(() => _selectedActivityLevel = value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.textWhite : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.primary, size: 24),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: const Duration(milliseconds: 600),
        )
        .slideX(begin: 0.3, end: 0);
  }
}
