import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyPageStream extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyPageStream> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  String _serverResponse = "Awaiting response...";
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final camera = await _getCamera(CameraLensDirection.front);
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await _cameraController.initialize();
    _cameraController.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;
      _processCameraImage(image);
    });
  }

  Future<CameraDescription> _getCamera(CameraLensDirection direction) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == direction,
      ),
    );
  }

  void _processCameraImage(CameraImage image) async {
    try {
      final imageBytes = _convertYUV420ToImageColor(image);
      _sendImageToServer(imageBytes);
    } catch (e) {
      print("Error processing image: $e");
    } finally {
      _isDetecting = false;
    }
  }

  Uint8List _convertYUV420ToImageColor(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int size = width * height;
    final Uint8List yuvBytes = Uint8List(size * 3 ~/ 2);
    final Uint8List uBuffer = image.planes[1].bytes;
    final Uint8List vBuffer = image.planes[2].bytes;

    for (int i = 0; i < size; i++) {
      yuvBytes[i] = image.planes[0].bytes[i];
    }

    int uvIndex = size;
    for (int i = 0; i < size / 2; i++) {
      yuvBytes[uvIndex++] = vBuffer[i];
      yuvBytes[uvIndex++] = uBuffer[i];
    }

    return yuvBytes;
  }

  void _sendImageToServer(Uint8List imageData) async {
    // Convert image data to base64 string
    String base64Image = base64Encode(imageData);

    // Send image data to server
    final uri = Uri.parse('http://10.240.0.166:5000/predict');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      setState(() {
        _serverResponse = responseBody.toString();
      });
    } else {
      setState(() {
        _serverResponse = 'Error: ${response.reasonPhrase}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Example')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(child: CameraPreview(_cameraController)),
                Text(_serverResponse),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
