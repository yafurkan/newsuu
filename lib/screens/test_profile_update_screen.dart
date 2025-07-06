import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/water_provider.dart';

class TestProfileUpdateScreen extends StatefulWidget {
  const TestProfileUpdateScreen({super.key});

  @override
  State<TestProfileUpdateScreen> createState() =>
      _TestProfileUpdateScreenState();
}

class _TestProfileUpdateScreenState extends State<TestProfileUpdateScreen> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedActivity = 'medium';

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _ageController.text = userProvider.age.toString();
    _weightController.text = userProvider.weight.toString();
    _heightController.text = userProvider.height.toString();
    _selectedGender = userProvider.gender;
    _selectedActivity = userProvider.activityLevel;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Profil Güncelleme'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<UserProvider, WaterProvider>(
        builder: (context, userProvider, waterProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Mevcut su hedefi göstergesi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Mevcut Su Hedefi'),
                      Text(
                        '${waterProvider.dailyGoal.toInt()}ml',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'UserProvider: ${userProvider.dailyWaterGoal.toInt()}ml',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Form alanları
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Yaş',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Kilo (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Boy (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Cinsiyet',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Erkek')),
                    DropdownMenuItem(value: 'female', child: Text('Kadın')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedActivity,
                  decoration: const InputDecoration(
                    labelText: 'Aktivite Seviyesi',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Düşük')),
                    DropdownMenuItem(value: 'medium', child: Text('Orta')),
                    DropdownMenuItem(value: 'high', child: Text('Yüksek')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedActivity = value!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final age = int.tryParse(_ageController.text) ?? 25;
                      final weight =
                          double.tryParse(_weightController.text) ?? 70.0;
                      final height =
                          double.tryParse(_heightController.text) ?? 170.0;

                      await userProvider.updatePersonalInfo(
                        firstName: userProvider.firstName.isNotEmpty
                            ? userProvider.firstName
                            : 'Test',
                        lastName: userProvider.lastName.isNotEmpty
                            ? userProvider.lastName
                            : 'User',
                        age: age,
                        weight: weight,
                        height: height,
                        gender: _selectedGender,
                        activityLevel: _selectedActivity,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profil güncellendi! Su hedefi otomatik hesaplandı.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Profili Güncelle'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
