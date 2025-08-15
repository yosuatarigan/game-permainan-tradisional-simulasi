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
                  color: widget.color.withOpacity(0.05), // More transparent
                  border: Border.all(
                    color: widget.color.withOpacity(widget.isEnabled ? 0.3 : 0.15),
                    width: 3,
                  ),
                  boxShadow: [
                    if (_isDragging)
                      BoxShadow(
                        color: widget.color.withOpacity(0.2), // More subtle shadow
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Joystick base circles with better visibility
                    Center(
                      child: Container(
                        width: widget.size * 0.8,
                        height: widget.size * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.color.withOpacity(0.03), // More transparent
                          border: Border.all(
                            color: widget.color.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    
                    // Inner guidance circle
                    Center(
                      child: Container(
                        width: widget.size * 0.5,
                        height: widget.size * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: widget.color.withOpacity(0.15), // More transparent
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    // Directional indicators with better feedback
                    _buildDirectionIndicator(0, -widget.size / 3, Icons.keyboard_arrow_up, 'UP'),
                    _buildDirectionIndicator(0, widget.size / 3, Icons.keyboard_arrow_down, 'DOWN'),
                    _buildDirectionIndicator(-widget.size / 3, 0, Icons.keyboard_arrow_left, 'LEFT'),
                    _buildDirectionIndicator(widget.size / 3, 0, Icons.keyboard_arrow_right, 'RIGHT'),
                    
                    // Center dot for reference
                    Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.4), // More transparent
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    // Movable knob with enhanced design
                    AnimatedPositioned(
                      duration: _isDragging 
                          ? Duration.zero 
                          : const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      left: (widget.size / 2) + _knobPosition.dx - 18,
                      top: (widget.size / 2) + _knobPosition.dy - 18,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.4),
                              blurRadius: _isDragging ? 12 : 6,
                              offset:  Offset(0, _isDragging ? 4 : 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.control_camera,
                          color: Colors.white,
                          size: 18,
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
                          color: Colors.grey.withOpacity(0.3), // More transparent
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 24,
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

  Widget _buildDirectionIndicator(double dx, double dy, IconData icon, String direction) {
    final isActive = _isDragging && _isInDirection(dx, dy);
    final opacity = isActive ? 0.9 : 0.3;
    
    return Positioned(
      left: (widget.size / 2) + dx - 12,
      top: (widget.size / 2) + dy - 12,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: opacity,
        child: AnimatedScale(
          scale: isActive ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(isActive ? 0.6 : 0.1), // More transparent
              border: Border.all(
                color: widget.color.withOpacity(isActive ? 1.0 : 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : widget.color.withOpacity(0.7),
              size: 16,
            ),
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