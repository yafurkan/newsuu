import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/user_provider.dart';
import '../core/utils/app_theme.dart';

class AnimatedOnboardingScreen extends StatefulWidget {
  final bool isFirstSetup;

  const AnimatedOnboardingScreen({super.key, this.isFirstSetup = true});

  @override
  State<AnimatedOnboardingScreen> createState() => _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState extends State<AnimatedOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _progressController;
  
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedGender = '';
  String _selectedActivityLevel = '';

  final List<String> _stepTitles = [
    'Hoş Geldiniz! 👋',
    'Adınız Nedir? 😊',
    'Yaşınız Kaç? 🎂',
    'Kilonuz Kaç? ⚖️',
    'Boyunuz Kaç? 📏',
    'Cinsiyetiniz? 👫',
    'Aktivite Seviyeniz? 🏃‍♂️',
    'Tamamlandı! 🎉'
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    if (!widget.isFirstSetup) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _firstNameController.text = userProvider.firstName;
    _lastNameController.text = userProvider.lastName;
    _ageController.text = userProvider.age.toString();
    _heightController.text = userProvider.height.toString();
    _weightController.text = userProvider.weight.toString();
    _selectedGender = userProvider.gender;
    
    final activityLevel = userProvider.activityLevel;
    if (activityLevel == 'moderate') {
      _selectedActivityLevel = 'medium';
    } else if (['low', 'medium', 'high'].contains(activityLevel)) {
      _selectedActivityLevel = activityLevel;
    } else {
      _selectedActivityLevel = 'medium';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _progressController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.forward();
      _backgroundController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reverse();
      _backgroundController.reverse();
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: return true; // Welcome screen
      case 1: return _firstNameController.text.trim().isNotEmpty && 
                     _lastNameController.text.trim().isNotEmpty;
      case 2: 
        final age = int.tryParse(_ageController.text);
        return age != null && age >= 1 && age <= 120;
      case 3:
        final weight = double.tryParse(_weightController.text);
        return weight != null && weight >= 20 && weight <= 300;
      case 4:
        final height = double.tryParse(_heightController.text);
        return height != null && height >= 50 && height <= 250;
      case 5: return _selectedGender.isNotEmpty;
      case 6: return _selectedActivityLevel.isNotEmpty;
      default: return false;
    }
  }

  Future<void> _completeOnboarding() async {
    if (!_canProceed()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.updatePersonalInfo(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
      );

      if (widget.isFirstSetup) {
        await userProvider.completeFirstTime();
      }

      // Success animation
      _nextStep();
      
      // Navigate after animation
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (mounted) {
        if (widget.isFirstSetup) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getBackgroundColors(),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(),
              
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomeStep(),
                    _buildNameStep(),
                    _buildAgeStep(),
                    _buildWeightStep(),
                    _buildHeightStep(),
                    _buildGenderStep(),
                    _buildActivityStep(),
                    _buildCompletionStep(),
                  ],
                ),
              ),
              
              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getBackgroundColors() {
    switch (_currentStep) {
      case 0: return [Colors.blue.shade300, Colors.blue.shade600];
      case 1: return [Colors.green.shade300, Colors.green.shade600];
      case 2: return [Colors.orange.shade300, Colors.orange.shade600];
      case 3: return [Colors.purple.shade300, Colors.purple.shade600];
      case 4: return [Colors.teal.shade300, Colors.teal.shade600];
      case 5: return _selectedGender == 'female' 
          ? [Colors.pink.shade300, Colors.pink.shade600]
          : [Colors.blue.shade300, Colors.blue.shade600];
      case 6: return [Colors.red.shade300, Colors.red.shade600];
      case 7: return [Colors.green.shade400, Colors.green.shade700];
      default: return [Colors.blue.shade300, Colors.blue.shade600];
    }
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _stepTitles[_currentStep],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _stepTitles.length,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ).animate().scaleX(duration: 500.ms),
          const SizedBox(height: 8),
          Text(
            '${_currentStep + 1} / ${_stepTitles.length}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop,
            size: 120,
            color: Colors.white,
          ).animate().scale(duration: 800.ms).then().shake(),
          const SizedBox(height: 32),
          const Text(
            'Su Takip Uygulamasına\nHoş Geldiniz!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 16),
          const Text(
            'Günlük su ihtiyacınızı hesaplayabilmek için\nbirkaç bilgiye ihtiyacımız var.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 100,
            color: Colors.white,
          ).animate().scale(duration: 600.ms).then().scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 500.ms).then().scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0), duration: 500.ms),
          const SizedBox(height: 32),
          _buildAnimatedTextField(
            controller: _firstNameController,
            label: 'Adınız',
            icon: Icons.person,
            delay: 200,
          ),
          const SizedBox(height: 16),
          _buildAnimatedTextField(
            controller: _lastNameController,
            label: 'Soyadınız',
            icon: Icons.person_outline,
            delay: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildAgeStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cake,
            size: 100,
            color: Colors.white,
          ).animate().scale(duration: 600.ms).then().rotate(),
          const SizedBox(height: 32),
          _buildAnimatedTextField(
            controller: _ageController,
            label: 'Yaşınız',
            icon: Icons.cake,
            keyboardType: TextInputType.number,
            suffix: 'yıl',
            delay: 200,
          ),
          const SizedBox(height: 16),
          if (_ageController.text.isNotEmpty)
            Text(
              _getAgeMessage(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildWeightStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_weight,
            size: 100,
            color: Colors.white,
          ).animate().scale(duration: 600.ms).then().slideY(begin: -0.1, end: 0.1).then().slideY(begin: 0.1, end: -0.1),
          const SizedBox(height: 32),
          _buildAnimatedTextField(
            controller: _weightController,
            label: 'Kilonuz',
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.number,
            suffix: 'kg',
            delay: 200,
          ),
          const SizedBox(height: 16),
          if (_weightController.text.isNotEmpty)
            Text(
              _getWeightMessage(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildHeightStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.height,
            size: 100,
            color: Colors.white,
          ).animate().scale(duration: 600.ms).then().slideY(begin: 0, end: -0.2).then().slideY(begin: -0.2, end: 0),
          const SizedBox(height: 32),
          _buildAnimatedTextField(
            controller: _heightController,
            label: 'Boyunuz',
            icon: Icons.height,
            keyboardType: TextInputType.number,
            suffix: 'cm',
            delay: 200,
          ),
          const SizedBox(height: 16),
          if (_heightController.text.isNotEmpty)
            Text(
              _getHeightMessage(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Cinsiyetinizi Seçin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildGenderCard(
                  'female',
                  'Kadın',
                  Icons.female,
                  Colors.pink,
                  0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderCard(
                  'male',
                  'Erkek',
                  Icons.male,
                  Colors.blue,
                  200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 100,
            color: Colors.white,
          ).animate().scale(duration: 600.ms).then().rotate(begin: -0.1, end: 0.1).then().rotate(begin: 0.1, end: -0.1),
          const SizedBox(height: 32),
          const Text(
            'Aktivite Seviyenizi Seçin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          _buildActivityCard('low', 'Düşük', 'Hareketsiz yaşam', Icons.airline_seat_recline_normal, 0),
          const SizedBox(height: 12),
          _buildActivityCard('medium', 'Orta', 'Haftada 1-3 gün spor', Icons.directions_walk, 200),
          const SizedBox(height: 12),
          _buildActivityCard('high', 'Yüksek', 'Haftada 3+ gün spor', Icons.directions_run, 400),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 120,
            color: Colors.white,
          ).animate().scale(duration: 800.ms).then().scale(begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2), duration: 600.ms).then().scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0), duration: 600.ms),
          const SizedBox(height: 32),
          const Text(
            'Tebrikler! 🎉',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 16),
          const Text(
            'Profiliniz başarıyla oluşturuldu!\nArtık su takibinize başlayabilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? suffix,
    required int delay,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      onChanged: (value) => setState(() {}),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).slideX(begin: 0.3);
  }

  Widget _buildGenderCard(String value, String title, IconData icon, Color color, int delay) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white70,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected ? color : Colors.white70,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildActivityCard(String value, String title, String subtitle, IconData icon, int delay) {
    final isSelected = _selectedActivityLevel == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedActivityLevel = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.white70,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.orange : Colors.white70,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.orange : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.orange.shade700 : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).slideX(begin: 0.3);
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0 && _currentStep < 7)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Geri', style: TextStyle(fontSize: 16)),
              ),
            ),
          if (_currentStep > 0 && _currentStep < 7) const SizedBox(width: 16),
          if (_currentStep < 7)
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _canProceed() 
                    ? (_currentStep == 6 ? _completeOnboarding : _nextStep)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _getBackgroundColors()[1],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _currentStep == 0 
                            ? 'Başlayalım!' 
                            : _currentStep == 6 
                                ? 'Tamamla' 
                                : 'Devam',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  String _getAgeMessage() {
    final age = int.tryParse(_ageController.text);
    if (age == null) return '';
    if (age < 18) return 'Genç ve enerjik! 🌟';
    if (age < 30) return 'Harika bir yaş! 💪';
    if (age < 50) return 'Deneyimli ve güçlü! 🎯';
    return 'Bilge ve tecrübeli! 🏆';
  }

  String _getWeightMessage() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null) return '';
    return 'Sağlıklı bir kilo! 💚';
  }

  String _getHeightMessage() {
    final height = double.tryParse(_heightController.text);
    if (height == null) return '';
    if (height < 160) return 'Kompakt ve çevik! ⚡';
    if (height < 180) return 'İdeal boy! 📐';
    return 'Uzun ve güçlü! 🗼';
  }
}