import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'socket_service.dart';
import 'ws_calibration_window.dart';

class CalibrationButton extends StatefulWidget {
  const CalibrationButton({Key? key}) : super(key: key);

  @override
  State<CalibrationButton> createState() => _CalibrationButtonState();
}

class _CalibrationButtonState extends State<CalibrationButton> {
  String serverResponse = '';

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.connectToServer();

    socketService.socket.on('calibration_started', (data) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CalibrationWindow()),
      );
      
    });

    socketService.socket.on('error', (error) {
      setState(() {
        serverResponse = 'Server is not connected';
      });
    });

    socketService.socket.on('connect', (_) {
      setState(() {
        serverResponse = 'Connected to server';
      });
    });
  }

  void tellServerForCalibration() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.emit('calibrate_start', {'isStart': 'Yes'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calibration Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Fix your mobile phone at one place, do not move it during calibration',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: tellServerForCalibration,
              child: Text('Start the Calibration'),
            ),
            if (serverResponse.isNotEmpty) Text(serverResponse),
          ],
        ),
      ),
    );
  }
}
