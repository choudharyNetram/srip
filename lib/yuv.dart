import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class YuvService {
  final String baseUrl;
  
  YuvService(this.baseUrl);
  
  Future<void> sendYUVData(Uint8List yuvData) async {
    String base64Data = base64.encode(yuvData);

    String url = '$baseUrl/upload-yuv';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'yuv_data': base64Data,
        },
      );

      if (response.statusCode == 200) {
        print('YUV data uploaded successfully');
      } else {
        print('Failed to upload YUV data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading YUV data: $e');
    }
  }
}
