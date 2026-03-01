import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class ScreenshotService {
  final ScreenshotController _screenshotController = ScreenshotController();

  ScreenshotController get screenshotController => _screenshotController;

  Future<Uint8List?> captureWidget(Widget widget,
      {double pixelRatio = 3.0}) async {
    try {
      final Uint8List image = await _screenshotController.captureFromWidget(
        widget,
        pixelRatio: pixelRatio,
        delay: const Duration(milliseconds: 100),
      );
      return image;
    } catch (e) {
      debugPrint('Screenshot capture error: $e');
      return null;
    }
  }

  Future<String?> saveToGallery(Uint8List imageBytes,
      {String? fileName}) async {
    try {
      // Save to app documents directory (no permission needed)
      final docDir = await getApplicationDocumentsDirectory();
      final fakeChatDir = Directory('${docDir.path}/FakeChat');
      if (!await fakeChatDir.exists()) {
        await fakeChatDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'fake_chat_$timestamp.png';
      final filePath = '${fakeChatDir.path}/$name';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Also try to save to external Pictures folder if available
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final picturesPath = extDir.path.replaceAll(
            RegExp(r'/Android/data/[^/]+/files'),
            '/Pictures/FakeChat',
          );
          final picturesDir = Directory(picturesPath);
          if (!await picturesDir.exists()) {
            await picturesDir.create(recursive: true);
          }
          final extFile = File('$picturesPath/$name');
          await extFile.writeAsBytes(imageBytes);
          return '$picturesPath/$name';
        }
      } catch (e) {
        debugPrint('External save fallback: $e');
      }

      return filePath;
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return null;
    }
  }

  Future<Uint8List?> captureChatArea({
    required GlobalKey chatAreaKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      final RenderRepaintBoundary? boundary = chatAreaKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture chat area error: $e');
      return null;
    }
  }
}
