import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:flutter/services.dart'; // Import this to use SystemChrome
import 'socket_service.dart';
import 'package:provider/provider.dart';



late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class CalibrationWindowStream extends StatefulWidget {
  const CalibrationWindowStream({Key? key}) : super(key: key);

  @override
  State<CalibrationWindowStream> createState() => _CalibrationWindowState();
}

class _CalibrationWindowState extends State<CalibrationWindowStream> with SingleTickerProviderStateMixin {
  late CameraController controller;
  bool isCameraInitialized = false;
  String serverResponse = '';
  String serverResponseTrain = '';
  String serverConnected = '' ; 
  bool isCaptureFinished = false;
  var xAxis = 0;
  var yAxis = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    _autoChangeCoordinates();
    _initializeSocketAndCamera();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 5.0, end: 20.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
    socketService.socket.on('calibration_results', (data) {
    setState(() {
      serverResponse = data.toString();
    });
  });
/// training_results
    socketService.socket.on('training_results', (data) {
      setState(() {
        serverResponseTrain = data.toString();
      });
    });

    socketService.socket.on('error', (error) {
      print('Error connecting to server: $error');
    });

    // Assign the socket from SocketService to the local socket variable
    socket = socketService.socket;
  }

  @override
  void dispose() {
    _controller.dispose();
    controller.dispose();
    super.dispose();
  }

  List<Uint8List> frameBuffer = [];
  final int bufferSize = 5;
  List<int> buttonNumbers = [];
  int _lastProcessedTimestamp = 0;
  final int _imageProcessingInterval = 500; // Interval in milliseconds


  void _processCameraImage(CameraImage image) async {
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (currentTimestamp - _lastProcessedTimestamp < _imageProcessingInterval) {
      return;
    }
    _lastProcessedTimestamp = currentTimestamp;
    Uint8List yuvBytes = _concatenatePlanes(image.planes);
    final int halfSize = yuvBytes.length ~/ 2; 
    yuvBytes = yuvBytes.sublist(0, halfSize); 
    frameBuffer.add(yuvBytes);
    buttonNumbers.add(3 * xAxis + yAxis ); 
    // print('Image Height: ${image.height}');
    // print('Image Width: ${image.width}');
    // print('Image Format: ${image.format.group}');
    // print('Number of Planes: ${image.planes.length}');
    if (frameBuffer.length >= bufferSize) {
      /// print('Sending ${frameBuffer.length} images to server');
      _sendImageToServer(frameBuffer, buttonNumbers);
      frameBuffer.clear();
      buttonNumbers.clear() ; 
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void _sendImageToServer(List<Uint8List> imagesData, List<int> buttonNumbers) async {
    try {
      List<String> base64Images = imagesData.map((imgData) => base64Encode(imgData)).toList();
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('calibrate_stream', {'images': base64Images, 'buttonNos': buttonNumbers});
    } catch (e) {
      print('Error sending images to server: $e');
    }
  }
  

  void tellServerForTraining() {
    socket.emit('train', {'isStart': 'Yes'});
  }

  void _nextCoordinates() {
    if (xAxis == 0) {
      if (yAxis == 0) {
        setState(() {
          xAxis = 0;
          yAxis = 1;
        });
      } else if (yAxis == 1) {
        setState(() {
          xAxis = 0;
          yAxis = 2;
        });
      } else {
        setState(() {
          xAxis = 1;
          yAxis = 0;
        });
      }
    } else if (xAxis == 1) {
      if (yAxis == 0) {
        setState(() {
          xAxis = 1;
          yAxis = 1;
        });
      } else if (yAxis == 1) {
        setState(() {
          xAxis = 1;
          yAxis = 2;
        });
      } else {
        setState(() {
          xAxis = 2;
          yAxis = 0;
        });
      }
    } else {
      if (yAxis == 0) {
        setState(() {
          xAxis = 2;
          yAxis = 1;
        });
      } else if (yAxis == 1) {
        setState(() {
          xAxis = 2;
          yAxis = 2;
        });
      } else {
        setState(() {
          xAxis = 0;
          yAxis = 0;
          isCaptureFinished = true ; 
        });
      }
    }
  }

  void _autoChangeCoordinates() {
     Timer.periodic(Duration(seconds: 8), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _nextCoordinates();
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (isCaptureFinished == false) ... [

            if (xAxis == 0) ...[
              if (yAxis == 0) ...[
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 5,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Container(
                              width: _animation.value,
                              height: _animation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ] else if (yAxis == 1) ...[
               Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double containerWidth = 50;
                    double leftPosition = (screenWidth - containerWidth) / 2;

                    return Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: leftPosition,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Center(
                              child: Container(
                                width: _animation.value,
                                height: _animation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              ] else if (yAxis == 2) ...[
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 5,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Container(
                              width: _animation.value,
                              height: _animation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else if (xAxis == 1) ...[
              if (yAxis == 0) ...[
                Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenHeight = constraints.maxHeight;
                    double containerWidth = 50;
                    double leftPosition = (screenHeight - containerWidth) / 2;

                    return Stack(
                      children: [
                        Positioned(
                          top: leftPosition ,
                          left: 5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Center(
                              child: Container(
                                width: _animation.value,
                                height: _animation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ] else if (yAxis == 1) ...[
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Center(
                        child: Container(
                          width: _animation.value,
                          height: _animation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else if (yAxis == 2) ...[
                Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenHeight = constraints.maxHeight;
                    double containerWidth = 50;
                    double leftPosition = (screenHeight - containerWidth) / 2;

                    return Stack(
                      children: [
                        Positioned(
                          top: leftPosition ,
                          right: 5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Center(
                              child: Container(
                                width: _animation.value,
                                height: _animation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ],
            ] else if (xAxis == 2) ...[
              if (yAxis == 0) ...[
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 5,
                        bottom: 0,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Container(
                              width: _animation.value,
                              height: _animation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (yAxis == 1) ...[
                Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double containerWidth = 50;
                    double leftPosition = (screenWidth - containerWidth) / 2;

                    return Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: leftPosition,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Center(
                              child: Container(
                                width: _animation.value,
                                height: _animation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              ] else if (yAxis == 2) ...[
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Container(
                              width: _animation.value,
                              height: _animation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ]
           else if (isCaptureFinished ) ... [
               ElevatedButton(
              onPressed: () {
                tellServerForTraining() ; 
              },
              child: Text('Start the training'),
            ),
            if(serverResponseTrain != '')...[
              Text(serverResponseTrain) ,
              Text(serverResponse) 
            ]
    
            else if (serverResponse != '') ... [
              Text(serverResponse) 
            ]
          ]
          
          ],
         
        ),
      ),
    );
  }
}
