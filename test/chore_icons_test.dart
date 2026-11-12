import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:casvium/data/chore_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _columns = 6;
const _cellSize = 60;
const _galleryWidth = _columns * _cellSize;

void main() {
  testWidgets('Todos los iconos se animan y respetan el movimiento reducido',
      (tester) async {
    final galleryKey = GlobalKey();

    Widget gallery({bool reduceMotion = false}) => Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: Center(
              child: RepaintBoundary(
                key: galleryKey,
                child: SizedBox(
                  width: _galleryWidth.toDouble(),
                  child: Wrap(
                    children: [
                      for (final icon in ChoreIconsCatalog.all)
                        SizedBox.square(
                          dimension: _cellSize.toDouble(),
                          child: Center(
                            child: ChoreCustomIcon(iconKey: icon.key),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

    Future<Uint8List> frame() async {
      final gallery =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(galleryKey));
      return (await tester.runAsync(() async {
        final image = await gallery.toImage();
        try {
          final pixels = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          return pixels.buffer
              .asUint8List(pixels.offsetInBytes, pixels.lengthInBytes);
        } finally {
          image.dispose();
        }
      }))!;
    }

    await tester.pumpWidget(gallery());
    final start = await frame();
    await tester.pump(const Duration(milliseconds: 610));
    final animated = await frame();

    for (final (index, icon) in ChoreIconsCatalog.all.indexed) {
      expect(
        _iconChanged(start, animated, index),
        isTrue,
        reason: '${icon.key} debe cambiar al avanzar el tiempo.',
      );
    }

    await tester.pumpWidget(gallery(reduceMotion: true));
    final still = await frame();
    await tester.pump(const Duration(milliseconds: 610));
    expect(listEquals(still, await frame()), isTrue);

    await tester.pumpWidget(gallery());
    await tester.pump(const Duration(milliseconds: 610));
    expect(listEquals(still, await frame()), isFalse);
  });
}

bool _iconChanged(Uint8List first, Uint8List second, int index) {
  final left = (index % _columns) * _cellSize;
  final top = (index ~/ _columns) * _cellSize;
  for (var y = top; y < top + _cellSize; y++) {
    final start = (y * _galleryWidth + left) * 4;
    final end = start + _cellSize * 4;
    for (var byte = start; byte < end; byte++) {
      if (first[byte] != second[byte]) return true;
    }
  }
  return false;
}
