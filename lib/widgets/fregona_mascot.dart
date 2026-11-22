import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/casvium_theme.dart';

enum MascotMood {
  happy,
  scrubbing,
  celebrating,
  relaxed,
}

/// Mascota animada de Casvium: "Don Mocho", una fregona humanizada con flecos en movimiento,
/// burbujas de jabón flotantes, parpadeo natural y reacción interactiva al toque.
class FregonaMascotWidget extends StatefulWidget {
  final MascotMood mood;
  final String mascotName;
  final String speechBubble;
  final double size;
  final VoidCallback? onTap;

  const FregonaMascotWidget({
    super.key,
    this.mood = MascotMood.happy,
    this.mascotName = 'Don Mocho',
    required this.speechBubble,
    this.size = 135,
    this.onTap,
  });

  @override
  State<FregonaMascotWidget> createState() => _FregonaMascotWidgetState();
}

class _FregonaMascotWidgetState extends State<FregonaMascotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _bounceController;
  bool _isExcited = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerTapReaction() {
    setState(() => _isExcited = true);
    _bounceController.forward(from: 0).then((_) {
      _bounceController.reverse().then((_) {
        if (mounted) setState(() => _isExcited = false);
      });
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerTapReaction,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _bounceController]),
        builder: (context, _) {
          final t = _idleController.value;
          final jumpFraction = math.sin(_bounceController.value * math.pi);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: widget.size,
                height: widget.size * _HumanizedMopPainter.heightFactor,
                child: CustomPaint(
                  painter: _HumanizedMopPainter(
                    phase: t * 2 * math.pi,
                    mood: _isExcited ? MascotMood.celebrating : widget.mood,
                    jumpFraction: jumpFraction,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: CasviumColors.mustard,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: CasviumColors.ink,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'MASCOTA · ${widget.mascotName.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: CasviumColors.ink,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ),
                        const Text(
                          'Tócame ✨',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CasviumColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CasviumColors.surface,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                          topLeft: Radius.circular(4),
                        ),
                        border: Border.all(
                          color: CasviumColors.ink,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: CasviumColors.ink,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.speechBubble,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: CasviumColors.ink,
                          height: 1.35,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HumanizedMopPainter extends CustomPainter {
  static const heightFactor = 1.24;
  static const _artboardWidth = 120.0;
  static const _centerX = _artboardWidth / 2;
  static const _floorY = 137.0;

  static const _ink = Color(0xFF2C2119);
  static const _cotton = Color(0xFFFFF8E8);
  static const _terracotta = Color(0xFFD86A30);
  static const _orangeLight = Color(0xFFF5A766);

  final double phase;
  final MascotMood mood;
  final double jumpFraction;

  const _HumanizedMopPainter({
    required this.phase,
    required this.mood,
    required this.jumpFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(phase);
    final scrubbing = mood == MascotMood.scrubbing;
    final celebrating = mood == MascotMood.celebrating;
    final outline = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.scale(size.width / _artboardWidth);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_centerX + sway * 1.3, _floorY),
        width: 66 + 8 * jumpFraction,
        height: 10 + jumpFraction,
      ),
      Paint()..color = _ink.withAlpha((42 - 16 * jumpFraction).round()),
    );

    _paintBubbles(canvas);

    canvas.save();
    final bob = math.cos(phase * 2) * 1.2;
    canvas.translate(
      _centerX + sway * (scrubbing ? 4.0 : 2.0),
      _floorY + bob - 10.7 * jumpFraction,
    );
    canvas.rotate(sway * (scrubbing ? 0.09 : 0.045));
    canvas.translate(-_centerX, -_floorY);

    _paintLegsAndBoots(canvas, outline);
    _paintArm(canvas,
        left: true, angle: celebrating ? 0.95 + sway * 0.24 : sway * 0.13);
    _paintArm(canvas,
        left: false, angle: scrubbing ? 0.55 + sway * 0.30 : -sway * 0.13);
    _paintCotton(canvas, outline, sway * (scrubbing ? 4.0 : 2.3));
    _paintHandleAndCap(canvas, outline);
    _paintFace(canvas, celebrating);

    if (celebrating) {
      final rays = Paint()
        ..color = _terracotta
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(33, 76), const Offset(26, 73), rays);
      canvas.drawLine(const Offset(38, 68), const Offset(34, 63), rays);
      canvas.drawLine(const Offset(84, 75), const Offset(91, 71), rays);
    }

    canvas.restore();
    canvas.restore();
  }

  void _paintLegsAndBoots(Canvas canvas, Paint outline) {
    final legs = Paint()
      ..color = _ink
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final leather = Paint()..color = _terracotta;
    final cuffLight = Paint()
      ..color = _orangeLight
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final sole = Paint()
      ..color = const Color(0xFF903E25)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final boot = Path()
      ..moveTo(42, 124)
      ..quadraticBezierTo(41, 122, 45, 122)
      ..lineTo(53, 122)
      ..quadraticBezierTo(57, 122, 56, 126)
      ..lineTo(55, 131)
      ..quadraticBezierTo(58, 138, 54, 138)
      ..lineTo(36, 138)
      ..quadraticBezierTo(32, 138, 33, 134)
      ..quadraticBezierTo(35, 129, 43, 129)
      ..close();

    for (final left in [true, false]) {
      canvas.save();
      if (!left) {
        canvas.translate(_artboardWidth, 0);
        canvas.scale(-1, 1);
      }
      canvas.drawLine(const Offset(50, 111), const Offset(47, 125), legs);
      canvas.drawPath(boot, leather);
      canvas.drawPath(boot, outline);
      canvas.drawLine(const Offset(36, 135.5), const Offset(54, 135.5), sole);
      canvas.drawLine(const Offset(45, 125), const Offset(52, 125), cuffLight);
      canvas.drawLine(const Offset(37, 132), const Offset(41, 131), cuffLight);
      canvas.restore();
    }
  }

  void _paintArm(Canvas canvas, {required bool left, required double angle}) {
    canvas.save();
    if (!left) {
      canvas.translate(_artboardWidth, 0);
      canvas.scale(-1, 1);
    }
    canvas.translate(44, 84);
    canvas.rotate(angle);
    canvas.translate(-44, -84);

    final arm = Path()
      ..moveTo(47, 84)
      ..cubicTo(35, 81, 22, 87, 27, 93)
      ..quadraticBezierTo(29, 95, 32, 97);
    final armStroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.7
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(arm, armStroke);
    final glove = Path()
      ..moveTo(28, 94.5)
      ..cubicTo(30.5, 93, 32.5, 94.4, 33, 96.5)
      ..cubicTo(36.5, 95.5, 39.2, 98, 37.5, 101.5)
      ..cubicTo(36, 105, 29, 106, 26.5, 102.5)
      ..quadraticBezierTo(23.8, 98.8, 28, 94.5)
      ..close();
    canvas.drawPath(glove, Paint()..color = _ink);
    canvas.drawPath(
      Path()
        ..moveTo(28.5, 100.2)
        ..quadraticBezierTo(30.4, 98.4, 33.1, 99.7),
      Paint()
        ..color = const Color(0xFF91654C)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.2,
    );
    canvas.restore();
  }

  void _paintCotton(Canvas canvas, Paint outline, double drift) {
    final body = Path()
      ..moveTo(45, 79)
      ..quadraticBezierTo(61, 74, 75, 79)
      ..cubicTo(79, 87, 79, 94, 89 + drift / 2, 102)
      ..cubicTo(97 + drift, 111, 86 + drift, 116, 80 + drift, 109)
      ..cubicTo(82 + drift, 117, 70 + drift, 121, 66 + drift, 113)
      ..cubicTo(66 + drift, 122, 54 + drift, 123, 53 + drift, 114)
      ..cubicTo(48 + drift, 121, 37 + drift, 118, 38 + drift, 110)
      ..cubicTo(31 + drift, 116, 23 + drift, 112, 28 + drift, 105)
      ..cubicTo(32, 100, 39, 96, 42, 88)
      ..close();
    final cottonBounds = body.getBounds();
    final fabric = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_cotton, Color(0xFFF1D9B9)],
        stops: [0.45, 1],
      ).createShader(cottonBounds);
    canvas.drawPath(body, fabric);

    // Las curvas separan los cinco mechones sin dividir la cara.
    final seam = Paint()..color = _ink;
    const strandRoots = [46.0, 55.0, 65.0, 74.0];
    const strandEnds = [38.0, 53.0, 66.0, 80.0];
    for (var i = 0; i < strandRoots.length; i++) {
      final root = strandRoots[i];
      final end = strandEnds[i] + drift;
      final startY = i == 0 || i == 3 ? 91.0 : 99.0;
      final endY = switch (i) {
        0 => 110.0,
        1 => 114.0,
        2 => 113.0,
        _ => 109.0,
      };
      final fold = Path()
        ..moveTo(root, startY)
        ..cubicTo(root + 0.7, startY + 6, (root + end) / 2 + 2, endY - 6,
            end + 1.3, endY)
        ..lineTo(end - 1.3, endY)
        ..cubicTo((root + end) / 2 - 1, endY - 6, root - 0.8, startY + 6, root,
            startY)
        ..close();
      canvas.drawPath(fold, seam);
    }
    canvas.drawPath(body, outline);
  }

  void _paintHandleAndCap(Canvas canvas, Paint outline) {
    final handle = RRect.fromLTRBR(55, 14, 65, 68, const Radius.circular(5));
    canvas.drawRRect(handle, Paint()..color = const Color(0xFFE78E49));
    canvas.drawRRect(handle, outline);

    final grain = Paint()
      ..color = const Color(0xFF8F4323)
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(61.5, 20)
        ..cubicTo(65, 32, 57.5, 38, 59, 48)
        ..moveTo(61.5, 39)
        ..cubicTo(63, 47, 59.5, 52, 60.4, 59),
      grain,
    );
    canvas.drawLine(const Offset(58, 24), const Offset(58, 32), grain);

    final collar =
        RRect.fromLTRBR(52.5, 64, 67.5, 73, const Radius.circular(4.5));
    final cap = Path()
      ..moveTo(42, 81)
      ..cubicTo(35, 79, 46, 67, 60, 68)
      ..cubicTo(74, 67, 85, 79, 78, 81)
      ..quadraticBezierTo(60, 76, 42, 81)
      ..close();
    final orange = Paint()..color = _terracotta;
    canvas.drawRRect(collar, orange);
    canvas.drawRRect(collar, outline);
    canvas.drawPath(cap, orange);
    canvas.drawPath(cap, outline);

    final reflection = Paint()
      ..color = _orangeLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(44, 75.8)
        ..quadraticBezierTo(52, 70.8, 61, 71.8),
      reflection,
    );
    canvas.drawLine(const Offset(57, 66.6), const Offset(62, 66.6), reflection);
    final fleck = Paint()..color = const Color(0xFFFFC591);
    for (final point in const [
      Offset(49, 76),
      Offset(54, 75),
      Offset(59, 74.8),
      Offset(65, 73),
      Offset(67, 75),
      Offset(71, 74.8),
      Offset(74, 76.4),
    ]) {
      canvas.drawCircle(point, 0.65, fleck);
    }
  }

  void _paintFace(Canvas canvas, bool celebrating) {
    final eye = Paint()..color = _ink;
    final expression = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final blinking = math.sin(phase) < -0.98;
    for (final x in [53.5, 66.5]) {
      if (blinking) {
        canvas.drawLine(Offset(x - 1.6, 86), Offset(x + 1.6, 86), expression);
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 85.7), width: 3.6, height: 5.5),
          eye,
        );
      }
    }

    final cheeks = Paint()..color = const Color(0xFFD46D42).withAlpha(95);
    canvas.drawOval(const Rect.fromLTWH(48, 90, 4, 2.3), cheeks);
    canvas.drawOval(const Rect.fromLTWH(68, 90, 4, 2.3), cheeks);
    final smile = Path()
      ..moveTo(55.5, 90.5)
      ..quadraticBezierTo(60, celebrating ? 101 : 97, 64.5, 90);
    if (celebrating) {
      smile
        ..quadraticBezierTo(60, 92, 55.5, 90.5)
        ..close();
      canvas.drawPath(smile, Paint()..color = _terracotta);
    }
    canvas.drawPath(smile, expression);
  }

  void _paintBubbles(Canvas canvas) {
    final glass = Paint()..color = _cotton.withAlpha(205);
    final ring = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final glint = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final wave = math.sin(phase + i * 2.1);
      final center = switch (i) {
        0 => Offset(79 + 2 * wave, 60 + 4 * wave),
        1 => Offset(24 + 2 * wave, 65 + 9 * wave),
        _ => Offset(102 + 3 * wave, 106 + 10 * wave),
      };
      final radius = i == 0 ? 5.8 : 2.4;
      canvas.drawCircle(center, radius, glass);
      canvas.drawCircle(center, radius, ring);
      if (i == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 3.3),
          -1.3,
          0.8,
          false,
          glint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HumanizedMopPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.mood != mood ||
      oldDelegate.jumpFraction != jumpFraction;
}
