import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

// Camera related initialization
late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class CameraAndKeyboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combined Camera and Keyboard Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraKeyboardExample(title: 'Combined Example'),
    );
  }
}

class CameraKeyboardExample extends StatefulWidget {
  const CameraKeyboardExample({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CameraKeyboardExample> createState() => _CameraKeyboardExampleState();
}

class _CameraKeyboardExampleState extends State<CameraKeyboardExample> {
  late CameraController controller;
  bool isCameraInitialized = false;
  String serverResponse = '';
  Timer? _timer;

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

      _startAutoCaptureAndSend();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _sendImageToServer(Uint8List imageData) async {
    String base64Image = base64Encode(imageData);
    final uri = Uri.parse('http://10.240.0.166:5000/predict');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          serverResponse = responseBody.toString();
        });
      }
    } else {
      if (mounted) {
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
        _sendImageToServer(imageData);
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  void _startAutoCaptureAndSend() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Only the server response and custom keyboard are displayed
          Text(serverResponse),
          Expanded(child: Keyboards()),
        ],
      ),
    );
  }
}

class Keyboards extends StatefulWidget {
  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboards> {
  final List<List<String>> keyBoardData = [
    ["A-I", "J-R", "S-Z", "a-i", "j-r", "s-z", "1-9", ";:.,?+-*/", "!'@#*%^()"],
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
    ['J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'],
    ['S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0'],
    ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'],
    ['j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r'],
    ['s', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0'],
    ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
    [';', ':', '.', ',', '?', '+', '-', '*', '/'],
    ['!', "'", '@', '#', '*', '%', '^', '(', ')'],
    ['DELETE']
  ];

  String text = 'Starting Text:';
  int view = 0;
  String isDelete = "Delete";

  void handleButtonPress(int index) {
    if (view == 0) {
      setState(() {
        view = index+1;
        isDelete = 'Back';
      });
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0 ; 
        isDelete = 'Delete' ; 
      });
    }
  }

  void handleDeletePress() {
    if (view == 0) {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1);
        });
      }
    } else {
      setState(() {
        view = 0;
        isDelete = 'Delete';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () => handleButtonPress(0),
                      child: Text(keyBoardData[view][0]),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.orange,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () => handleButtonPress(1),
                      child: Text(keyBoardData[view][1]),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () => handleButtonPress(2),
                      child: Text(keyBoardData[view][2]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 12,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.orange,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () => handleButtonPress(3),
                          child: Text(keyBoardData[view][3]),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () => handleButtonPress(5),
                          child: Text(keyBoardData[view][5]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          text = value;
                        });
                      },
                      controller: TextEditingController(text: text),
                      maxLines: 8,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () => handleButtonPress(4),
                          child: Text(keyBoardData[view][4]),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(),
                          onPressed: () => handleButtonPress(6),
                          child: Text(keyBoardData[view][6]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 10,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () => handleButtonPress(7),
                      child: Text(keyBoardData[view][7]),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.orange,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () => handleButtonPress(8),
                      child: Text(keyBoardData[view][8]),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: handleDeletePress,
                      child: Text(isDelete),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
