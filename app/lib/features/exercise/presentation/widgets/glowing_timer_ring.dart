import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/date_helpers.dart';

class GlowingTimerRing extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final VoidCallback? onTapTime;

  const GlowingTimerRing({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    this.onTapTime,
  });

  @override
  State<GlowingTimerRing> createState() => _GlowingTimerRingState();
}

class _GlowingTimerRingState extends State<GlowingTimerRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRunning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GlowingTimerRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRunning && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = widget.totalSeconds > 0
        ? (widget.remainingSeconds / widget.totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRunning ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(240, 240),
              painter: _RingPainter(progress: progress),
            ),
            GestureDetector(
              onTap: widget.onTapTime,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusBadge(),
                  const SizedBox(height: 8),
                  Text(
                    DateHelpers.formatDuration(widget.remainingSeconds),
                    style: AppTypography.metricValue.copyWith(
                      fontSize: 48,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.onTapTime != null
                        ? 'Toca para cambiar'
                        : (widget.isRunning ? 'Inhala y exhala' : 'En pausa'),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isRunning
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.isRunning ? 'DESCANSO' : 'PAUSADO',
        style: AppTypography.labelSmall.copyWith(
          color: widget.isRunning ? AppColors.primary : AppColors.textMuted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;

    final bgPaint = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, glowPaint);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        colors: [AppColors.primary, AppColors.secondary, AppColors.primary],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
