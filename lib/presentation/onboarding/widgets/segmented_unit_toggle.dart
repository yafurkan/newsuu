import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Birim seçimi için segmented toggle bileşeni
/// Örnek: ["kg", "lb"] veya ["cm", "ft, inç"]
class SegmentedUnitToggle extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const SegmentedUnitToggle({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.padding,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final isSelected = index == selectedIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index != selectedIndex) {
                  // Hafif haptic feedback
                  HapticFeedback.selectionClick();
                  onChanged(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? theme.primaryColor
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: isSelected 
                        ? Colors.white
                        : isDark ? Colors.grey[300] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    child: Text(
                      segment,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Özel segmented toggle - daha fazla özelleştirme seçeneği ile
class CustomSegmentedToggle<T> extends StatelessWidget {
  final List<T> values;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;
  final Widget Function(T)? iconBuilder;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;

  const CustomSegmentedToggle({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.onChanged,
    required this.labelBuilder,
    this.iconBuilder,
    this.padding,
    this.height = 48,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultSelectedColor = selectedColor ?? theme.primaryColor;
    final defaultUnselectedColor = unselectedColor ?? 
      (isDark ? Colors.grey[800] : Colors.grey[200]);
    
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: defaultUnselectedColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.map((value) {
          final isSelected = value == selectedValue;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (value != selectedValue) {
                  HapticFeedback.selectionClick();
                  onChanged(value);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? defaultSelectedColor
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: defaultSelectedColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (iconBuilder != null) ...[
                        iconBuilder!(value),
                        const SizedBox(width: 8),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: isSelected 
                          ? (selectedTextStyle ?? theme.textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ))
                          : (unselectedTextStyle ?? theme.textTheme.titleMedium!.copyWith(
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            )),
                        child: Text(
                          labelBuilder(value),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
