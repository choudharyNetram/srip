import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'socket_service.dart';
import 'dart:math' ; 

late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class CameraKeyboardStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SocketService(),
      child: MaterialApp(
        title: 'Camera Keyboard App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CameraKeyboardScreen(title: 'Camera Keyboard App'),
      ),
    );
  }
}

class CameraKeyboardScreen extends StatefulWidget {
  const CameraKeyboardScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CameraKeyboardScreen> createState() => _CameraKeyboardScreenState();
}

class _CameraKeyboardScreenState extends State<CameraKeyboardScreen> {
  late CameraController controller;
  bool isCameraInitialized = false;
  String serverConnected = '';
  String text = 'Starting Text:';
  int view = 0;
  String isDelete = "Delete";

  @override
  void initState() {
    super.initState();
    _initializeSocketAndCamera();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.addListener(_onWeightsChanged);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onWeightsChanged() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    List<double> weights = socketService.weights;
    if (weights.isNotEmpty) {
      double maxValue = weights.reduce(max);
      int maxIndex = weights.indexOf(maxValue);
      if (maxValue >= threshold) {
        if (maxIndex == 8) {
          handleDeletePress(maxIndex);
        } else {
          handleButtonPress(maxIndex);
        }
      }
    }
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

      // Start the image stream
      controller.startImageStream(_processCameraImage);
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

  List<Uint8List> frameBuffer = [];
  final double threshold = 0.1;
  final int bufferSize = 5;

  void _processCameraImage(CameraImage image) async {
    final Uint8List yuvBytes = _concatenatePlanes(image.planes);
    frameBuffer.add(yuvBytes);
    //print(image.height) ; 
    // print('between') ;
    // print(image.width) ; 
    if (frameBuffer.length >= bufferSize) {
      /// print('Sending ${frameBuffer.length} images to server');
      _sendImageToServer(frameBuffer);
      frameBuffer.clear();
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void _sendImageToServer(List<Uint8List> imagesData) async {
    try {
      List<String> base64Images = imagesData.map((imgData) => base64Encode(imgData)).toList();
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('predict_ops_stream', {'images': base64Images});
    } catch (e) {
      print('Error sending images to server: $e');
    }
  }

  void handleButtonPress(int index) {
    if (view == 0) {
      setState(() {
        view = index + 1;
        isDelete = 'Back';
      });
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0;
        isDelete = 'Delete';
      });
    }
  }

  void handleDeletePress(int index) {
    if (view == 0) {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1);
        });
      }
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              buildButton(0, Alignment.topLeft),
                              buildButton(1, Alignment.topCenter, flex: 2),
                              buildButton(2, Alignment.topRight),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              buildButton(3, Alignment.centerLeft),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    onChanged: (value) {
                                      // Handle text field change
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
                              buildButton(4, Alignment.centerRight),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              buildButton(5, Alignment.bottomLeft),
                              buildButton(6, Alignment.bottomCenter, flex: 2),
                              buildButton(7, Alignment.bottomRight, isDeleteButton: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildWeightsDisplay(socketService.weights),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildWeightsDisplay(List<double> weights) {
    if (weights.isEmpty) {
      return Text('No weights received yet');
    }

    return Column(
      children: [
        Text(
          'Received Weights:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          weights.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Expanded buildButton(int index, Alignment alignment, {int flex = 1, bool isDeleteButton = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 149, 243, 33),
            foregroundColor: const Color.fromARGB(255, 54, 89, 244),
            fixedSize: const Size(60, 48),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          onPressed: () => isDeleteButton ? handleDeletePress(index) : handleButtonPress(index),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Text(
                keyBoardData[view][index],
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final List<List<String>> keyBoardData = [
    ["ABCD\nEFGH", "IJKL\nMNOP", "QRST\nUVWX", "YZab\ncdef", "ghij\nklmn", "opqr\nstuv", "wxyz\n., 0", "delete"],
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
    ['I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'],
    ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X'],
    ['Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f'],
    ['g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'],
    ['o', 'p', 'q', 'r', 's', 't', 'u', 'v'],
    ['w', 'x', 'y', 'z', '.', ',', '0', ''],
  ];
}

/*import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart'; // For SystemChrome
import 'socket_service.dart'; // Ensure you have the SocketService implemented

late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class CameraKeyboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SocketService(),
      child: MaterialApp(
        title: 'Camera Keyboard App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CameraKeyboardScreen(title: 'Camera Keyboard App'),
      ),
    );
  }
}

class CameraKeyboardScreen extends StatefulWidget {
  const CameraKeyboardScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CameraKeyboardScreen> createState() => _CameraKeyboardScreenState();
}

class _CameraKeyboardScreenState extends State<CameraKeyboardScreen> {
  late CameraController controller;
  bool isCameraInitialized = false;
  String serverConnected = '';
  String text = 'Starting Text:';
  int view = 0;
  String isDelete = "Delete";

  @override
  void initState() {
    super.initState();
    _initializeSocketAndCamera();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.addListener(_onWeightsChanged);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _onWeightsChanged() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    List<double> weights = socketService.weights;
    if (weights.isNotEmpty) {
      double maxValue = weights.reduce(max);
      int maxIndex = weights.indexOf(maxValue);
      if (maxValue >= threshold) {
        if (maxIndex == 8) {
          handleDeletePress(maxIndex);
        } else {
          handleButtonPress(maxIndex);
        }
      }
    }
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

      // Start the image stream
      controller.startImageStream(_processCameraImage);
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

  List<Uint8List> frameBuffer = [];
  final double threshold = 0.6;
  final int bufferSize = 5;
  void _processCameraImage(CameraImage image) {
    // Convert CameraImage to Uint8List
    Uint8List imageData = _convertCameraImageToUint8List(image);
    frameBuffer.add(imageData);
    if (frameBuffer.length >= bufferSize) {
      _sendImageToServer(frameBuffer);
      frameBuffer.clear();
    }
  }

  Uint8List _convertCameraImageToUint8List(CameraImage image) {
    // Convert the CameraImage to a Uint8List (this might need adjustments based on your use case)
    return Uint8List.fromList(image.planes.expand((plane) => plane.bytes).toList());
  }

  void _sendImageToServer(List<Uint8List> imagesData) async {
    try {
      List<String> base64Images = imagesData.map((imgData) => base64Encode(imgData)).toList();
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('predict_ops', {'images': base64Images});
    } catch (e) {
      print('Error encoding image: $e');
    }
  }

  void handleButtonPress(int index) {
    if (view == 0) {
      setState(() {
        view = index + 1;
        isDelete = 'Back';
      });
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0;
        isDelete = 'Delete';
      });
    }
  }

  void handleDeletePress(int index) {
    if (view == 0) {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1);
        });
      }
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              buildButton(0, Alignment.topLeft),
                              buildButton(1, Alignment.topCenter, flex: 2),
                              buildButton(2, Alignment.topRight),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              buildButton(3, Alignment.centerLeft),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    onChanged: (value) {
                                      // Handle text field change
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
                              buildButton(4, Alignment.centerRight),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              buildButton(5, Alignment.bottomLeft),
                              buildButton(6, Alignment.bottomCenter, flex: 2),
                              buildButton(7, Alignment.bottomRight, isDeleteButton: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildWeightsDisplay(socketService.weights),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildWeightsDisplay(List<double> weights) {
    if (weights.isEmpty) {
      return Text('No weights received yet');
    }

    return Column(
      children: [
        Text(
          'Received Weights:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          weights.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Expanded buildButton(int index, Alignment alignment, {int flex = 1, bool isDeleteButton = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 149, 243, 33),
            foregroundColor: const Color.fromARGB(255, 54, 89, 244),
            fixedSize: const Size(60, 48),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          onPressed: () => isDeleteButton ? handleDeletePress(index) : handleButtonPress(index),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Text(
                keyBoardData[view][index],  // Assuming the initial view is 0, you might need to adjust this
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final List<List<String>> keyBoardData = [
    ["ABCD\nEFGH", "IJKL\nMNOP", "QRST\nUVWX", "YZab\ncdef", "ghij\nklmn", "opqr\nstuv", "wxyz\n., 0", "delete"],
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
    ['I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'],
    ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X'],
    ['Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f'],
    ['g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'],
    ['o', 'p', 'q', 'r', 's', 't', 'u', 'v'],
    ['w', 'x', 'y', 'z', '.', ',', ' ', '0'],
    ['DELETE']
  ];
}


*/