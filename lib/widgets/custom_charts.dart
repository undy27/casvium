import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/casvium_theme.dart';
import '../data/chore_icons.dart';

/// 1. Infografía Circular de Equidad del Hogar (Reparto de minutos entre miembros)
class MemberEquityRingChart extends StatelessWidget {
  final List<HouseholdMember> members;
  final List<WorkSession> sessions;

  const MemberEquityRingChart({
    super.key,
    required this.members,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, int> minutesByMember = {
      for (final m in members) m.id: 0,
    };
    for (final s in sessions) {
      minutesByMember[s.memberId] =
          (minutesByMember[s.memberId] ?? 0) + s.durationMinutes;
      for (final coId in s.coWorkerIds) {
        if (minutesByMember.containsKey(coId)) {
          minutesByMember[coId] =
              (minutesByMember[coId] ?? 0) + (s.durationMinutes ~/ 2);
        }
      }
    }

    final totalMinutes =
        minutesByMember.values.fold<int>(0, (sum, item) => sum + item);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: _EquityDonutPainter(
                  members: members,
                  minutesByMember: minutesByMember,
                  totalMinutes: totalMinutes,
                  progress: progress,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(totalMinutes * progress).round()}m',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: CasviumColors.ink,
                        ),
                      ),
                      const Text(
                        'TOTAL HOGAR',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: CasviumColors.inkMuted,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: members.map((member) {
                  final mins = minutesByMember[member.id] ?? 0;
                  final pct = totalMinutes > 0
                      ? ((mins / totalMinutes) * 100).round()
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: member.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: CasviumColors.ink, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                member.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: CasviumColors.ink,
                                  fontFamily: 'Segoe UI',
                                ),
                              ),
                            ),
                            Text(
                              '$mins min ($pct%)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: CasviumColors.inkMuted,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: CasviumColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: totalMinutes > 0
                                  ? (mins / totalMinutes) * progress
                                  : 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: member.color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EquityDonutPainter extends CustomPainter {
  final List<HouseholdMember> members;
  final Map<String, int> minutesByMember;
  final int totalMinutes;
  final double progress;

  const _EquityDonutPainter({
    required this.members,
    required this.minutesByMember,
    required this.totalMinutes,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.39;
    const strokeWidth = 22.0;

    final trackPaint = Paint()
      ..color = CasviumColors.surfaceAlt
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (totalMinutes <= 0) return;

    double startAngle = -math.pi / 2;
    for (final member in members) {
      final mins = minutesByMember[member.id] ?? 0;
      if (mins <= 0) continue;
      final sweep = (mins / totalMinutes) * 2 * math.pi * progress;

      final segPaint = Paint()
        ..color = member.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        segPaint,
      );

      startAngle += sweep;
    }

    // Bordes interiores y exteriores tipo sello editorial
    final borderPaint = Paint()
      ..color = CasviumColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius + strokeWidth / 2, borderPaint);
    canvas.drawCircle(center, radius - strokeWidth / 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _EquityDonutPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.totalMinutes != totalMinutes;
}

/// 2. Curva Semanal de Pulso Doméstico (Spline animada con área rellena)
class WeeklyPulseWaveChart extends StatelessWidget {
  final List<WorkSession> sessions;

  const WeeklyPulseWaveChart({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> labels = [];
    final List<int> dailyMinutes = [];
    const weekdayShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      labels.add(weekdayShort[day.weekday - 1]);
      final mins = sessions.where((s) {
        return s.performedAt.year == day.year &&
            s.performedAt.month == day.month &&
            s.performedAt.day == day.day;
      }).fold<int>(0, (sum, s) => sum + s.durationMinutes);
      dailyMinutes.add(mins);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutQuart,
      builder: (context, progress, _) {
        return Column(
          children: [
            SizedBox(
              height: 155,
              width: double.infinity,
              child: CustomPaint(
                painter: _WeeklySplinePainter(
                  values: dailyMinutes,
                  progress: progress,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isToday = index == 6;
                return Column(
                  children: [
                    Text(
                      '${dailyMinutes[index]}m',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isToday
                            ? CasviumColors.terracotta
                            : CasviumColors.ink,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isToday
                            ? CasviumColors.terracotta
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isToday
                              ? CasviumColors.surface
                              : CasviumColors.inkMuted,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _WeeklySplinePainter extends CustomPainter {
  final List<int> values;
  final double progress;

  const _WeeklySplinePainter({
    required this.values,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final maxVal = math.max(60, values.fold<int>(0, math.max));

    // Líneas guía punteadas horizontales
    final guidePaint = Paint()
      ..color = CasviumColors.ink.withOpacity(0.10)
      ..strokeWidth = 1;
    for (int g = 1; g <= 3; g++) {
      final y = h * (g / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), guidePaint);
    }

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (w / (values.length - 1)) * i;
      final normalized = (values[i] / maxVal) * progress;
      final y = h - 18 - (normalized * (h - 36));
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();

    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        CasviumColors.terracotta.withOpacity(0.42),
        CasviumColors.mustard.withOpacity(0.05),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(fillPath, Paint()..shader = shader);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = CasviumColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    for (final pt in points) {
      canvas.drawCircle(
          pt, 5.5, Paint()..color = CasviumColors.terracotta);
      canvas.drawCircle(
        pt,
        5.5,
        Paint()
          ..color = CasviumColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklySplinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 3. Infografía de Dedicación por Estancia + Comparativa Duración Estimada vs Real
class RoomEffortInfographic extends StatelessWidget {
  final List<Room> rooms;
  final List<ChoreTask> tasks;
  final List<WorkSession> sessions;

  const RoomEffortInfographic({
    super.key,
    required this.rooms,
    required this.tasks,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, int> roomMinutes = {for (final r in rooms) r.id: 0};
    for (final s in sessions) {
      if (s.roomId != null && roomMinutes.containsKey(s.roomId)) {
        roomMinutes[s.roomId!] =
            (roomMinutes[s.roomId!] ?? 0) + s.durationMinutes;
      } else {
        final task = tasks.where((t) => t.id == s.taskId).firstOrNull;
        if (task != null && task.roomIds.isNotEmpty) {
          final firstRoom = task.roomIds.first;
          roomMinutes[firstRoom] =
              (roomMinutes[firstRoom] ?? 0) + s.durationMinutes;
        }
      }
    }

    final maxMins = math.max(
      30,
      roomMinutes.values.fold<int>(0, math.max),
    );

    return Column(
      children: rooms.map((room) {
        final mins = roomMinutes[room.id] ?? 0;
        final ratio = (mins / maxMins).clamp(0.0, 1.0);
        final taskCount =
            tasks.where((t) => t.roomIds.contains(room.id)).length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              ChoreCustomIcon(
                iconKey: room.iconKey,
                size: 38,
                backgroundColor: room.color.withOpacity(0.22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: CasviumColors.ink,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                        Text(
                          '$mins min · $taskCount tareas',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: CasviumColors.inkMuted,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: CasviumColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: CasviumColors.ink,
                          width: 1.4,
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: math.max(0.06, ratio),
                        child: Container(
                          decoration: BoxDecoration(
                            color: room.color,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
