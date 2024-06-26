import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;


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
  String serverResponse = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await initializeCameras();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[1], ResolutionPreset.max);
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _sendImageToServer(Uint8List imageData) async {
    // Convert image data to base64 string
    String base64Image = base64Encode(imageData);
    print("Base64 Image Length: ${base64Image.length}");

    // Send image data to server
    final uri = Uri.parse('http://10.240.0.166:5000/predict');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if(mounted){
        setState(() {
        serverResponse = responseBody.toString();
      });
      }
      
    } else {
      if(mounted){
        setState(() {
        serverResponse = 'Error: ${response.reasonPhrase}';
      });
      }
    }
  }

  void _captureAndSendImage() async {
    try {
      XFile? imageFile = await controller.takePicture();
      if (imageFile != null) {
        Uint8List imageData = await imageFile.readAsBytes();
        Uint8List compressedImageData = _compressImage(imageData);
      _sendImageToServer(compressedImageData);
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }
  Uint8List _compressImage(Uint8List imageData) {
    img.Image image = img.decodeImage(imageData)!;
    img.Image resizedImage = img.copyResize(image, width: 320); 
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 30)); 
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
                ElevatedButton(
                  onPressed: _captureAndSendImage,
                  child: Text('Capture and Send Image'),
                ),
                SizedBox(height: 20),
                Text(serverResponse),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
