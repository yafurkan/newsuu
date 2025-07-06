import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/water_provider.dart';
import '../presentation/widgets/water_progress_card.dart';
import '../presentation/widgets/quick_add_buttons.dart';
import '../presentation/widgets/today_intake_list.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WaterProvider>().refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Takip'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, WaterProvider>(
        builder: (context, userProvider, waterProvider, child) {
          if (userProvider.isLoading || waterProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hoş geldin mesajı
                Text(
                  'Merhaba, ${userProvider.firstName}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Su ilerleme kartı
                const WaterProgressCard(),
                const SizedBox(height: 16),

                // Hızlı ekleme butonları
                const QuickAddButtons(),
                const SizedBox(height: 16),

                // Bugünkü alım listesi
                const Text(
                  'Bugünkü Su Alımları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const TodayIntakeList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
