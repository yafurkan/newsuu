import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Yatay kaydırmalı ruler picker bileşeni
/// Performanslı ve akıcı kaydırma deneyimi sunar
class RulerPicker extends StatefulWidget {
  final double min;
  final double max;
  final double step;
  final double initialValue;
  final String unitLabel;
  final ValueChanged<double> onChanged;
  final double height;
  final Color? indicatorColor;
  final Color? scaleColor;
  final TextStyle? valueTextStyle;
  final TextStyle? unitTextStyle;

  const RulerPicker({
    super.key,
    required this.min,
    required this.max,
    required this.step,
    required this.initialValue,
    required this.unitLabel,
    required this.onChanged,
    this.height = 200,
    this.indicatorColor,
    this.scaleColor,
    this.valueTextStyle,
    this.unitTextStyle,
  });

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker> {
  late ScrollController _scrollController;
  late double _currentValue;
  double? _lastHapticValue;
  
  // Ruler özellikleri
  static const double _itemWidth = 20.0;
  static const double _majorTickHeight = 40.0;
  static const double _minorTickHeight = 20.0;
  static const double _tickWidth = 2.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.min, widget.max);
    
    // Başlangıç pozisyonunu hesapla
    final initialOffset = _valueToOffset(_currentValue);
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    
    // Scroll listener ekle
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Değer dışarıdan değiştirilmişse scroll pozisyonunu güncelle
    if (widget.initialValue != oldWidget.initialValue) {
      final newValue = widget.initialValue.clamp(widget.min, widget.max);
      if (newValue != _currentValue) {
        _currentValue = newValue;
        final newOffset = _valueToOffset(_currentValue);
        _scrollController.animateTo(
          newOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Değeri scroll offset'ine çevir
  double _valueToOffset(double value) {
    final steps = (value - widget.min) / widget.step;
    return steps * _itemWidth;
  }

  /// Scroll offset'ini değere çevir
  double _offsetToValue(double offset) {
    final steps = offset / _itemWidth;
    final value = widget.min + (steps * widget.step);
    return value.clamp(widget.min, widget.max);
  }

  /// Scroll dinleyicisi
  void _onScroll() {
    final offset = _scrollController.offset;
    final newValue = _offsetToValue(offset);
    
    // Değer değişmişse güncelle
    if (newValue != _currentValue) {
      setState(() {
        _currentValue = newValue;
      });
      
      // Haptic feedback (sadece tam değerlerde)
      final roundedValue = (newValue / widget.step).round() * widget.step;
      if (_lastHapticValue != roundedValue) {
        _lastHapticValue = roundedValue;
        HapticFeedback.selectionClick();
      }
      
      widget.onChanged(newValue);
    }
  }

  /// Toplam item sayısını hesapla
  int get _totalItems {
    return ((widget.max - widget.min) / widget.step).round() + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final indicatorColor = widget.indicatorColor ?? theme.primaryColor;
    final scaleColor = widget.scaleColor ?? 
      (isDark ? Colors.grey[400] : Colors.grey[600]);
    
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          // Değer göstergesi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatValue(_currentValue),
                  style: widget.valueTextStyle ?? theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.unitLabel,
                  style: widget.unitTextStyle ?? theme.textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Ruler
          Expanded(
            child: Stack(
              children: [
                // Scroll edilebilir ruler
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 2 - _itemWidth / 2,
                  ),
                  child: CustomPaint(
                    size: Size(_totalItems * _itemWidth, _majorTickHeight),
                    painter: _RulerPainter(
                      min: widget.min,
                      max: widget.max,
                      step: widget.step,
                      itemWidth: _itemWidth,
                      majorTickHeight: _majorTickHeight,
                      minorTickHeight: _minorTickHeight,
                      tickWidth: _tickWidth,
                      scaleColor: scaleColor!,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: scaleColor,
                      ) ?? TextStyle(color: scaleColor),
                    ),
                  ),
                ),
                
                // Merkez göstergesi (kırmızı çizgi)
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: indicatorColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Değeri formatla
  String _formatValue(double value) {
    if (widget.step >= 1) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }
}

/// Ruler çizimi için custom painter
class _RulerPainter extends CustomPainter {
  final double min;
  final double max;
  final double step;
  final double itemWidth;
  final double majorTickHeight;
  final double minorTickHeight;
  final double tickWidth;
  final Color scaleColor;
  final TextStyle textStyle;

  _RulerPainter({
    required this.min,
    required this.max,
    required this.step,
    required this.itemWidth,
    required this.majorTickHeight,
    required this.minorTickHeight,
    required this.tickWidth,
    required this.scaleColor,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = scaleColor
      ..strokeWidth = tickWidth
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    double currentValue = min;
    int index = 0;

    while (currentValue <= max) {
      final x = index * itemWidth + itemWidth / 2;
      
      // Major tick (her 5. değerde) veya minor tick
      final isMajorTick = (currentValue - min) % (step * 5) == 0;
      final tickHeight = isMajorTick ? majorTickHeight : minorTickHeight;
      
      // Tick çiz
      canvas.drawLine(
        Offset(x, size.height - tickHeight),
        Offset(x, size.height),
        paint,
      );
      
      // Major tick'lerde değer yaz
      if (isMajorTick) {
        final valueText = step >= 1 
          ? currentValue.toInt().toString()
          : currentValue.toStringAsFixed(1);
          
        textPainter.text = TextSpan(
          text: valueText,
          style: textStyle,
        );
        textPainter.layout();
        
        textPainter.paint(
          canvas,
          Offset(
            x - textPainter.width / 2,
            size.height - majorTickHeight - textPainter.height - 4,
          ),
        );
      }
      
      currentValue += step;
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dual ruler picker (feet + inches için)
class DualRulerPicker extends StatefulWidget {
  final int minFeet;
  final int maxFeet;
  final int initialFeet;
  final int initialInches;
  final ValueChanged<Map<String, int>> onChanged;
  final double height;

  const DualRulerPicker({
    super.key,
    required this.minFeet,
    required this.maxFeet,
    required this.initialFeet,
    required this.initialInches,
    required this.onChanged,
    this.height = 200,
  });

  @override
  State<DualRulerPicker> createState() => _DualRulerPickerState();
}

class _DualRulerPickerState extends State<DualRulerPicker> {
  late int _currentFeet;
  late int _currentInches;

  @override
  void initState() {
    super.initState();
    _currentFeet = widget.initialFeet.clamp(widget.minFeet, widget.maxFeet);
    _currentInches = widget.initialInches.clamp(0, 11);
  }

  void _onFeetChanged(double value) {
    final newFeet = value.round();
    if (newFeet != _currentFeet) {
      setState(() {
        _currentFeet = newFeet;
      });
      widget.onChanged({'feet': _currentFeet, 'inches': _currentInches});
    }
  }

  void _onInchesChanged(double value) {
    final newInches = value.round();
    if (newInches != _currentInches) {
      setState(() {
        _currentInches = newInches;
      });
      widget.onChanged({'feet': _currentFeet, 'inches': _currentInches});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          // Feet picker
          Expanded(
            child: RulerPicker(
              min: widget.minFeet.toDouble(),
              max: widget.maxFeet.toDouble(),
              step: 1,
              initialValue: _currentFeet.toDouble(),
              unitLabel: 'ft',
              onChanged: _onFeetChanged,
              height: widget.height,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Inches picker
          Expanded(
            child: RulerPicker(
              min: 0,
              max: 11,
              step: 1,
              initialValue: _currentInches.toDouble(),
              unitLabel: 'in',
              onChanged: _onInchesChanged,
              height: widget.height,
            ),
          ),
        ],
      ),
    );
  }
}
