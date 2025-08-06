import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';

class BadgeCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const BadgeCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return GestureDetector(
            onTap: () => onCategoryChanged(category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 18,
                    color: isSelected ? AppColors.primary : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getCategoryDisplayName(category),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(target: isSelected ? 1 : 0)
              .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05))
              .then()
              .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3));
        },
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'Tümü';
      case 'water_drinking':
        return 'Su İçme';
      case 'quick_add':
        return 'Hızlı Ekleme';
      case 'consistency':
        return 'Süreklilik';
      case 'special':
        return 'Özel';
      default:
        return category;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'all':
        return Icons.grid_view;
      case 'water_drinking':
        return Icons.water_drop;
      case 'quick_add':
        return Icons.touch_app;
      case 'consistency':
        return Icons.trending_up;
      case 'special':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }
}