import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/casvium_theme.dart';

class ChoreIconDefinition {
  final String key;
  final String label;
  final String category;
  final Color accentColor;

  const ChoreIconDefinition({
    required this.key,
    required this.label,
    required this.category,
    required this.accentColor,
  });
}

/// Catálogo completo de 30 iconos vectoriales artesanales para tareas domésticas típicas.
class ChoreIconsCatalog {
  static const List<ChoreIconDefinition> all = [
    // Limpieza de suelos y superficies (1-6)
    ChoreIconDefinition(
      key: 'mop_bucket',
      label: 'Cubo y fregona',
      category: 'Suelos',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'vacuum',
      label: 'Aspiradora',
      category: 'Suelos',
      accentColor: CasviumColors.terracotta,
    ),
    ChoreIconDefinition(
      key: 'broom_dustpan',
      label: 'Escoba',
      category: 'Suelos',
      accentColor: CasviumColors.mustard,
    ),
    ChoreIconDefinition(
      key: 'dust_feather',
      label: 'Plumero',
      category: 'Superficies',
      accentColor: CasviumColors.plum,
    ),
    ChoreIconDefinition(
      key: 'window_spray',
      label: 'Pulverizador',
      category: 'Superficies',
      accentColor: CasviumColors.mint,
    ),
    ChoreIconDefinition(
      key: 'rug_beater',
      label: 'Alfombra',
      category: 'Suelos',
      accentColor: CasviumColors.terracotta,
    ),

    // Cocina y alimentación (7-14)
    ChoreIconDefinition(
      key: 'dishes_sponge',
      label: 'Plato',
      category: 'Cocina',
      accentColor: CasviumColors.mint,
    ),
    ChoreIconDefinition(
      key: 'dishwasher',
      label: 'Lavavajillas',
      category: 'Cocina',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'stove_flame',
      label: 'Fogón',
      category: 'Cocina',
      accentColor: CasviumColors.terracotta,
    ),
    ChoreIconDefinition(
      key: 'oven_sparkle',
      label: 'Horno',
      category: 'Cocina',
      accentColor: CasviumColors.coral,
    ),
    ChoreIconDefinition(
      key: 'fridge_clean',
      label: 'Nevera',
      category: 'Cocina',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'cooking_pot',
      label: 'Olla',
      category: 'Cocina',
      accentColor: CasviumColors.terracotta,
    ),
    ChoreIconDefinition(
      key: 'grocery_bag',
      label: 'Bolsa de compra',
      category: 'Cocina',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'pantry_jars',
      label: 'Tarro',
      category: 'Cocina',
      accentColor: CasviumColors.mustard,
    ),

    // Colada y textil (15-19)
    ChoreIconDefinition(
      key: 'washing_machine',
      label: 'Lavadora',
      category: 'Colada',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'clothesline',
      label: 'Camiseta tendida',
      category: 'Colada',
      accentColor: CasviumColors.mint,
    ),
    ChoreIconDefinition(
      key: 'steam_iron',
      label: 'Plancha',
      category: 'Colada',
      accentColor: CasviumColors.plum,
    ),
    ChoreIconDefinition(
      key: 'folded_shirts',
      label: 'Ropa doblada',
      category: 'Colada',
      accentColor: CasviumColors.mustard,
    ),
    ChoreIconDefinition(
      key: 'shoe_rack',
      label: 'Bota',
      category: 'Colada',
      accentColor: CasviumColors.terracotta,
    ),

    // Baño e higiene (20-23)
    ChoreIconDefinition(
      key: 'toilet_brush',
      label: 'Inodoro',
      category: 'Baño',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'shower_head',
      label: 'Ducha',
      category: 'Baño',
      accentColor: CasviumColors.mint,
    ),
    ChoreIconDefinition(
      key: 'sink_faucet',
      label: 'Lavabo',
      category: 'Baño',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'towels_stack',
      label: 'Toalla',
      category: 'Baño',
      accentColor: CasviumColors.plum,
    ),

    // Dormitorio y orden (24-26)
    ChoreIconDefinition(
      key: 'bed_pillow',
      label: 'Cama',
      category: 'Dormitorio',
      accentColor: CasviumColors.mustard,
    ),
    ChoreIconDefinition(
      key: 'fresh_sheets',
      label: 'Sábana',
      category: 'Dormitorio',
      accentColor: CasviumColors.plum,
    ),
    ChoreIconDefinition(
      key: 'wardrobe_hanger',
      label: 'Percha',
      category: 'Dormitorio',
      accentColor: CasviumColors.terracotta,
    ),

    // Exterior, residuos, mascotas y mantenimiento (27-30)
    ChoreIconDefinition(
      key: 'trash_bin',
      label: 'Cubo de basura',
      category: 'Hogar',
      accentColor: CasviumColors.ink,
    ),
    ChoreIconDefinition(
      key: 'recycle_loop',
      label: 'Símbolo de reciclaje',
      category: 'Hogar',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'watering_can',
      label: 'Regadera',
      category: 'Exterior',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'pet_care',
      label: 'Huella',
      category: 'Hogar',
      accentColor: CasviumColors.terracotta,
    ),
  ];

  static ChoreIconDefinition byKey(String key) {
    return all.firstWhere(
      (item) => item.key == key,
      orElse: () => all.first,
    );
  }
}

/// Ilustración vectorial animada del catálogo de tareas.
class ChoreCustomIcon extends StatefulWidget {
  final String iconKey;
  final double size;
  final Color? backgroundColor;
  final bool showBadgeBorder;

  const ChoreCustomIcon({
    super.key,
    required this.iconKey,
    this.size = 44,
    this.backgroundColor,
    this.showBadgeBorder = true,
  });

  @override
  State<ChoreCustomIcon> createState() => _ChoreCustomIconState();
}

class _ChoreCustomIconState extends State<ChoreCustomIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _motion.reset();
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final def = ChoreIconsCatalog.byKey(widget.iconKey);
    final bg = Color.alphaBlend(
      widget.backgroundColor ?? def.accentColor.withOpacity(0.16),
      CasviumColors.surface,
    );

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.size * 0.30),
        border: widget.showBadgeBorder
            ? Border.all(color: CasviumColors.ink, width: 1.8)
            : null,
        boxShadow: widget.showBadgeBorder
            ? const [
                BoxShadow(
                  color: CasviumColors.ink,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                )
              ]
            : null,
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          willChange: _motion.isAnimating,
          painter: _ChoreVectorPainter(
            iconKey: def.key,
            accent: def.accentColor,
            motion: _motion,
            phaseOffset: ChoreIconsCatalog.all.indexOf(def) * 0.13,
          ),
        ),
      ),
    );
  }
}

class _ChoreVectorPainter extends CustomPainter {
  final String iconKey;
  final Color accent;
  final Animation<double> motion;
  final double phaseOffset;

  _ChoreVectorPainter({
    required this.iconKey,
    required this.accent,
    required this.motion,
    required this.phaseOffset,
  }) : super(repaint: motion);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final progress = (motion.value + phaseOffset) % 1.0;
    final phase = progress * 2 * math.pi;
    final sway = math.sin(phase);
    final pulse = (1 - math.cos(phase)) / 2;

    final stroke = Paint()
      ..color = CasviumColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.055).clamp(1.6, 2.8)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final softFill = Paint()
      ..color = CasviumColors.surface
      ..style = PaintingStyle.fill;

    late final softStroke = Paint.from(stroke)..color = CasviumColors.surface;
    late final water = Paint()..color = CasviumColors.cobalt;

    void rotateAround(Offset pivot, double angle) {
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(angle);
      canvas.translate(-pivot.dx, -pivot.dy);
    }

    void drawDrop(Offset center, double progress) {
      final diameter = w * 0.10 * math.sin(progress * math.pi);
      canvas.drawOval(
        Rect.fromCenter(
            center: center, width: diameter, height: diameter * 1.3),
        water,
      );
    }

    void drawSteam(Offset origin, double progress) {
      final y = origin.dy - h * 0.14 * progress;
      final steam = Path()
        ..moveTo(origin.dx, y)
        ..relativeCubicTo(
            -w * 0.06, -h * 0.04, w * 0.06, -h * 0.07, 0, -h * 0.12);
      final steamPaint = Paint.from(stroke)
        ..strokeWidth = stroke.strokeWidth * 0.7
        ..color = CasviumColors.ink.withAlpha(
          (190 * math.sin(progress * math.pi)).round(),
        );
      canvas.drawPath(steam, steamPaint);
    }

    void drawSparkle(Offset center, double radius) {
      final x = center.dx;
      final y = center.dy;
      final inset = radius * 0.24;
      final sparkle = Path()
        ..moveTo(x, y - radius)
        ..lineTo(x + inset, y - inset)
        ..lineTo(x + radius, y)
        ..lineTo(x + inset, y + inset)
        ..lineTo(x, y + radius)
        ..lineTo(x - inset, y + inset)
        ..lineTo(x - radius, y)
        ..lineTo(x - inset, y - inset)
        ..close();
      canvas.drawPath(sparkle, softFill);
    }

    canvas.save();
    switch (iconKey) {
      case 'mop_bucket':
        // Cubo trapezoidal + palo de fregona y burbujas
        final bucket = Path()
          ..moveTo(w * 0.24, h * 0.44)
          ..lineTo(w * 0.76, h * 0.44)
          ..lineTo(w * 0.68, h * 0.80)
          ..lineTo(w * 0.32, h * 0.80)
          ..close();
        canvas.drawPath(bucket, fill);
        canvas.drawPath(bucket, stroke);
        canvas.drawLine(
          Offset(w * (0.65 + 0.12 * sway), h * 0.16),
          Offset(w * 0.46, h * 0.56),
          stroke,
        );
        final bubble = Offset(w * 0.32, h * (0.33 - 0.13 * pulse));
        canvas.drawCircle(bubble, w * 0.06, softFill);
        canvas.drawCircle(bubble, w * 0.06, stroke);
        break;

      case 'vacuum':
        // La aspiradora se desliza sobre sus ruedas.
        canvas.translate(w * 0.08 * sway, 0);
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.44, h * 0.28),
          Radius.circular(w * 0.14),
        );
        canvas.drawRRect(body, fill);
        canvas.drawRRect(body, stroke);
        canvas.drawCircle(Offset(w * 0.30, h * 0.76), w * 0.07, softFill);
        canvas.drawCircle(Offset(w * 0.30, h * 0.76), w * 0.07, stroke);
        canvas.drawLine(
          Offset(w * 0.64, h * 0.56),
          Offset(w * 0.78, h * (0.24 - 0.06 * sway)),
          stroke,
        );
        canvas.drawLine(
            Offset(w * 0.70, h * 0.76), Offset(w * 0.84, h * 0.76), stroke);
        break;

      case 'broom_dustpan':
        // Las cerdas barren de un lado a otro.
        rotateAround(Offset(w * 0.58, h * 0.16), 0.22 * sway);
        canvas.drawLine(
            Offset(w * 0.58, h * 0.16), Offset(w * 0.42, h * 0.54), stroke);
        final bristles = Path()
          ..moveTo(w * 0.32, h * 0.52)
          ..lineTo(w * 0.56, h * 0.56)
          ..lineTo(w * 0.62, h * 0.78)
          ..lineTo(w * 0.24, h * 0.74)
          ..close();
        canvas.drawPath(bristles, fill);
        canvas.drawPath(bristles, stroke);
        break;

      case 'dust_feather':
        // El plumero oscila desde el extremo del mango.
        rotateAround(Offset(w * 0.26, h * 0.78), 0.18 * sway);
        canvas.drawLine(
            Offset(w * 0.26, h * 0.78), Offset(w * 0.48, h * 0.56), stroke);
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(w * (0.52 + i * 0.08), h * (0.46 - i * 0.08)),
            w * 0.13,
            fill,
          );
          canvas.drawCircle(
            Offset(w * (0.52 + i * 0.08), h * (0.46 - i * 0.08)),
            w * 0.13,
            stroke,
          );
        }
        break;

      case 'window_spray':
        // Botella pulverizadora
        final bottle = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.32, h * 0.42, w * 0.34, h * 0.40),
          Radius.circular(w * 0.08),
        );
        canvas.drawRRect(bottle, fill);
        canvas.drawRRect(bottle, stroke);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.42, h * 0.28, w * 0.14, h * 0.14), stroke);
        canvas.drawLine(
            Offset(w * 0.36, h * 0.24), Offset(w * 0.64, h * 0.24), stroke);
        for (var i = 0; i < 2; i++) {
          final travel = (progress * 2 + i * 0.5) % 1.0;
          drawDrop(
            Offset(w * (0.65 + 0.24 * travel),
                h * (0.24 + (i - 0.5) * 0.23 * travel)),
            travel,
          );
        }
        break;

      case 'rug_beater':
        // La alfombra se sacude con un vaivén corto.
        canvas.translate(w * 0.05 * math.sin(phase * 2), 0);
        rotateAround(Offset(cx, cy), 0.14 * sway);
        final rug = Rect.fromLTWH(w * 0.24, h * 0.26, w * 0.52, h * 0.48);
        canvas.drawRect(rug, fill);
        canvas.drawRect(rug, stroke);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.34, h * 0.36, w * 0.32, h * 0.28), softFill);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.34, h * 0.36, w * 0.32, h * 0.28), stroke);
        break;

      case 'dishes_sponge':
        // Plato brillante + espuma
        canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.28, softFill);
        canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.28, stroke);
        canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.17, fill);
        canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.17, stroke);
        final bubble =
            Offset(w * (0.72 + 0.05 * sway), h * (0.31 - 0.15 * pulse));
        final bubbleRadius = w * (0.045 + 0.02 * pulse);
        canvas.drawCircle(bubble, bubbleRadius, softFill);
        canvas.drawCircle(bubble, bubbleRadius, stroke);
        break;

      case 'dishwasher':
        // Lavavajillas frontal con cestas
        final box = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.22, h * 0.20, w * 0.56, h * 0.60),
          Radius.circular(w * 0.06),
        );
        canvas.drawRRect(box, softFill);
        canvas.drawRRect(box, stroke);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.22, h * 0.20, w * 0.56, h * 0.15), fill);
        canvas.drawLine(
            Offset(w * 0.22, h * 0.35), Offset(w * 0.78, h * 0.35), stroke);
        final leftDish = Offset(w * 0.40, h * (0.58 + 0.08 * sway));
        final rightDish = Offset(w * 0.60, h * (0.58 - 0.08 * sway));
        canvas.drawCircle(leftDish, w * 0.10, fill);
        canvas.drawCircle(leftDish, w * 0.10, stroke);
        canvas.drawCircle(rightDish, w * 0.10, stroke);
        break;

      case 'stove_flame':
        // Quemador de cocina y llama
        canvas.drawOval(
            Rect.fromLTWH(w * 0.20, h * 0.58, w * 0.60, h * 0.20), stroke);
        final flameTip =
            Offset(cx + w * 0.09 * sway, h * (0.23 - 0.09 * pulse));
        final flame = Path()
          ..moveTo(flameTip.dx, flameTip.dy)
          ..quadraticBezierTo(w * 0.76, h * 0.42, cx, h * 0.64)
          ..quadraticBezierTo(w * 0.24, h * 0.42, flameTip.dx, flameTip.dy);
        canvas.drawPath(flame, fill);
        canvas.drawPath(flame, stroke);
        break;

      case 'oven_sparkle':
        // Horno con ventana iluminada
        final oven = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.20, h * 0.22, w * 0.60, h * 0.56),
          Radius.circular(w * 0.06),
        );
        canvas.drawRRect(oven, softFill);
        canvas.drawRRect(oven, stroke);
        final glass = Rect.fromLTWH(w * 0.30, h * 0.40, w * 0.40, h * 0.28);
        canvas.drawRect(glass, fill);
        canvas.drawRect(glass, stroke);
        drawSparkle(
          Offset(w * (0.50 + 0.08 * sway), h * 0.54),
          w * (0.035 + 0.075 * pulse),
        );
        canvas.drawCircle(Offset(w * 0.36, h * 0.30), w * 0.025, stroke);
        canvas.drawCircle(Offset(w * 0.50, h * 0.30), w * 0.025, stroke);
        canvas.drawCircle(Offset(w * 0.64, h * 0.30), w * 0.025, stroke);
        break;

      case 'fridge_clean':
        // Frigorífico de dos puertas
        final fridge = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.28, h * 0.16, w * 0.44, h * 0.68),
          Radius.circular(w * 0.06),
        );
        canvas.drawRRect(fridge, fill);
        final doorEdge = w * (0.72 - 0.14 * pulse);
        final interior = Path()
          ..moveTo(doorEdge, h * 0.22)
          ..lineTo(w * 0.72, h * 0.26)
          ..lineTo(w * 0.72, h * 0.42)
          ..lineTo(doorEdge, h * 0.42)
          ..close();
        canvas.drawPath(interior, softFill);
        canvas.drawRRect(fridge, stroke);
        canvas.drawLine(
            Offset(w * 0.28, h * 0.42), Offset(w * 0.72, h * 0.42), stroke);
        canvas.drawLine(
            Offset(w * 0.36, h * 0.26), Offset(w * 0.36, h * 0.36), stroke);
        canvas.drawLine(
            Offset(w * 0.36, h * 0.50), Offset(w * 0.36, h * 0.66), stroke);
        break;

      case 'cooking_pot':
        // Olla con tapa y vapor
        final pot = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.24, h * 0.42, w * 0.52, h * 0.34),
          Radius.circular(w * 0.06),
        );
        canvas.drawRRect(pot, fill);
        canvas.drawRRect(pot, stroke);
        canvas.drawLine(
            Offset(w * 0.16, h * 0.48), Offset(w * 0.24, h * 0.48), stroke);
        canvas.drawLine(
            Offset(w * 0.76, h * 0.48), Offset(w * 0.84, h * 0.48), stroke);
        canvas.drawArc(Rect.fromLTWH(w * 0.42, h * 0.32, w * 0.16, h * 0.14),
            math.pi, math.pi, false, stroke);
        drawSteam(Offset(w * 0.35, h * 0.42), progress);
        drawSteam(Offset(w * 0.64, h * 0.42), (progress + 0.5) % 1.0);
        break;

      case 'grocery_bag':
        // La bolsa se balancea desde el asa.
        canvas.translate(0, -h * 0.05 * pulse);
        rotateAround(Offset(cx, h * 0.28), 0.15 * sway);
        final bag = Path()
          ..moveTo(w * 0.26, h * 0.38)
          ..lineTo(w * 0.74, h * 0.38)
          ..lineTo(w * 0.68, h * 0.80)
          ..lineTo(w * 0.32, h * 0.80)
          ..close();
        canvas.drawPath(bag, fill);
        canvas.drawPath(bag, stroke);
        canvas.drawArc(Rect.fromLTWH(w * 0.38, h * 0.24, w * 0.24, h * 0.26),
            math.pi, math.pi, false, stroke);
        break;

      case 'pantry_jars':
        // Tarro de conserva con etiqueta
        final jar = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.30, h * 0.32, w * 0.40, h * 0.48),
          Radius.circular(w * 0.08),
        );
        canvas.drawRRect(jar, softFill);
        canvas.drawRRect(jar, stroke);
        final lid = Rect.fromLTWH(
            w * 0.34, h * (0.22 - 0.10 * pulse), w * 0.32, h * 0.10);
        canvas.drawRect(lid, fill);
        canvas.drawRect(lid, stroke);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.36, h * 0.46, w * 0.28, h * 0.18), fill);
        break;

      case 'washing_machine':
        // Lavadora con tambor circular
        final wm = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.64),
          Radius.circular(w * 0.07),
        );
        canvas.drawRRect(wm, softFill);
        canvas.drawRRect(wm, stroke);
        final drum = Offset(cx, h * 0.54);
        canvas.drawCircle(drum, w * 0.18, fill);
        canvas.drawCircle(drum, w * 0.18, stroke);
        canvas.drawArc(
          Rect.fromCircle(center: drum, radius: w * 0.10),
          phase * 2,
          math.pi,
          false,
          softStroke,
        );
        canvas.drawLine(
            Offset(w * 0.22, h * 0.32), Offset(w * 0.78, h * 0.32), stroke);
        break;

      case 'clothesline':
        // Cuerda de tender con camiseta colgada
        canvas.drawLine(
            Offset(w * 0.16, h * 0.28), Offset(w * 0.84, h * 0.28), stroke);
        final flutter = w * 0.10 * sway;
        final shirt = Path()
          ..moveTo(w * 0.34, h * 0.28)
          ..lineTo(w * 0.66, h * 0.28)
          ..lineTo(w * 0.74 + flutter * 0.5, h * 0.46)
          ..lineTo(w * 0.62 + flutter * 0.5, h * 0.50)
          ..lineTo(w * 0.62 + flutter, h * (0.76 + 0.03 * sway))
          ..lineTo(w * 0.38 + flutter, h * (0.76 - 0.03 * sway))
          ..lineTo(w * 0.38 + flutter * 0.5, h * 0.50)
          ..lineTo(w * 0.26 + flutter * 0.5, h * 0.46)
          ..close();
        canvas.drawPath(shirt, fill);
        canvas.drawPath(shirt, stroke);
        break;

      case 'steam_iron':
        // La plancha se desliza y suelta vapor.
        canvas.translate(w * 0.08 * sway, 0);
        final iron = Path()
          ..moveTo(w * 0.20, h * 0.68)
          ..lineTo(w * 0.78, h * 0.68)
          ..quadraticBezierTo(w * 0.72, h * 0.42, w * 0.40, h * 0.42)
          ..close();
        canvas.drawPath(iron, fill);
        canvas.drawPath(iron, stroke);
        canvas.drawLine(
            Offset(w * 0.38, h * 0.42), Offset(w * 0.62, h * 0.30), stroke);
        drawSteam(Offset(w * 0.26, h * 0.57), (progress * 2) % 1.0);
        break;

      case 'folded_shirts':
        // Las prendas de arriba se acomodan sobre la pila.
        for (int i = 0; i < 3; i++) {
          final movement = 1 - i * 0.5;
          final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * (0.24 + 0.09 * sway * movement),
              h * (0.26 + i * 0.18 - 0.08 * pulse * movement),
              w * 0.52,
              h * 0.14,
            ),
            Radius.circular(w * 0.05),
          );
          canvas.drawRRect(r, i.isEven ? fill : softFill);
          canvas.drawRRect(r, stroke);
        }
        break;

      case 'shoe_rack':
        // Bota/zapatilla limpia
        final shoe = Path()
          ..moveTo(w * 0.26, h * 0.32)
          ..lineTo(w * 0.48, h * 0.32)
          ..lineTo(w * 0.52, h * 0.54)
          ..lineTo(w * 0.78, h * 0.58)
          ..lineTo(w * 0.78, h * 0.74)
          ..lineTo(w * 0.26, h * 0.74)
          ..close();
        canvas.drawPath(shoe, fill);
        canvas.drawPath(shoe, stroke);
        drawSparkle(
          Offset(w * (0.64 + 0.06 * sway), h * 0.64),
          w * (0.025 + 0.065 * pulse),
        );
        break;

      case 'toilet_brush':
        // Inodoro reluciente
        canvas.drawRect(
            Rect.fromLTWH(w * 0.30, h * 0.20, w * 0.40, h * 0.22), softFill);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.30, h * 0.20, w * 0.40, h * 0.22), stroke);
        final bowl = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.26, h * 0.42, w * 0.48, h * 0.34),
          Radius.circular(w * 0.18),
        );
        canvas.drawRRect(bowl, fill);
        canvas.drawRRect(bowl, stroke);
        drawSparkle(
          Offset(w * (0.50 + 0.10 * sway), h * 0.55),
          w * (0.035 + 0.075 * pulse),
        );
        break;

      case 'shower_head':
        // Alcachofa de ducha y gotas
        canvas.drawArc(Rect.fromLTWH(w * 0.28, h * 0.20, w * 0.44, h * 0.32),
            math.pi, math.pi, true, fill);
        canvas.drawArc(Rect.fromLTWH(w * 0.28, h * 0.20, w * 0.44, h * 0.32),
            math.pi, math.pi, true, stroke);
        for (int i = 0; i < 3; i++) {
          final fall = (progress * 2 + i / 3) % 1.0;
          drawDrop(
              Offset(w * (0.36 + i * 0.14), h * (0.43 + 0.39 * fall)), fall);
        }
        break;

      case 'sink_faucet':
        // Grifo curvo y lavabo
        canvas.drawArc(Rect.fromLTWH(w * 0.22, h * 0.44, w * 0.56, h * 0.32), 0,
            math.pi, true, fill);
        canvas.drawArc(Rect.fromLTWH(w * 0.22, h * 0.44, w * 0.56, h * 0.32), 0,
            math.pi, true, stroke);
        canvas.drawLine(Offset(cx, h * 0.44), Offset(cx, h * 0.24), stroke);
        canvas.drawLine(
            Offset(cx, h * 0.24), Offset(w * 0.64, h * 0.24), stroke);
        final fall = (progress * 2) % 1.0;
        drawDrop(Offset(w * 0.64, h * (0.28 + 0.17 * fall)), fall);
        break;

      case 'towels_stack':
        // Toalla colgada en barra
        canvas.drawLine(
            Offset(w * 0.20, h * 0.28), Offset(w * 0.80, h * 0.28), stroke);
        final hem = w * 0.085 * sway;
        final towel = Path()
          ..moveTo(w * 0.30, h * 0.28)
          ..lineTo(w * 0.70, h * 0.28)
          ..quadraticBezierTo(w * 0.70, h * 0.53, w * 0.70 + hem, h * 0.75)
          ..quadraticBezierTo(
              cx + hem, h * (0.79 - 0.07 * pulse), w * 0.30 + hem, h * 0.75)
          ..quadraticBezierTo(w * 0.30, h * 0.53, w * 0.30, h * 0.28)
          ..close();
        canvas.drawPath(towel, fill);
        canvas.drawPath(towel, stroke);
        canvas.drawLine(
          Offset(w * 0.31 + hem * 0.55, h * 0.64),
          Offset(w * 0.69 + hem * 0.55, h * 0.64),
          stroke,
        );
        break;

      case 'bed_pillow':
        // Cama con cabecero y almohada
        canvas.drawRect(
            Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.60, h * 0.24), fill);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.60, h * 0.24), stroke);
        final pillow = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w * (0.26 + 0.05 * pulse),
            h * (0.34 - 0.11 * pulse),
            w * 0.22,
            h * 0.14,
          ),
          Radius.circular(w * 0.045),
        );
        canvas.drawRRect(pillow, softFill);
        canvas.drawRRect(pillow, stroke);
        canvas.drawLine(
            Offset(w * 0.20, h * 0.26), Offset(w * 0.20, h * 0.78), stroke);
        canvas.drawLine(
            Offset(w * 0.80, h * 0.48), Offset(w * 0.80, h * 0.78), stroke);
        break;

      case 'fresh_sheets':
        // La sábana ondea al extenderse.
        final wave = Path()
          ..moveTo(w * 0.24, h * 0.28)
          ..cubicTo(w * 0.42, h * (0.20 - 0.09 * sway), w * 0.58,
              h * (0.32 + 0.09 * sway), w * 0.76, h * (0.30 - 0.07 * sway))
          ..lineTo(w * 0.72, h * (0.74 - 0.08 * sway))
          ..cubicTo(w * 0.58, h * (0.80 + 0.12 * sway), w * 0.42,
              h * (0.63 - 0.12 * sway), w * 0.28, h * 0.74)
          ..close();
        canvas.drawPath(wave, fill);
        canvas.drawPath(wave, stroke);
        break;

      case 'wardrobe_hanger':
        // La percha se balancea desde el gancho.
        rotateAround(Offset(cx, h * 0.25), 0.24 * sway);
        final hanger = Path()
          ..moveTo(cx, h * 0.36)
          ..lineTo(w * 0.80, h * 0.68)
          ..lineTo(w * 0.20, h * 0.68)
          ..close();
        canvas.drawPath(hanger, fill);
        canvas.drawPath(hanger, stroke);
        canvas.drawArc(Rect.fromLTWH(w * 0.44, h * 0.20, w * 0.12, h * 0.16),
            math.pi, math.pi * 1.5, false, stroke);
        break;

      case 'trash_bin':
        // Cubo de basura con tapa y estrías
        final bin = Rect.fromLTWH(w * 0.28, h * 0.34, w * 0.44, h * 0.46);
        canvas.drawRect(bin, fill);
        canvas.drawRect(bin, stroke);
        canvas.drawLine(
          Offset(w * 0.22, h * 0.34),
          Offset(w * (0.78 - 0.04 * pulse), h * (0.34 - 0.20 * pulse)),
          stroke,
        );
        canvas.drawLine(
            Offset(w * 0.42, h * 0.44), Offset(w * 0.42, h * 0.70), softStroke);
        canvas.drawLine(
            Offset(w * 0.58, h * 0.44), Offset(w * 0.58, h * 0.70), softStroke);
        break;

      case 'recycle_loop':
        // El símbolo de reciclaje gira en bucle.
        rotateAround(Offset(cx, h * 0.54), phase);
        final tri = Path()
          ..moveTo(cx, h * 0.20)
          ..lineTo(w * 0.78, h * 0.72)
          ..lineTo(w * 0.22, h * 0.72)
          ..close();
        canvas.drawPath(tri, fill);
        canvas.drawPath(tri, stroke);
        canvas.drawCircle(Offset(cx, h * 0.54), w * 0.09, softFill);
        break;

      case 'watering_can':
        // La regadera se inclina para verter agua.
        rotateAround(Offset(w * 0.47, h * 0.56), 0.36 * pulse);
        final canBody = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.28, h * 0.40, w * 0.38, h * 0.36),
          Radius.circular(w * 0.06),
        );
        canvas.drawRRect(canBody, fill);
        canvas.drawRRect(canBody, stroke);
        canvas.drawLine(
            Offset(w * 0.66, h * 0.56), Offset(w * 0.82, h * 0.34), stroke);
        canvas.drawArc(Rect.fromLTWH(w * 0.18, h * 0.42, w * 0.16, h * 0.26),
            math.pi / 2, math.pi, false, stroke);
        for (var i = 0; i < 2; i++) {
          final fall = (progress * 2 + i * 0.5) % 1.0;
          drawDrop(
              Offset(w * (0.83 + 0.10 * fall), h * (0.35 + 0.32 * fall)), fall);
        }
        break;

      case 'pet_care':
      default:
        // La almohadilla se expande al apoyar la pata.
        canvas.translate(cx, h * 0.70);
        canvas.scale(1 + 0.12 * pulse, 1 - 0.13 * pulse);
        canvas.translate(-cx, -h * 0.70);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, h * 0.58),
                width: w * 0.34,
                height: h * 0.26),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, h * 0.58),
                width: w * 0.34,
                height: h * 0.26),
            stroke);
        for (int i = -1; i <= 1; i++) {
          final toe = Offset(cx + i * w * 0.14, h * (i == 0 ? 0.30 : 0.36));
          canvas.drawCircle(toe, w * 0.065, fill);
          canvas.drawCircle(toe, w * 0.065, stroke);
        }
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChoreVectorPainter oldDelegate) =>
      oldDelegate.iconKey != iconKey ||
      oldDelegate.accent != accent ||
      oldDelegate.motion != motion ||
      oldDelegate.phaseOffset != phaseOffset;
}
