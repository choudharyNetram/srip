
import 'package:flutter/material.dart';
import 'keyboard.dart';
import 'ws_one_image.dart';
import 'ws_predictions.dart';
import 'keyboard1.dart';
import 'socket_service.dart';
import 'ws_calibration_button.dart';
import 'package:provider/provider.dart';
import 'socket_page.dart' ; 
import 'ws_camera_keyboard1.dart'; 
import 'ws_camera_stream.dart' ; 


class HomePage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to the Home Page!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalibrationButton()),
                );
              },
              child: Text('Calibration Button'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Keyboard()),
                );
              },
              child: Text('Keyboard UI'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SingleImage(title: 'this is title')),
                );
              },
              child: Text('Camera with Single Image'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraExample(title: 'this is title')),
                );
              },
              child: Text('Camera Stream & predictions'),
            ),
            ElevatedButton(
              
              onPressed: () {
                socketService.socket.emit('prediction_ops_start') ; 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraKeyboardApp()),
                );

              },
              child: Text('Camera & Keyboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraKeyboardStream()),
                );
              },
              child: Text('Camera Keyboard Stream '),
            ),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KeyboardNew1()),
                );
              },
              child: Text('New-Keyboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SocketPage()),
                );
              },
              child: Text('Socket IO '),
            ),
          ],
        ),
      ),
    );
  }
}
