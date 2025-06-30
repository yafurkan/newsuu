import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_tracking_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  // Form kontrolleri
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedGender = 'male';
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final age = int.parse(_ageController.text);
      final height = int.parse(_heightController.text);
      
      // Günlük su ihtiyacını hesapla
      final dailyWaterGoal = UserModel.calculateDailyWaterNeed(
        height: height,
        age: age,
        gender: _selectedGender,
      );

      final user = UserModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: age,
        height: height,
        gender: _selectedGender,
        createdAt: DateTime.now(),
        dailyWaterGoal: dailyWaterGoal,
      );

      final provider = Provider.of<WaterTrackingProvider>(context, listen: false);
      await provider.saveUser(user);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // İlerleme çubuğu
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < 2 ? 10 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
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
                    _buildWelcomePage(),
                    _buildPersonalInfoPage(),
                    _buildGoalPage(),
                  ],
                ),
              ),

              // Alt butonlar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: const Text(
                          'Geri',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        if (_currentPage == 2) {
                          _completeOnboarding();
                        } else {
                          _nextPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_currentPage == 2 ? 'Başla' : 'İleri'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 30),
          const Text(
            'Su Takip\'e Hoşgeldiniz!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Günlük su tüketiminizi takip ederek sağlıklı yaşam alışkanlıkları edinin.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Kişisel Bilgileriniz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Ad',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ad boş olamaz';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Soyad',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Soyad boş olamaz';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Yaş',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Yaş boş olamaz';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 120) {
                        return 'Geçerli bir yaş girin';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Boy (cm)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Boy boş olamaz';
                      }
                      final height = int.tryParse(value);
                      if (height == null || height < 50 || height > 250) {
                        return 'Geçerli bir boy girin';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Cinsiyet seçimi
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cinsiyet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Erkek', style: TextStyle(color: Colors.white)),
                          value: 'male',
                          groupValue: _selectedGender,
                          activeColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Kadın', style: TextStyle(color: Colors.white)),
                          value: 'female',
                          groupValue: _selectedGender,
                          activeColor: Colors.white,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPage() {
    int calculatedGoal = 2000;
    
    if (_ageController.text.isNotEmpty && _heightController.text.isNotEmpty) {
      final age = int.tryParse(_ageController.text);
      final height = int.tryParse(_heightController.text);
      
      if (age != null && height != null) {
        calculatedGoal = UserModel.calculateDailyWaterNeed(
          height: height,
          age: age,
          gender: _selectedGender,
        );
      }
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 30),
          const Text(
            'Günlük Su Hedefiniz',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  '${calculatedGoal} ml',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(calculatedGoal / 1000).toStringAsFixed(1)} litre',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bu hedef, kişisel bilgilerinize göre hesaplanmıştır. Daha sonra profil ayarlarından değiştirebilirsiniz.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
