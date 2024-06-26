import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Import this to use SystemChrome


late List<CameraDescription> _cameras;

Future<void> initializeCameras() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
}

class CalibrationWindow extends StatefulWidget {
  const CalibrationWindow({Key? key}) : super(key: key);

  @override
  State<CalibrationWindow> createState() => _CalibrationWindowState();
}

class _CalibrationWindowState extends State<CalibrationWindow> with SingleTickerProviderStateMixin {
  late CameraController controller;
  bool isCameraInitialized = false;
  String serverResponse = '';
  String serverResponseTrain = '' ; 
  bool isCaptureFinished = false ; 
  var xAxis = 0;
  var yAxis = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _autoChangeCoordinates();
    

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 5.0, end: 20.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _controller.dispose();
    controller.dispose();
    super.dispose();
  }
  void tellServerForTraining() async {
    final uri = Uri.parse('http://10.240.0.166:5000/train') ; 
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isStart': 'Yes'}),
    );
    if(response.statusCode == 200){
      if(mounted){
        setState(() {
           serverResponseTrain = response.body.toString() ; 
        });
       
      }
    }
    else{
      if(mounted){
        setState(() {
        serverResponseTrain = response.body ; 
      });
      }
    }
    
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
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _nextCoordinates();
    });
  }

  Future<void> _initializeCamera() async {
    await initializeCameras();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[1], ResolutionPreset.medium);
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        isCameraInitialized = true;
      });
      _startAutoCaptureAndSend();
    }
  }

  void _startAutoCaptureAndSend() {
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if(isCaptureFinished == true){
        timer.cancel() ; 
        return ; 
      }
      _captureAndSendFrames();
    });
  }

  
 
  List<Uint8List> frameBuffer = [];
  final int bufferSize = 10;
  List<int>buttonNumbers = [] ; 

  void _captureAndSendFrames() async {
    try {
      XFile imageFile = await controller.takePicture();
      if (imageFile != null) {
        Uint8List imageData = await imageFile.readAsBytes();
        frameBuffer.add(imageData);
        buttonNumbers.add(3 * xAxis + yAxis ); 
        if (frameBuffer.length >= bufferSize) {
          _sendFramesToServer(frameBuffer,buttonNumbers );
          frameBuffer.clear();
          buttonNumbers.clear() ; 
        }
      }
    } catch (e) {
      print('Error in capturing frames: $e');
    }
  }

  void _sendFramesToServer(List<Uint8List> images, List<int>buttonNumbers) async {
    List<String> base64Images = images.map((imgData) => base64Encode(imgData)).toList();
    final uri = Uri.parse('http://10.240.0.166:5000/calibrate');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'images': base64Images, 'buttonNos': buttonNumbers }),
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

  /*
  void _sendFrameToServer(Uint8List imageData) async {
    String base64Image = base64Encode(imageData);
    final uri = Uri.parse('http://10.240.0.166:5000/calibrate');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image, 'buttonNo': 3 * xAxis + yAxis }),
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
  }*/

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
              Text(serverResponseTrain) 
            ]
          ]
          
          ],
         

        ),
      ),
    );
  }
}
