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
    final w = size.width;
    final h = size.height / heightFactor;
    final headroom = size.height - h;
    final floorY = h * 0.91;
    final cx = w * 0.50;
    const bodyScale = 0.9;

    final sway = math.sin(phase) * (mood == MascotMood.scrubbing ? 9.0 : 4.5);
    final bob = math.cos(phase * 2) * 2.5;

    final outline = Paint()
      ..color = CasviumColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Sombra en el suelo
    final shadowScale = 1.0 + jumpFraction * 0.12;
    final shadowOpacity = 0.16 - jumpFraction * 0.06;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + sway * 0.4, headroom + floorY),
        width: w * 0.56 * shadowScale,
        height: h * 0.09 * shadowScale,
      ),
      Paint()..color = CasviumColors.ink.withOpacity(shadowOpacity),
    );

    canvas.save();
    canvas.translate(0, headroom - 12.0 * jumpFraction);

    // 2. Palo de madera de la fregona (tronco y piernas bailarinas)
    final stickPaint = Paint()
      ..color = const Color(0xFFD6955B)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx + sway * 0.3, floorY - h * 0.33 * bodyScale + bob);
    canvas.rotate(math.sin(phase) * 0.07);
    canvas.scale(bodyScale);

    final stickRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, h * 0.14),
        width: w * 0.10,
        height: h * 0.38,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(stickRect, stickPaint);
    canvas.drawRRect(stickRect, outline);

    // Zapatitos rojos de goma
    final leftBoot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-w * 0.10, h * 0.31),
        width: w * 0.16,
        height: h * 0.09,
      ),
      const Radius.circular(8),
    );
    final rightBoot = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.10, h * 0.31),
        width: w * 0.16,
        height: h * 0.09,
      ),
      const Radius.circular(8),
    );
    final bootFill = Paint()..color = CasviumColors.terracotta;
    canvas.drawRRect(leftBoot, bootFill);
    canvas.drawRRect(leftBoot, outline);
    canvas.drawRRect(rightBoot, bootFill);
    canvas.drawRRect(rightBoot, outline);

    // 3. Brazos enguantados amarillos saludando
    final leftArmWave = mood == MascotMood.celebrating
        ? -h * 0.18 + math.sin(phase * 3) * 8
        : -h * 0.02 + math.sin(phase) * 5;
    final rightArmWave = mood == MascotMood.scrubbing
        ? -h * 0.14 + math.cos(phase * 4) * 10
        : -h * 0.08 + math.cos(phase) * 6;

    final armPathLeft = Path()
      ..moveTo(-w * 0.06, h * 0.06)
      ..quadraticBezierTo(-w * 0.28, h * 0.04, -w * 0.32, leftArmWave);
    final armPathRight = Path()
      ..moveTo(w * 0.06, h * 0.06)
      ..quadraticBezierTo(w * 0.28, h * 0.04, w * 0.34, rightArmWave);

    canvas.drawPath(armPathLeft, outline);
    canvas.drawPath(armPathRight, outline);

    final glovePaint = Paint()..color = CasviumColors.mustard;
    canvas.drawCircle(Offset(-w * 0.32, leftArmWave), w * 0.055, glovePaint);
    canvas.drawCircle(Offset(-w * 0.32, leftArmWave), w * 0.055, outline);
    canvas.drawCircle(Offset(w * 0.34, rightArmWave), w * 0.055, glovePaint);
    canvas.drawCircle(Offset(w * 0.34, rightArmWave), w * 0.055, outline);

    // 4. Cabezal de fregona: flecos de algodón que ondean (cabellera y cuerpo esponjoso)
    final strandColors = [
      const Color(0xFFFFFCF5),
      const Color(0xFFE4F0F6),
      const Color(0xFFF3ECE0),
    ];

    for (int i = -4; i <= 4; i++) {
      final strandSway = math.sin(phase + i * 0.45) * 5.0;
      final sx = i * (w * 0.062);
      final strandPath = Path()
        ..moveTo(sx * 0.5, -h * 0.22)
        ..quadraticBezierTo(
          sx * 1.15 + strandSway * 0.5,
          -h * 0.05,
          sx * 1.25 + strandSway,
          h * 0.14 + (i.abs().isEven ? 3 : -2),
        );

      final strandPaint = Paint()
        ..color = strandColors[i.abs() % strandColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.088
        ..strokeCap = StrokeCap.round;

      final strandBorder = Paint()
        ..color = CasviumColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.088 + 3.6
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(strandPath, strandBorder);
      canvas.drawPath(strandPath, strandPaint);
    }

    // 5. Casquete roscado y mango de madera
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -h * 0.25),
        width: w * 0.42,
        height: h * 0.15,
      ),
      const Radius.circular(14),
    );
    final handleHalfWidth = w * 0.035 / bodyScale;
    final handleLength = h * 0.405 / bodyScale;
    final handleRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        -handleHalfWidth,
        capRect.top - handleLength,
        handleHalfWidth,
        capRect.top + h * 0.035,
      ),
      Radius.circular(handleHalfWidth),
    );
    canvas.drawRRect(handleRect, stickPaint);
    canvas.drawRRect(handleRect, outline);

    canvas.drawRRect(capRect, Paint()..color = CasviumColors.cobalt);
    canvas.drawRRect(capRect, outline);

    // Cinta decorativa naranja en el casquete
    canvas.drawLine(
      Offset(-w * 0.18, -h * 0.22),
      Offset(w * 0.18, -h * 0.22),
      Paint()
        ..color = CasviumColors.terracotta
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // 6. Rostro expresivo sobre los flecos centrales
    final isBlinking = (math.sin(phase * 1.7) > 0.94);
    final eyeY = -h * 0.07;
    final leftEyeX = -w * 0.095;
    final rightEyeX = w * 0.095;

    // Mejillas sonrojadas
    final blushPaint = Paint()
      ..color = CasviumColors.terracotta.withOpacity(0.45);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-w * 0.15, eyeY + h * 0.055), width: 10, height: 6),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.15, eyeY + h * 0.055), width: 10, height: 6),
      blushPaint,
    );

    if (isBlinking) {
      canvas.drawLine(
          Offset(leftEyeX - 4, eyeY), Offset(leftEyeX + 4, eyeY), outline);
      canvas.drawLine(
          Offset(rightEyeX - 4, eyeY), Offset(rightEyeX + 4, eyeY), outline);
    } else {
      canvas.drawCircle(
          Offset(leftEyeX, eyeY), 4.2, Paint()..color = CasviumColors.ink);
      canvas.drawCircle(
          Offset(rightEyeX, eyeY), 4.2, Paint()..color = CasviumColors.ink);
      // Brillo pupilar
      canvas.drawCircle(Offset(leftEyeX - 1.2, eyeY - 1.2), 1.4,
          Paint()..color = Colors.white);
      canvas.drawCircle(Offset(rightEyeX - 1.2, eyeY - 1.2), 1.4,
          Paint()..color = Colors.white);
    }

    // Boca sonriente o cantando
    if (mood == MascotMood.celebrating) {
      final mouthRect = Rect.fromCenter(
        center: Offset(0, eyeY + h * 0.075),
        width: 14,
        height: 11,
      );
      canvas.drawArc(mouthRect, 0, math.pi, true,
          Paint()..color = CasviumColors.terracotta);
      canvas.drawArc(mouthRect, 0, math.pi, true, outline);
    } else {
      final smileRect = Rect.fromCenter(
        center: Offset(0, eyeY + h * 0.055),
        width: 13,
        height: 9,
      );
      canvas.drawArc(smileRect, 0.15, math.pi - 0.3, false, outline);
    }

    canvas.restore();

    // 7. Burbujas de espuma flotando alrededor de Don Mocho
    for (int b = 0; b < 4; b++) {
      final bProgress = ((phase / (2 * math.pi)) + b * 0.25) % 1.0;
      final bx = (b.isEven ? w * 0.14 : w * 0.85) +
          math.sin(bProgress * math.pi * 2 + b) * 6;
      final by = h * (0.78 - bProgress * 0.62);
      final radius = (4.0 + (b % 2) * 2.5) * (1.0 - bProgress * 0.35);

      canvas.drawCircle(
        Offset(bx, by),
        radius,
        Paint()..color = CasviumColors.mint.withOpacity(0.45),
      );
      canvas.drawCircle(
        Offset(bx, by),
        radius,
        Paint()
          ..color = CasviumColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HumanizedMopPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.mood != mood ||
      oldDelegate.jumpFraction != jumpFraction;
}
