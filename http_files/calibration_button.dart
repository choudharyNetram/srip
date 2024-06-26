import 'package:flutter/material.dart';
import 'calibration_window.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class CalibrationButton extends StatefulWidget{
  const CalibrationButton({Key? key }) : super(key: key) ; 

  @override 
  State<CalibrationButton> createState() => _CalibrationButton() ; 
}

class _CalibrationButton extends State<CalibrationButton>{
  String serverResponse = '' ; 
  
  void tellServerForCalibration() async {
    final uri = Uri.parse('http://10.240.0.166:5000/calibrateStart') ; 
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isStart': 'Yes'}),
    );
    if(response.statusCode == 200){
      if(mounted){
        setState(() {
           serverResponse = '' ; 
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalibrationWindow()),
        );
        
       
      }
    }
    else{
      print("server is not connected") ; 
      if(mounted){
        setState(() {
        serverResponse = response.body ; 
      });
      }
      

    }
    
  }

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Fix your mobile phone at one palace, do not move it during calibration' ) , 
            SizedBox(height: 20,) , 
            ElevatedButton(
              onPressed: () {
                tellServerForCalibration() ; 
              },
              child: Text('Start the Calibration'),
            ),
            if(serverResponse != '') ... [
              Text('Server is not connected') , 
            ]
          ],)
         ,) 

      

    ) ; 
  }
}