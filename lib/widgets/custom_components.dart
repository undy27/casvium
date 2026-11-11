import 'package:flutter/material.dart';
import '../theme/casvium_theme.dart';
import '../data/chore_icons.dart';

/// Tarjeta táctil Neo-Bento con borde de tinta y sombra desplazada sólida
/// que reacciona físicamente al pulsarla (sin aspecto genérico de Material Card).
class CasviumBentoCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double shadowOffset;

  const CasviumBentoCard({
    super.key,
    required this.child,
    this.backgroundColor = CasviumColors.surface,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.shadowOffset = 4.0,
  });

  @override
  State<CasviumBentoCard> createState() => _CasviumBentoCardState();
}

class _CasviumBentoCardState extends State<CasviumBentoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final offset = _pressed ? 1.0 : widget.shadowOffset;
    final translate = _pressed ? widget.shadowOffset - 1.0 : 0.0;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        transform: Matrix4.translationValues(translate, translate, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: CasviumColors.ink,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: CasviumColors.ink,
              offset: Offset(offset, offset),
              blurRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Botón de acción artesanal con sombra dura y respuesta elástica.
class CasviumActionPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final bool compact;

  const CasviumActionPill({
    super.key,
    required this.label,
    this.icon,
    this.color = CasviumColors.terracotta,
    this.textColor = CasviumColors.surface,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return CasviumBentoCard(
      backgroundColor: color,
      shadowOffset: 3.0,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 8 : 11,
      ),
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 16 : 18, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12.5 : 14,
              fontWeight: FontWeight.w800,
              color: textColor,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ),
    );
  }
}

/// Dock flotante personalizado de navegación inferior (sustituye al BottomNavigationBar estándar).
class CasviumFloatingDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const CasviumFloatingDock({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  static const _items = [
    (label: 'Hogar', iconKey: 'mop_bucket'),
    (label: 'Tareas', iconKey: 'broom_dustpan'),
    (label: 'Sesiones', iconKey: 'cooking_pot'),
    (label: 'Infografías', iconKey: 'watering_can'),
    (label: 'Railway DB', iconKey: 'pantry_jars'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: CasviumColors.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = index == currentIndex;
          return GestureDetector(
            onTap: () => onChanged(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 12 : 8,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: selected ? CasviumColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChoreCustomIcon(
                    iconKey: item.iconKey,
                    size: 26,
                    showBadgeBorder: selected,
                  ),
                  if (selected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: CasviumColors.ink,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Selector interactivo personalizado de duración estimada (en minutos) con dial visual y botones rápidos.
class DurationCustomSelector extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;

  const DurationCustomSelector({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  static const _presets = [5, 10, 15, 20, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CasviumColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CasviumColors.ink, width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'DURACIÓN ESTIMADA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                  color: CasviumColors.inkMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: CasviumColors.terracotta,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: CasviumColors.ink, width: 1.5),
                ),
                child: Text(
                  '$minutes min',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: CasviumColors.surface,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: CasviumColors.terracotta,
              inactiveTrackColor: CasviumColors.surface,
              thumbColor: CasviumColors.mustard,
              trackHeight: 8,
            ),
            child: Slider(
              min: 5,
              max: 120,
              divisions: 23,
              value: minutes.clamp(5, 120).toDouble(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _presets.map((preset) {
              final active = preset == minutes;
              return GestureDetector(
                onTap: () => onChanged(preset),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: active
                        ? CasviumColors.ink
                        : CasviumColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CasviumColors.ink, width: 1.4),
                  ),
                  child: Text(
                    '${preset}m',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: active
                          ? CasviumColors.surface
                          : CasviumColors.ink,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
