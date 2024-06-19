import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class CameraSocket extends StatefulWidget {
  const CameraSocket({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CameraSocket> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraSocket> {
  late CameraController controller;
  bool isCameraInitialized = false;
  String serverResponse = '';
  late WebSocketChannel channel;
  Timer? captureTimer;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await initializeCameras();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[1], ResolutionPreset.max);
      try {
        await controller.initialize();
        if (!mounted) return;

        setState(() {
          isCameraInitialized = true;
        });

        // Initialize WebSocket channel
        channel = WebSocketChannel.connect(Uri.parse('ws://10.240.0.166:5000'));
        channel.stream.listen((message) {
          setState(() {
            serverResponse = message;
          });
        });

        // Start capturing and sending images automatically after camera initialization
        _startAutoCaptureAndSend();
      } catch (e) {
        print("Error initializing camera: $e");
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    captureTimer?.cancel();
    channel.sink.close();
    super.dispose();
  }

  void _sendImageToServer(Uint8List imageData) async {
    // Compress the image
    img.Image? image = img.decodeImage(imageData);
    Uint8List compressedImage = Uint8List.fromList(img.encodeJpg(image!, quality: 75));

    // Convert image data to base64 string
    String base64Image = base64Encode(compressedImage);
    print("Base64 Image Length: ${base64Image.length}");

    // Send image data to server via WebSocket
    channel.sink.add(jsonEncode({'image': base64Image}));
  }

  void _captureAndSendImage() async {
    if (isSending) return;
    isSending = true;
    try {
      XFile? imageFile = await controller.takePicture();
      if (imageFile != null) {
        Uint8List imageData = await imageFile.readAsBytes();
        _sendImageToServer(imageData);
      }
    } catch (e) {
      print("Error capturing image: $e");
    } finally {
      isSending = false;
    }
  }

  void _startAutoCaptureAndSend() {
    captureTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _captureAndSendImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: isCameraInitialized
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
                SizedBox(height: 20),
                Text(serverResponse),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
