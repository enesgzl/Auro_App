import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';

class VerticalEnergySlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VerticalEnergySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<VerticalEnergySlider> createState() => _VerticalEnergySliderState();
}

class _VerticalEnergySliderState extends State<VerticalEnergySlider> {
  // Constants for fixed calculation and visual consistency
  static const double _sliderHeight = 350.0;
  static const double _sliderWidth = 100.0;
  static const double _thumbSize = 80.0;

  String _getEmoji(double value) {
    if (value < 0.3) return '😴';
    if (value < 0.7) return '🙂';
    return '🚀';
  }

  void _handleUpdate(Offset localPosition) {
    // Calculate new value based on vertical position (inverted because dy=0 is top)
    double newValue = 1.0 - (localPosition.dy / _sliderHeight).clamp(0.0, 1.0);
    if (newValue != widget.value) {
      widget.onChanged(newValue);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getEmoji(widget.value);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (details) => _handleUpdate(details.localPosition),
      onVerticalDragUpdate: (details) => _handleUpdate(details.localPosition),
      onTapDown: (details) => _handleUpdate(details.localPosition),
      child: SizedBox(
        width: _sliderWidth,
        height: _sliderHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Track Background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),

            // Filled part (Dynamic height)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                height: _sliderHeight * widget.value,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Sliding Thumb
            Positioned(
              bottom: (_sliderHeight * widget.value) - (_thumbSize / 2),
              child: IgnorePointer(
                child: GlassmorphicContainer(
                  width: _thumbSize,
                  height: _thumbSize,
                  borderRadius: _thumbSize / 2,
                  blur: 15,
                  alignment: Alignment.center,
                  border: 1.5,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.2),
                    ],
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
