import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'socket_service.dart';

class SocketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Socket IO Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('Server Response: ${socketService.serverResponse}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: socketService.sendMessage,
              child: Text('Send Message'),
            ),
            ElevatedButton(
              onPressed: socketService.sendJson,
              child: Text('Send JSON'),
            ),
            ElevatedButton(
              onPressed: socketService.sendCustomEvent,
              child: Text('Send Custom Event'),
            ),
            ElevatedButton(
              onPressed: socketService.disconnectSocket,
              child: Text('Disconnect Socket'),
            ),
            ElevatedButton(
              onPressed: socketService.connectSocket,
              child: Text('Connect Socket'),
            ),
          ],
        ),
      ),
    );
  }
}
