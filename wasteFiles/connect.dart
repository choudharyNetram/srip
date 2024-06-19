import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyAppExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flask Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Example(title: 'Flutter Flask Example'),
    );
  }
}

class Example extends StatefulWidget {
  const Example({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  String serverResponse = 'Server response will be shown here';

  void _sendImageToServer() async {
    // Use your computer's local IP address or ngrok URL
    // 10.240.0.166
    final uri = Uri.parse('http://10.240.0.166:5000/predict'); 
    print("button clicked") ; 
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': 'C:/Users/choud/App_dev/flutter_application_1/image.jpg'}),
    );
    print("https request sent") ; 
    if (response.statusCode == 200) {
      print("got the response") ; 
      final responseBody = jsonDecode(response.body);
      setState(() {
        serverResponse = responseBody.toString();
      });
      print(responseBody);
    } else {
      print('Error: ${response.reasonPhrase}');
      setState(() {
        serverResponse = 'Error: ${response.reasonPhrase}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendImageToServer,
              child: Text('Send Request to Server'),
            ),
            SizedBox(height: 20),
            Text(
              serverResponse,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
