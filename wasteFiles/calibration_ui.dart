import 'dart:convert';
import 'package:camera/camera.dart' ;
import 'package:flutter/cupertino.dart'; 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http ; 
import 'dart:typed_data';

class CalibrationWindowUI extends StatefulWidget{
  const CalibrationWindowUI({Key? key}) : super(key : key) ; 

  @override 
  State<CalibrationWindowUI> createState() => _CalibrationWindow() ; 
}

class _CalibrationWindow extends State<CalibrationWindowUI> {
  var xAxis = 0 ; 
  var yAxis = 0 ; 

  @override
  void initState() {
    super.initState();
    _autoChangeCoordinates();
  }
  void _nextCoordinates(){
    if(xAxis == 0){
      if(yAxis == 0){
        setState(() {
          xAxis = 0 ; 
          yAxis = 1 ; 
        });
      }
      else if(yAxis == 1){
        setState(() {
          xAxis = 0 ; 
          yAxis = 2 ; 
        });
        
      }
      else{
        setState(() {
          xAxis = 1 ; 
          yAxis = 0 ; 
        });
      }
    }
    else if(xAxis == 1){
      if(yAxis == 0){
        setState(() {
          xAxis = 1 ; 
          yAxis = 1 ; 
        });
       
      }
      else if(yAxis == 1){
        setState(() {
          xAxis = 1 ; 
          yAxis = 2 ; 
        });
       
      }
      else{
        setState(() {
          xAxis = 2 ; 
          yAxis = 0 ; 
        });
       
      }
    }
    else{
      if(yAxis == 0){
        setState(() {
          xAxis = 2 ; 
          yAxis = 1 ; 
        });
        
      }
      else if(yAxis == 1){
        setState(() {
          xAxis = 2 ; 
          yAxis = 2 ; 
        });
        
      }
      else{
        setState(() {
          xAxis = 0 ; 
          yAxis = 0 ; 
        });
        
      }
    }
  }

  void _autoChangeCoordinates(){
    Timer.periodic(Duration(seconds: 1), (timer) { 
      if(!mounted){
        timer.cancel() ; 
        return ; 
      }
      _nextCoordinates() ; 
    }) ; 
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
       body:SafeArea(child: Column(
        children: [
            if (xAxis == 0) ...[
              if(yAxis == 0) ... [
                Expanded(
                  flex: 2,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                  ),
                ),
              ]
              else if (yAxis == 1) ... [
                Expanded(
                  flex: 2,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                  ),
                ),
              ]
              else if(yAxis== 2) ... [
                Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                  ),
                ),
              ]
              
            ] else if(xAxis == 1)...[
              if(yAxis == 0) ... [
                Expanded(
                    child: 
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                    ),
                ),
              ]
              else if (yAxis == 1) ... [
                Expanded(
                    child: 
                        Align(
                          alignment: Alignment.center,
                          child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                    ),
                ),
              ]
              else if(yAxis== 2) ... [
                Expanded(
                    child: 
                        Align(
                          alignment: Alignment.centerRight,
                          child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ]
            ]
            else if(xAxis == 2) ... [
              if(yAxis == 0) ... [
                Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ]
              else if (yAxis == 1) ... [
                Expanded(
                  flex: 2,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                  ),
                ),
              ]
              else if(yAxis== 2) ... [
                Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        onPressed: () {},
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.camera_alt,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ]
            ],
        ],
      ),
      )
    );
  }
}

/*
 Positioned(
  bottom: 10,
  right: 10,
  child: FlutterLogo()
),
Expanded(
  child: Container(
    color: Colors.red,
    child: Align(
      alignment: Alignment.topLeft,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(),
        onPressed () {},
      ),
    ),
  ),
),



Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('The x-axis is $xAxis'),
          Text('The y-axis is $yAxis'),
          MaterialButton(
            onPressed: () {},
            color: Colors.blue,
            textColor: Colors.white,
            padding: EdgeInsets.all(16),
            shape: CircleBorder(),
            child: Icon(
              Icons.camera_alt,
              size: 24,
            ),
           
          ),

         
        ],

      ),
*/