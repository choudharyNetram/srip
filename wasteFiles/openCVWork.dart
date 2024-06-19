/*import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}


class OpenCVtask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face and Eye Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FaceDetectionPage(),
    );
  }
}

class FaceDetectionPage extends StatefulWidget {
  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late CameraController _controller;
  String _detectionResult = '';

  @override
  void initState() {
    super.initState();
    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    }
  Future<img.Image> processImage(CameraImage image) async {
    // ... (image processing logic)
    
    // Convert to grayscale (assuming grayscale is needed)
    final grayscaleImage = img.grayscale(flippedImage);

    // Create image data from bytes (replace with actual byte data)
    final imageBytes = Uint8List.fromList(img.encodeJpg(grayscaleImage));
    var imgData = img.Image.fromBytes(grayscaleImage.width, grayscaleImage.height, imageBytes);

    return imgData;
  }

  Future<void> detectFacesAndEyes(CameraImage image) async {
    final grayscaleImage = await processImage(image);

    final inputImage = InputImage.fromBytes(
      bytes: imageBytes, // Replace with actual byte data
      // inputImageData argument removed
    );

    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
      ),
    );

    final faces = await faceDetector.processImage(inputImage);

    for (Face face in faces) {
      final leftEye = face.getLandmark(FaceLandmarkType.leftEye); // Updated method
      final rightEye = face.getLandmark(FaceLandmarkType.rightEye); // Updated method

      if (leftEye != null && rightEye != null) {
        print('Left eye position: ${leftEye.position}');
        print('Right eye position: ${rightEye.position}');
      }
    }

    faceDetector.close();

    setState(() {
      _detectionResult = 'Detection completed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face and Eye Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _controller.value.isInitialized
                ? CameraPreview(_controller)
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_controller.value.isInitialized) {
                  _controller.startImageStream((image) async {
                    await detectFacesAndEyes(image);
                  });
                }
              },
              child: Text('Detect Faces and Eyes'),
            ),
            Text(_detectionResult),
          ],
        ),
      ),
    );
  }
}
*/