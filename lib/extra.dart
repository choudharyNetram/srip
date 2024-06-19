 /*
  Uint8List _convertYUV420ToRGBArray(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel!;

      List<int> rgbBytes = List<int>.filled(width * height * 3, 0);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
          final int index = y * width + x;

          final int yp = image.planes[0].bytes[index];
          final int up = image.planes[1].bytes[uvIndex];
          final int vp = image.planes[2].bytes[uvIndex];

          int r = (yp + (vp * 1436 / 1024 - 179)).round().clamp(0, 255);
          int g = (yp - (up * 46549 / 131072) + 44 - (vp * 93604 / 131072) + 91).round().clamp(0, 255);
          int b = (yp + (up * 1814 / 1024 - 227)).round().clamp(0, 255);

          rgbBytes[(y * width + x) * 3] = r;
          rgbBytes[(y * width + x) * 3 + 1] = g;
          rgbBytes[(y * width + x) * 3 + 2] = b;
        }
      }
      return Uint8List.fromList(rgbBytes);
    } catch (e) {
      print("Error converting YUV to RGB: $e");
      return Uint8List(0);
    }
  }
*/