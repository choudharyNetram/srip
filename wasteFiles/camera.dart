import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CameraExample> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  late CameraController controller;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await initializeCameras();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        isCameraInitialized = true;
        // Start streaming frames to the backend
        controller.startImageStream((CameraImage image) {
          _sendImageToServer(image);
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _sendImageToServer(CameraImage cameraImage) async {
    // Convert camera image data to bytes
    List<int> bytes = _concatenatePlanes(cameraImage.planes);

    // Convert bytes to base64 string
    String base64Image = base64Encode(bytes);

    // Send base64 string to the server
    final uri = Uri.parse('http://127.0.0.1:5000/predict');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print(responseBody);
      // Handle the response from the server
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  List<int> _concatenatePlanes(List<Plane> planes) {
    List<int> bytes = [];
    for (Plane plane in planes) {
      bytes.addAll(plane.bytes);
    }
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: isCameraInitialized
          ? CameraPreview(controller)
          : Center(child: CircularProgressIndicator()),
    );
  }
}

void main() async {
  runApp(MaterialApp(
    home: CameraExample(title: 'Camera Example'),
  ));
}
