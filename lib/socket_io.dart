import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Socket.IO Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => SocketState(),
        child: MyHomePage(),
      ),
    );
  }
}

class SocketState with ChangeNotifier {
  late io.Socket socket;
  String serverResponse = 'No Response';

  SocketState() {
    connectToServer();
  }

  void connectToServer() {
    socket = io.io('http://10.240.0.166:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
      notifyListeners();
    });

    socket.on('response', (data) {
      serverResponse = data['data'];
      notifyListeners();
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
      notifyListeners();
    });
  }

  void sendMessage() {
    if (socket.connected) {
      socket.emit('message', 'Hello from Flutter!');
    }
  }

  void sendJson() {
    if (socket.connected) {
      socket.emit('json', {'key': 'value'});
    }
  }

  void sendCustomEvent() {
    if (socket.connected) {
      socket.emit('my_event', {'key': 'value'});
    }
  }

  void disconnectSocket() {
    if (socket.connected) {
      socket.emit('disconnect_event', {});
      socket.disconnect(); // Disconnect socket
    }
  }

  void connectSocket() {
    if (!socket.connected) {
      socket.connect(); // Connect socket
    }
  }

 
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketState = Provider.of<SocketState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Socket.IO Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text('Server Response: ${socketState.serverResponse}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: socketState.sendMessage,
              child: Text('Send Message'),
            ),
            ElevatedButton(
              onPressed: socketState.sendJson,
              child: Text('Send JSON'),
            ),
            ElevatedButton(
              onPressed: socketState.sendCustomEvent,
              child: Text('Send Custom Event'),
            ),
            ElevatedButton(
              onPressed: socketState.disconnectSocket,
              child: Text('Disconnect Socket'),
            ),
            ElevatedButton(
              onPressed: socketState.connectSocket,
              child: Text('Connect Socket'),
            ),
          ],
        ),
      ),
    );
  }
}
