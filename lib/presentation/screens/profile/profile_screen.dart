import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late TextEditingController _dailyGoalController;
  String _selectedGender = 'Erkek';
  String _selectedActivityLevel = 'Orta';

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.fullName);
    _weightController = TextEditingController(
      text: userProvider.weight > 0 ? userProvider.weight.toString() : '',
    );
    _heightController = TextEditingController(
      text: userProvider.height > 0 ? userProvider.height.toString() : '',
    );
    _ageController = TextEditingController(
      text: userProvider.age > 0 ? userProvider.age.toString() : '',
    );
    _dailyGoalController = TextEditingController(
      text: userProvider.dailyWaterGoal.toString(),
    );

    // Gender dönüştürme
    _selectedGender = userProvider.gender == 'male' ? 'Erkek' : 'Kadın';

    // Activity level dönüştürme
    switch (userProvider.activityLevel.toLowerCase()) {
      case 'low':
      case 'düşük':
        _selectedActivityLevel = 'Düşük';
        break;
      case 'high':
      case 'yüksek':
        _selectedActivityLevel = 'Yüksek';
        break;
      default:
        _selectedActivityLevel = 'Orta';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _dailyGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profil Düzenle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Ad Soyad',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ad soyad gereklidir';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Gender Selection
            _buildDropdownField(
              label: 'Cinsiyet',
              icon: Icons.people_outline,
              value: _selectedGender,
              items: ['Erkek', 'Kadın'],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Age Field
            _buildTextField(
              controller: _ageController,
              label: 'Yaş',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Yaş gereklidir';
                }
                final age = int.tryParse(value);
                if (age == null || age <= 0 || age > 120) {
                  return 'Geçerli bir yaş giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Weight Field
            _buildTextField(
              controller: _weightController,
              label: 'Kilo (kg)',
              icon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kilo gereklidir';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Geçerli bir kilo giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Height Field
            _buildTextField(
              controller: _heightController,
              label: 'Boy (cm)',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Boy gereklidir';
                }
                final height = double.tryParse(value);
                if (height == null || height <= 0) {
                  return 'Geçerli bir boy giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Activity Level
            _buildDropdownField(
              label: 'Aktivite Seviyesi',
              icon: Icons.fitness_center,
              value: _selectedActivityLevel,
              items: ['Düşük', 'Orta', 'Yüksek'],
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Daily Goal Field
            _buildTextField(
              controller: _dailyGoalController,
              label: 'Günlük Hedef (ml)',
              icon: Icons.local_drink,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Günlük hedef gereklidir';
                }
                final goal = int.tryParse(value);
                if (goal == null || goal <= 0) {
                  return 'Geçerli bir hedef giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),

            // Save Button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Profili Kaydet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // İsim ve soyisimi ayır
      final fullName = _nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Aktivite seviyesini dönüştür
      String activityLevel;
      switch (_selectedActivityLevel) {
        case 'Düşük':
          activityLevel = 'low';
          break;
        case 'Yüksek':
          activityLevel = 'high';
          break;
        default:
          activityLevel = 'medium';
      }

      userProvider.updatePersonalInfo(
        firstName: firstName,
        lastName: lastName,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        gender: _selectedGender.toLowerCase() == 'erkek' ? 'male' : 'female',
        activityLevel: activityLevel,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil başarıyla güncellendi'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.pop(context);
    }
  }
}
