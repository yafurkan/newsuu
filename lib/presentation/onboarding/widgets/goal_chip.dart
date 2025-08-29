import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hedef seçimi için animasyonlu chip bileşeni
class GoalChip extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isSelected;
  final ValueChanged<String> onToggle;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const GoalChip({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onToggle,
    this.padding,
    this.height,
  });

  @override
  State<GoalChip> createState() => _GoalChipState();
}

class _GoalChipState extends State<GoalChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Başlangıçta seçiliyse animasyonu başlat
    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(GoalChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Seçim durumu değiştiğinde animasyonu güncelle
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.selectionClick();
    widget.onToggle(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              height: widget.height ?? 80,
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? theme.primaryColor.withOpacity(0.1)
                    : (isDark ? Colors.grey[800] : Colors.grey[50]),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isSelected
                      ? theme.primaryColor
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 12 * _glowAnimation.value,
                      offset: const Offset(0, 4),
                    ),
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // İkon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? theme.primaryColor
                          : (isDark ? Colors.grey[700] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Metin içeriği
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.isSelected
                                ? theme.primaryColor
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Seçim göstergesi
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? theme.primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.isSelected
                            ? theme.primaryColor
                            : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Kompakt hedef chip'i (daha küçük boyut için)
class CompactGoalChip extends StatelessWidget {
  final String id;
  final String title;
  final String icon;
  final bool isSelected;
  final ValueChanged<String> onToggle;

  const CompactGoalChip({
    super.key,
    required this.id,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle(id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hedef grid'i - çoklu seçim için
class GoalGrid extends StatelessWidget {
  final List<Map<String, String>> goals;
  final Set<String> selectedGoals;
  final ValueChanged<Set<String>> onSelectionChanged;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  const GoalGrid({
    super.key,
    required this.goals,
    required this.selectedGoals,
    required this.onSelectionChanged,
    this.crossAxisCount = 1,
    this.childAspectRatio = 4.0,
    this.spacing = 12,
  });

  void _onGoalToggle(String goalId) {
    final newSelection = Set<String>.from(selectedGoals);
    if (newSelection.contains(goalId)) {
      newSelection.remove(goalId);
    } else {
      newSelection.add(goalId);
    }
    onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final goalId = goal['id']!;
        
        return GoalChip(
          id: goalId,
          title: goal['title']!,
          description: goal['description']!,
          icon: goal['icon']!,
          isSelected: selectedGoals.contains(goalId),
          onToggle: _onGoalToggle,
        );
      },
    );
  }
}
