import 'package:flutter/material.dart';

/// Onboarding adım progress göstergesi
class StepProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double spacing;
  final bool showNumbers;
  final TextStyle? numberTextStyle;

  const StepProgress({
    super.key,
    required this.current,
    required this.total,
    this.activeColor,
    this.inactiveColor,
    this.height = 4,
    this.spacing = 8,
    this.showNumbers = false,
    this.numberTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultActiveColor = activeColor ?? theme.primaryColor;
    final defaultInactiveColor = inactiveColor ?? 
      (isDark ? Colors.grey[700] : Colors.grey[300]);

    if (showNumbers) {
      return _buildNumberedProgress(
        context, 
        defaultActiveColor, 
        defaultInactiveColor!,
      );
    } else {
      return _buildBarProgress(
        context, 
        defaultActiveColor, 
        defaultInactiveColor!,
      );
    }
  }

  Widget _buildBarProgress(
    BuildContext context, 
    Color activeColor, 
    Color inactiveColor,
  ) {
    return Column(
      children: [
        // Progress bar
        Container(
          height: height,
          decoration: BoxDecoration(
            color: inactiveColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final progress = current / total;
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: constraints.maxWidth * progress,
                    height: height,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Adım metni
        Text(
          '$current / $total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[400] 
              : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberedProgress(
    BuildContext context, 
    Color activeColor, 
    Color inactiveColor,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      children: List.generate(total, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= current;
        final isCompleted = stepNumber < current;
        
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : inactiveColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            stepNumber.toString(),
                            style: numberTextStyle ?? theme.textTheme.titleSmall?.copyWith(
                              color: isActive ? Colors.white : 
                                (theme.brightness == Brightness.dark 
                                  ? Colors.grey[400] 
                                  : Colors.grey[600]),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              if (index < total - 1)
                SizedBox(width: spacing),
            ],
          ),
        );
      }),
    );
  }
}

/// Dot style progress göstergesi
class DotStepProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;

  const DotStepProgress({
    super.key,
    required this.current,
    required this.total,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultActiveColor = activeColor ?? theme.primaryColor;
    final defaultInactiveColor = inactiveColor ?? 
      (isDark ? Colors.grey[600] : Colors.grey[400]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index < current;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? dotSize * 2 : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? defaultActiveColor : defaultInactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}

/// Çizgi style progress göstergesi
class LineStepProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color? activeColor;
  final Color? inactiveColor;
  final double lineHeight;
  final double spacing;
  final List<String>? stepLabels;

  const LineStepProgress({
    super.key,
    required this.current,
    required this.total,
    this.activeColor,
    this.inactiveColor,
    this.lineHeight = 4,
    this.spacing = 4,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultActiveColor = activeColor ?? theme.primaryColor;
    final defaultInactiveColor = inactiveColor ?? 
      (isDark ? Colors.grey[700] : Colors.grey[300]);

    return Column(
      children: [
        Row(
          children: List.generate(total, (index) {
            final isActive = index < current;
            
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: lineHeight,
                      decoration: BoxDecoration(
                        color: isActive ? defaultActiveColor : defaultInactiveColor,
                        borderRadius: BorderRadius.circular(lineHeight / 2),
                      ),
                    ),
                  ),
                  if (index < total - 1)
                    SizedBox(width: spacing),
                ],
              ),
            );
          }),
        ),
        
        if (stepLabels != null) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(total, (index) {
              final isActive = index < current;
              final label = index < stepLabels!.length ? stepLabels![index] : '';
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isActive 
                            ? defaultActiveColor
                            : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (index < total - 1)
                      SizedBox(width: spacing),
                  ],
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Animasyonlu progress göstergesi
class AnimatedStepProgress extends StatefulWidget {
  final int current;
  final int total;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedStepProgress({
    super.key,
    required this.current,
    required this.total,
    this.activeColor,
    this.inactiveColor,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedStepProgress> createState() => _AnimatedStepProgressState();
}

class _AnimatedStepProgressState extends State<AnimatedStepProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.current / widget.total,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedStepProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.current != oldWidget.current) {
      _animation = Tween<double>(
        begin: _previousStep / widget.total,
        end: widget.current / widget.total,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ));
      _previousStep = oldWidget.current;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final activeColor = widget.activeColor ?? theme.primaryColor;
    final inactiveColor = widget.inactiveColor ?? 
      (isDark ? Colors.grey[700] : Colors.grey[300]);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 4,
          decoration: BoxDecoration(
            color: inactiveColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * _animation.value,
                    height: 4,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
