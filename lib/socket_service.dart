import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService with ChangeNotifier {
  late io.Socket socket;
  String serverResponse = 'No Response';
  List<double>weights = []; 

  SocketService() {
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
      //notifyListeners();
    });

    socket.on('prediction_results', (data) {
      print('Received prediction results: $data');
      serverResponse = data.toString();
      notifyListeners();
    });
    socket.on('predict_weights', (data) {
      serverResponse = data.toString();
      weights = List<double>.from(data['weights']);
      //print('Weights: $weights'); // Print the weights to the console
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

  @override
  void dispose() {
    socket.disconnect(); // Disconnect socket when disposing
    socket.close(); // Close socket when disposing
    super.dispose();
  }
}
