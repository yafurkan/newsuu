import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() async {
  // Flutter engine'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Icon oluştur
  await generateAppIcon();

  print('App icon başarıyla oluşturuldu!');
  exit(0);
}

Future<void> generateAppIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Arka plan
  final backgroundPaint = Paint()
    ..color =
        const Color(0xFF1976D2) // Su mavisi
    ..style = PaintingStyle.fill;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 512, 512),
      const Radius.circular(128),
    ),
    backgroundPaint,
  );

  // Su damlası şekli
  final dropPath = Path();

  // Su damlası koordinatları (512x512 için merkezi)
  final centerX = 256.0;
  final centerY = 200.0;
  final radius = 120.0;

  // Su damlası şekli çiz
  dropPath.moveTo(centerX, centerY - radius);
  dropPath.quadraticBezierTo(
    centerX - radius * 0.7,
    centerY - radius * 0.3,
    centerX - radius * 0.5,
    centerY + radius * 0.3,
  );
  dropPath.quadraticBezierTo(
    centerX - radius * 0.3,
    centerY + radius * 0.8,
    centerX,
    centerY + radius,
  );
  dropPath.quadraticBezierTo(
    centerX + radius * 0.3,
    centerY + radius * 0.8,
    centerX + radius * 0.5,
    centerY + radius * 0.3,
  );
  dropPath.quadraticBezierTo(
    centerX + radius * 0.7,
    centerY - radius * 0.3,
    centerX,
    centerY - radius,
  );

  // Su damlası boyası
  final dropPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  canvas.drawPath(dropPath, dropPaint);

  // Metin ekle
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'Su',
      style: TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );

  textPainter.layout();
  textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, 350));

  // Picture'ı al
  final picture = recorder.endRecording();
  final img = await picture.toImage(512, 512);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

  // Dosyaya kaydet
  final file = File('assets/images/app_icon.png');
  await file.writeAsBytes(byteData!.buffer.asUint8List());
}
