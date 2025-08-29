import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/user_provider.dart';
import '../core/utils/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isFirstSetup;

  const ProfileSetupScreen({super.key, this.isFirstSetup = true});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGender = 'male';
  String _selectedActivityLevel = 'medium';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

    // Firebase'dan gelen "moderate" değerini "medium" ile değiştir
    final activityLevel = userProvider.activityLevel;
    if (activityLevel == 'moderate') {
      _selectedActivityLevel = 'medium';
    } else if (['low', 'medium', 'high'].contains(activityLevel)) {
      _selectedActivityLevel = activityLevel;
    } else {
      _selectedActivityLevel = 'medium'; // default
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

      if (mounted) {
        if (widget.isFirstSetup) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pop();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
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
      appBar: AppBar(
        title: Text(
          widget.isFirstSetup ? 'Profil Kurulumu' : 'Profili Düzenle',
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.isFirstSetup,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isFirstSetup) ...[
                Icon(Icons.person_add, size: 80, color: AppTheme.primaryBlue),
                const SizedBox(height: 16),
                Text(
                  'Hoş Geldiniz!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Günlük su ihtiyacınızı hesaplayabilmek için birkaç bilgiye ihtiyacımız var.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],

              // Ad
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Adınız',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen adınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Soyad
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Soyadınız',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen soyadınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Yaş
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Yaşınız',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                  suffixText: 'yıl',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yaşınızı girin';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'Geçerli bir yaş girin (1-120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Boy
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Boyunuz',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen boyunuzu girin';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height < 50 || height > 250) {
                    return 'Geçerli bir boy girin (50-250 cm)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kilo
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Kilonuz',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kilonuzu girin';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 20 || weight > 300) {
                    return 'Geçerli bir kilo girin (20-300 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cinsiyet
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Cinsiyet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Erkek')),
                  DropdownMenuItem(value: 'female', child: Text('Kadın')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Aktivite Seviyesi
              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: const InputDecoration(
                  labelText: 'Aktivite Seviyesi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'low',
                    child: Text('Düşük (Hareketsiz)'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Orta (Haftada 1-3 gün)'),
                  ),
                  DropdownMenuItem(
                    value: 'high',
                    child: Text('Yüksek (Haftada 3+ gün)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.isFirstSetup ? 'Kurulumu Tamamla' : 'Güncelle',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
