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
      label: 'Fregar suelos',
      category: 'Suelos',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'vacuum',
      label: 'Aspirar',
      category: 'Suelos',
      accentColor: CasviumColors.terracotta,
    ),
    ChoreIconDefinition(
      key: 'broom_dustpan',
      label: 'Barrer y recoger',
      category: 'Suelos',
      accentColor: CasviumColors.mustard,
    ),
    ChoreIconDefinition(
      key: 'dust_feather',
      label: 'Quitar el polvo',
      category: 'Superficies',
      accentColor: CasviumColors.plum,
    ),
    ChoreIconDefinition(
      key: 'window_spray',
      label: 'Cristales y espejos',
      category: 'Superficies',
      accentColor: CasviumColors.mint,
    ),
    ChoreIconDefinition(
      key: 'rug_beater',
      label: 'Sacudir alfombras',
      category: 'Suelos',
      accentColor: CasviumColors.terracotta,
    ),

    // Cocina y alimentación (7-14)
    ChoreIconDefinition(
      key: 'dishes_sponge',
      label: 'Fregar platos',
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
      label: 'Limpiar fogones/vitro',
      category: 'Cocina',
      accentColor: CasviumColors.terracotta,
    ),
    ChoreIconDefinition(
      key: 'oven_sparkle',
      label: 'Desengrasar horno',
      category: 'Cocina',
      accentColor: CasviumColors.coral,
    ),
    ChoreIconDefinition(
      key: 'fridge_clean',
      label: 'Ordenar nevera',
      category: 'Cocina',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'cooking_pot',
      label: 'Cocinar / Batch cooking',
      category: 'Cocina',
      accentColor: CasviumColors.terracotta,
    ),
    ChoreIconDefinition(
      key: 'grocery_bag',
      label: 'Compra semanal',
      category: 'Cocina',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'pantry_jars',
      label: 'Despensa y tarros',
      category: 'Cocina',
      accentColor: CasviumColors.mustard,
    ),

    // Colada y textil (15-19)
    ChoreIconDefinition(
      key: 'washing_machine',
      label: 'Poner lavadora',
      category: 'Colada',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'clothesline',
      label: 'Tender la ropa',
      category: 'Colada',
      accentColor: CasviumColors.mint,
    ),
    ChoreIconDefinition(
      key: 'steam_iron',
      label: 'Planchar ropa',
      category: 'Colada',
      accentColor: CasviumColors.plum,
    ),
    ChoreIconDefinition(
      key: 'folded_shirts',
      label: 'Doblar y guardar',
      category: 'Colada',
      accentColor: CasviumColors.mustard,
    ),
    ChoreIconDefinition(
      key: 'shoe_rack',
      label: 'Limpiar calzado',
      category: 'Colada',
      accentColor: CasviumColors.terracotta,
    ),

    // Baño e higiene (20-23)
    ChoreIconDefinition(
      key: 'toilet_brush',
      label: 'Desinfectar WC',
      category: 'Baño',
      accentColor: CasviumColors.cobalt,
    ),
    ChoreIconDefinition(
      key: 'shower_head',
      label: 'Ducha y mampara',
      category: 'Baño',
      accentColor: CasviumColors.mint,
    ),
    ChoreIconDefinition(
      key: 'sink_faucet',
      label: 'Lavabo y grifería',
      category: 'Baño',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'towels_stack',
      label: 'Cambiar toallas',
      category: 'Baño',
      accentColor: CasviumColors.plum,
    ),

    // Dormitorio y orden (24-26)
    ChoreIconDefinition(
      key: 'bed_pillow',
      label: 'Hacer la cama',
      category: 'Dormitorio',
      accentColor: CasviumColors.mustard,
    ),
    ChoreIconDefinition(
      key: 'fresh_sheets',
      label: 'Cambiar sábanas',
      category: 'Dormitorio',
      accentColor: CasviumColors.plum,
    ),
    ChoreIconDefinition(
      key: 'wardrobe_hanger',
      label: 'Ordenar armario',
      category: 'Dormitorio',
      accentColor: CasviumColors.terracotta,
    ),

    // Exterior, residuos, mascotas y mantenimiento (27-30)
    ChoreIconDefinition(
      key: 'trash_bin',
      label: 'Sacar la basura',
      category: 'Hogar',
      accentColor: CasviumColors.ink,
    ),
    ChoreIconDefinition(
      key: 'recycle_loop',
      label: 'Reciclaje y vidrio',
      category: 'Hogar',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'watering_can',
      label: 'Regar plantas',
      category: 'Exterior',
      accentColor: CasviumColors.sage,
    ),
    ChoreIconDefinition(
      key: 'pet_care',
      label: 'Cuidar mascota',
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

/// Widget artesanal que dibuja cualquiera de los 30 iconos con trazo editorial e ilustración vectorial propia.
class ChoreCustomIcon extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final def = ChoreIconsCatalog.byKey(iconKey);
    final bg = backgroundColor ?? def.accentColor.withOpacity(0.16);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.30),
        border: showBadgeBorder
            ? Border.all(color: CasviumColors.ink, width: 1.8)
            : null,
        boxShadow: showBadgeBorder
            ? const [
                BoxShadow(
                  color: CasviumColors.ink,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                )
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _ChoreVectorPainter(
          iconKey: def.key,
          accent: def.accentColor,
        ),
      ),
    );
  }
}

class _ChoreVectorPainter extends CustomPainter {
  final String iconKey;
  final Color accent;

  const _ChoreVectorPainter({
    required this.iconKey,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

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
            Offset(w * 0.66, h * 0.16), Offset(w * 0.46, h * 0.56), stroke);
        canvas.drawCircle(Offset(w * 0.34, h * 0.28), w * 0.06, softFill);
        canvas.drawCircle(Offset(w * 0.34, h * 0.28), w * 0.06, stroke);
        break;

      case 'vacuum':
        // Cuerpo redondeado con ruedas y tubo flexible
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.44, h * 0.28),
          Radius.circular(w * 0.14),
        );
        canvas.drawRRect(body, fill);
        canvas.drawRRect(body, stroke);
        canvas.drawCircle(Offset(w * 0.30, h * 0.76), w * 0.07, softFill);
        canvas.drawCircle(Offset(w * 0.30, h * 0.76), w * 0.07, stroke);
        canvas.drawLine(
            Offset(w * 0.64, h * 0.56), Offset(w * 0.78, h * 0.24), stroke);
        canvas.drawLine(
            Offset(w * 0.70, h * 0.76), Offset(w * 0.84, h * 0.76), stroke);
        break;

      case 'broom_dustpan':
        // Escoba inclinada con cerdas
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
        // Plumero mullido
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
        canvas.drawCircle(Offset(w * 0.74, h * 0.24), w * 0.03, fill);
        canvas.drawCircle(Offset(w * 0.80, h * 0.32), w * 0.025, fill);
        break;

      case 'rug_beater':
        // Alfombra con flecos
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
        canvas.drawCircle(Offset(w * 0.72, h * 0.26), w * 0.06, softFill);
        canvas.drawCircle(Offset(w * 0.72, h * 0.26), w * 0.06, stroke);
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
        canvas.drawCircle(Offset(w * 0.40, h * 0.58), w * 0.10, fill);
        canvas.drawCircle(Offset(w * 0.40, h * 0.58), w * 0.10, stroke);
        canvas.drawCircle(Offset(w * 0.58, h * 0.58), w * 0.10, stroke);
        break;

      case 'stove_flame':
        // Quemador de cocina y llama
        canvas.drawOval(
            Rect.fromLTWH(w * 0.20, h * 0.58, w * 0.60, h * 0.20), stroke);
        final flame = Path()
          ..moveTo(cx, h * 0.20)
          ..quadraticBezierTo(w * 0.76, h * 0.42, cx, h * 0.64)
          ..quadraticBezierTo(w * 0.24, h * 0.42, cx, h * 0.20);
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
        break;

      case 'grocery_bag':
        // Bolsa de compra con hojas frescas
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
        canvas.drawRect(
            Rect.fromLTWH(w * 0.34, h * 0.22, w * 0.32, h * 0.10), fill);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.34, h * 0.22, w * 0.32, h * 0.10), stroke);
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
        canvas.drawCircle(Offset(cx, h * 0.54), w * 0.18, fill);
        canvas.drawCircle(Offset(cx, h * 0.54), w * 0.18, stroke);
        canvas.drawLine(
            Offset(w * 0.22, h * 0.32), Offset(w * 0.78, h * 0.32), stroke);
        break;

      case 'clothesline':
        // Cuerda de tender con camiseta colgada
        canvas.drawLine(
            Offset(w * 0.16, h * 0.28), Offset(w * 0.84, h * 0.28), stroke);
        final shirt = Path()
          ..moveTo(w * 0.34, h * 0.28)
          ..lineTo(w * 0.66, h * 0.28)
          ..lineTo(w * 0.74, h * 0.46)
          ..lineTo(w * 0.62, h * 0.50)
          ..lineTo(w * 0.62, h * 0.76)
          ..lineTo(w * 0.38, h * 0.76)
          ..lineTo(w * 0.38, h * 0.50)
          ..lineTo(w * 0.26, h * 0.46)
          ..close();
        canvas.drawPath(shirt, fill);
        canvas.drawPath(shirt, stroke);
        break;

      case 'steam_iron':
        // Plancha de vapor
        final iron = Path()
          ..moveTo(w * 0.20, h * 0.68)
          ..lineTo(w * 0.78, h * 0.68)
          ..quadraticBezierTo(w * 0.72, h * 0.42, w * 0.40, h * 0.42)
          ..close();
        canvas.drawPath(iron, fill);
        canvas.drawPath(iron, stroke);
        canvas.drawLine(
            Offset(w * 0.38, h * 0.42), Offset(w * 0.62, h * 0.30), stroke);
        break;

      case 'folded_shirts':
        // Pila de ropa doblada
        for (int i = 0; i < 3; i++) {
          final r = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.24, h * (0.26 + i * 0.18), w * 0.52, h * 0.14),
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
        break;

      case 'shower_head':
        // Alcachofa de ducha y gotas
        canvas.drawArc(Rect.fromLTWH(w * 0.28, h * 0.20, w * 0.44, h * 0.32),
            math.pi, math.pi, true, fill);
        canvas.drawArc(Rect.fromLTWH(w * 0.28, h * 0.20, w * 0.44, h * 0.32),
            math.pi, math.pi, true, stroke);
        for (int i = 0; i < 3; i++) {
          final dx = w * (0.36 + i * 0.14);
          canvas.drawLine(Offset(dx, h * 0.46), Offset(dx, h * 0.74), stroke);
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
        break;

      case 'towels_stack':
        // Toalla colgada en barra
        canvas.drawLine(
            Offset(w * 0.20, h * 0.28), Offset(w * 0.80, h * 0.28), stroke);
        final towel = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.30, h * 0.28, w * 0.40, h * 0.48),
          Radius.circular(w * 0.04),
        );
        canvas.drawRRect(towel, fill);
        canvas.drawRRect(towel, stroke);
        canvas.drawLine(
            Offset(w * 0.30, h * 0.64), Offset(w * 0.70, h * 0.64), stroke);
        break;

      case 'bed_pillow':
        // Cama con cabecero y almohada
        canvas.drawRect(
            Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.60, h * 0.24), fill);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.60, h * 0.24), stroke);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.26, h * 0.34, w * 0.22, h * 0.14), softFill);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.26, h * 0.34, w * 0.22, h * 0.14), stroke);
        canvas.drawLine(
            Offset(w * 0.20, h * 0.26), Offset(w * 0.20, h * 0.78), stroke);
        canvas.drawLine(
            Offset(w * 0.80, h * 0.48), Offset(w * 0.80, h * 0.78), stroke);
        break;

      case 'fresh_sheets':
        // Sábana ondeando al viento con estrellas de frescor
        final wave = Path()
          ..moveTo(w * 0.24, h * 0.28)
          ..quadraticBezierTo(cx, h * 0.20, w * 0.76, h * 0.30)
          ..lineTo(w * 0.72, h * 0.74)
          ..quadraticBezierTo(cx, h * 0.64, w * 0.28, h * 0.74)
          ..close();
        canvas.drawPath(wave, fill);
        canvas.drawPath(wave, stroke);
        break;

      case 'wardrobe_hanger':
        // Percha de ropa
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
            Offset(w * 0.22, h * 0.34), Offset(w * 0.78, h * 0.34), stroke);
        canvas.drawLine(
            Offset(w * 0.42, h * 0.44), Offset(w * 0.42, h * 0.70), stroke);
        canvas.drawLine(
            Offset(w * 0.58, h * 0.44), Offset(w * 0.58, h * 0.70), stroke);
        break;

      case 'recycle_loop':
        // Triángulo ecológico
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
        // Regadera de jardín
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
        break;

      case 'pet_care':
      default:
        // Huella de mascota cariñosa
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, h * 0.58), width: w * 0.34, height: h * 0.26),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, h * 0.58), width: w * 0.34, height: h * 0.26),
            stroke);
        for (int i = -1; i <= 1; i++) {
          final toe = Offset(cx + i * w * 0.14, h * (i == 0 ? 0.30 : 0.36));
          canvas.drawCircle(toe, w * 0.065, fill);
          canvas.drawCircle(toe, w * 0.065, stroke);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ChoreVectorPainter oldDelegate) =>
      oldDelegate.iconKey != iconKey || oldDelegate.accent != accent;
}
