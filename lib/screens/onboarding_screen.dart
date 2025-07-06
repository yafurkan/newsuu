import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/user_provider.dart';
import '../core/utils/app_theme.dart';
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
  final _weightController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderate';
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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

  Future<void> _finishOnboarding() async {
    // Temel alanların dolu olup olmadığını kontrol et
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _heightController.text.trim().isEmpty ||
        _weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Form alanlarının dolu olduğunu kontrol et
      if (_ageController.text.isEmpty ||
          _heightController.text.isEmpty ||
          _weightController.text.isEmpty) {
        throw Exception('Lütfen tüm alanları doldurun');
      }

      final age = int.parse(_ageController.text);
      final height = int.parse(_heightController.text);
      final weight = double.parse(_weightController.text);

      final provider = Provider.of<UserProvider>(context, listen: false);
      await provider.updatePersonalInfo(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: age,
        weight: weight,
        height: height.toDouble(),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
      );

      await provider.completeFirstTime();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
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
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
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
                        margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
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
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _previousPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Geri'),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_currentPage == 2
                                  ? _finishOnboarding
                                  : _nextPage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(_currentPage == 2 ? 'Başla' : 'İleri'),
                      ),
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
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop, size: 100, color: Colors.white),
          SizedBox(height: 30),
          Text(
            'Su Takip\'e Hoş Geldiniz!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Günlük su ihtiyacınızı takip edelim ve sağlıklı bir yaşam sürelim.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
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

              // Ad Soyad
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

              // Yaş Boy
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

              // Kilo alanı
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Kilo (kg)',
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
                    return 'Kilo boş olamaz';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 300) {
                    return 'Geçerli bir kilo girin';
                  }
                  return null;
                },
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
                            title: const Text(
                              'Erkek',
                              style: TextStyle(color: Colors.white),
                            ),
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
                            title: const Text(
                              'Kadın',
                              style: TextStyle(color: Colors.white),
                            ),
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

              const SizedBox(height: 20),

              // Aktivite seviyesi
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
                      'Aktivite Seviyesi',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      dropdownColor: Colors.blue[800],
                      items: const [
                        DropdownMenuItem(
                          value: 'low',
                          child: Text(
                            'Düşük (Masa başı)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'moderate',
                          child: Text(
                            'Orta (Hafif spor)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'high',
                          child: Text(
                            'Yüksek (Aktif spor)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'very_high',
                          child: Text(
                            'Çok Yüksek (Profesyonel)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityLevel = value!;
                        });
                      },
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

  Widget _buildGoalPage() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.track_changes, size: 80, color: Colors.white),
          SizedBox(height: 30),
          Text(
            'Her Şey Hazır!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Günlük su hedefinizi kişisel bilgilerinize göre hesaplayacağız.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Su içme alışkanlığınızı geliştirmeye başlayalım!',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
