import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'socket_service.dart';

late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class SingleImage extends StatefulWidget {
  const SingleImage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SingleImage> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<SingleImage> {
  late CameraController controller;
  bool isCameraInitialized = false;
  String serverConnected = '';

  @override
  void initState() {
    super.initState();
    _initializeSocketAndCamera();
  }

  Future<void> _initializeSocketAndCamera() async {
    await initializeCameras();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[1], ResolutionPreset.medium);
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        isCameraInitialized = true;
      });
    }

    final socketService = Provider.of<SocketService>(context, listen: false);
    if (socketService.socket.connected) {
      setState(() {
        serverConnected = 'Connected to server';
      });
    } else {
      socketService.socket.on('connect', (_) {
        if (mounted) {
          setState(() {
            serverConnected = 'Connected to server';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _sendImageToServer(Uint8List imageData) {
    try {
      String base64Image = base64Encode(imageData);
      print('Sending image data: ${base64Image.substring(0, 20)}...'); // Debug print first 20 chars
      final socketService = Provider.of<SocketService>(context, listen: false);
      // socketService.socket.emit('predict', {'image': base64Image});
       socketService.socket.emit('prediction_ops_start') ; 
      socketService.socket.emit('predict_ops', {'image': base64Image});
     // print(socketService.weights) ; 
    } catch (e) {
      print('Error encoding image: $e');
    }
  }

  void _captureAndSendImage() async {
    try {
      XFile? imageFile = await controller.takePicture();
      if (imageFile != null) {
        Uint8List imageData = await imageFile.readAsBytes();
        print('Image captured, size: ${imageData.length}');
        _sendImageToServer(imageData);
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
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
                ElevatedButton(
                  onPressed: _captureAndSendImage,
                  child: Text('Capture and Send Image'),
                ),
                SizedBox(height: 20),
                Text(socketService.serverResponse),
                Text(serverConnected),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
