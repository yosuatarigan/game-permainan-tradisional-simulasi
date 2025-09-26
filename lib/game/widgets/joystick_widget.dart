// File: lib/game/widgets/joystick_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class JoystickWidget extends StatefulWidget {
  final Function(Offset) onMove;
  final Color color;
  final bool isEnabled;
  final double size;

  const JoystickWidget({
    super.key,
    required this.onMove,
    required this.color,
    this.isEnabled = true,
    this.size = 100.0,
  });

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget>
    with TickerProviderStateMixin {
  
  Offset _knobPosition = Offset.zero;
  bool _isDragging = false;
  double _currentDistance = 0.0;
  
  late AnimationController _pressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isDragging = true;
    });
    _pressAnimationController.forward();
    HapticFeedback.selectionClick();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isEnabled) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Calculate knob position relative to center
    Offset delta = localPosition - center;
    final distance = delta.distance;
    final maxDistance = (widget.size / 2) - 20;

    setState(() {
      _currentDistance = distance;
    });

    // Limit knob movement to joystick boundary with smooth resistance
    if (distance > maxDistance) {
      delta = delta / distance * maxDistance;
    }

    setState(() {
      _knobPosition = delta;
    });

    // Normalize movement for game logic (-1 to 1 range)
    final normalizedMovement = Offset(
      delta.dx / maxDistance,
      delta.dy / maxDistance,
    );

    widget.onMove(normalizedMovement);
    
    // Haptic feedback based on distance
    if (distance > maxDistance * 0.8) {
      HapticFeedback.lightImpact();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isEnabled) return;

    setState(() {
      _knobPosition = Offset.zero;
      _isDragging = false;
      _currentDistance = 0.0;
    });
    _pressAnimationController.reverse();
    
    widget.onMove(Offset.zero);
    HapticFeedback.selectionClick();
  }

  double get _intensity => (_currentDistance / (widget.size / 2)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withOpacity(0.05),
                      widget.color.withOpacity(0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.6, 0.8, 1.0],
                  ),
                  border: Border.all(
                    color: widget.color.withOpacity(
                      widget.isEnabled ? (_isDragging ? 0.6 : 0.3) : 0.15
                    ),
                    width: _isDragging ? 3 : 2,
                  ),
                  boxShadow: [
                    if (_isDragging)
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated pulse ring when not active
                    if (!_isDragging && widget.isEnabled)
                      Center(
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: widget.size * 0.7,
                            height: widget.size * 0.7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.color.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Intensity rings that appear based on pressure
                    if (_isDragging) ...[
                      _buildIntensityRing(0.3, 0.1),
                      _buildIntensityRing(0.5, 0.15),
                      _buildIntensityRing(0.7, 0.2),
                    ],
                    
                    // Center reference dot
                    Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    // Main knob with improved design
                    AnimatedPositioned(
                      duration: _isDragging 
                          ? Duration.zero 
                          : const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      left: (widget.size / 2) + _knobPosition.dx - 20,
                      top: (widget.size / 2) + _knobPosition.dy - 20,
                      child: Transform.scale(
                        scale: 1.0 + (_intensity * 0.1),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                widget.color.withOpacity(0.9),
                                widget.color,
                              ],
                              stops: const [0.3, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(_isDragging ? 0.5 : 0.3),
                                blurRadius: _isDragging ? 10 : 6,
                                offset: Offset(0, _isDragging ? 3 : 2),
                              ),
                              // Inner glow
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 3,
                                offset: const Offset(0, -1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Disabled overlay
                    if (!widget.isEnabled)
                      Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntensityRing(double threshold, double opacity) {
    final shouldShow = _intensity >= threshold;
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: shouldShow ? opacity : 0,
        child: Container(
          width: widget.size * (0.4 + threshold * 0.4),
          height: widget.size * (0.4 + threshold * 0.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}