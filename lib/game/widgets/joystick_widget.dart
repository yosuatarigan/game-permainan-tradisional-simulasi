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
    with SingleTickerProviderStateMixin {
  
  Offset _knobPosition = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isDragging = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isEnabled) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Calculate knob position relative to center
    Offset delta = localPosition - center;
    final distance = delta.distance;
    final maxDistance = widget.size / 2 - 15; // Keep knob inside boundary

    // Limit knob movement to joystick boundary
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
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isEnabled) return;

    setState(() {
      _knobPosition = Offset.zero;
      _isDragging = false;
    });
    _animationController.reverse();
    
    // Stop player movement
    widget.onMove(Offset.zero);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
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
                  color: widget.color.withOpacity(0.1),
                  border: Border.all(
                    color: widget.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Joystick base circles
                    Center(
                      child: Container(
                        width: widget.size * 0.8,
                        height: widget.size * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color.withOpacity(0.05),
                          border: Border.all(
                            color: widget.color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    // Directional indicators
                    _buildDirectionIndicator(0, -widget.size / 3, Icons.keyboard_arrow_up),
                    _buildDirectionIndicator(0, widget.size / 3, Icons.keyboard_arrow_down),
                    _buildDirectionIndicator(-widget.size / 3, 0, Icons.keyboard_arrow_left),
                    _buildDirectionIndicator(widget.size / 3, 0, Icons.keyboard_arrow_right),
                    
                    // Movable knob
                    AnimatedPositioned(
                      duration: _isDragging 
                          ? Duration.zero 
                          : const Duration(milliseconds: 200),
                      curve: Curves.elasticOut,
                      left: (widget.size / 2) + _knobPosition.dx - 15,
                      top: (widget.size / 2) + _knobPosition.dy - 15,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color,
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.4),
                              blurRadius: _isDragging ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.control_camera,
                          color: Colors.white,
                          size: 16,
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

  Widget _buildDirectionIndicator(double dx, double dy, IconData icon) {
    final opacity = _isDragging && _isInDirection(dx, dy) ? 0.8 : 0.3;
    
    return Positioned(
      left: (widget.size / 2) + dx - 10,
      top: (widget.size / 2) + dy - 10,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: opacity,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: widget.color,
            size: 14,
          ),
        ),
      ),
    );
  }

  bool _isInDirection(double dx, double dy) {
    if (!_isDragging || _knobPosition.distance < 10) return false;
    
    final angle = atan2(_knobPosition.dy, _knobPosition.dx);
    final targetAngle = atan2(dy, dx);
    final angleDiff = (angle - targetAngle).abs();
    
    return angleDiff < pi / 4 || angleDiff > 7 * pi / 4;
  }
}