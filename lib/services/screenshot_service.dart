import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenshotService {
  final ScreenshotController _screenshotController = ScreenshotController();
  
  ScreenshotController get screenshotController => _screenshotController;

  Future<Uint8List?> captureWidget(Widget widget, {double pixelRatio = 3.0}) async {
    try {
      final Uint8List? image = await _screenshotController.captureFromWidget(
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

  Future<String?> saveToGallery(Uint8List imageBytes, {String? fileName}) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        // Try photos permission for newer Android
        final photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          debugPrint('Storage permission denied');
          return null;
        }
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        // Fallback to app documents directory
        final docDir = await getApplicationDocumentsDirectory();
        return await _saveImage(docDir.path, imageBytes, fileName);
      }

      // Try to save to Pictures folder
      final picturesPath = directory.path.replaceAll(
        RegExp(r'/Android/data/[^/]+/files'),
        '/Pictures/FakeChat',
      );
      
      return await _saveImage(picturesPath, imageBytes, fileName);
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return null;
    }
  }

  Future<String> _saveImage(String path, Uint8List imageBytes, String? fileName) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = fileName ?? 'fake_chat_$timestamp.png';
    final filePath = '$path/$name';
    
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    
    return filePath;
  }

  Future<Uint8List?> captureChatArea({
    required GlobalKey chatAreaKey,
    double pixelRatio = 3.0,
  }) async {
    try {
      final RenderRepaintBoundary? boundary = 
          chatAreaKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture chat area error: $e');
      return null;
    }
  }
}
