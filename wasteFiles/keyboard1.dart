import 'package:flutter/material.dart' ;
import 'package:flutter/services.dart';

class Keyboard extends StatefulWidget {
  @override 
  _KeyboardState createState() => _KeyboardState() ;

}

class _KeyboardState extends State<Keyboard>{
  final List<List<String>>keyBoardData = [
    ["A-I", "J-R", "S-Z", "a-i", "j-r", "s-z", "1-9", "!:.,?+-*/", "'@#*%^() "],
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
    ['J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R'],
    ['S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0'],
    ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'],
    ['j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r'],
    ['s', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0'],
    ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
    ['!', ':', '.', ',', '?', '+', '-', '*', '/'],
    ["'", '@', '#', '*', '%', '^', '(', ')', ' '],
    ['DELETE']
  ];

  String isDelete = 'Delete' ; 
  String text = 'Starting text: ' ; 
  int view = 0 ; 
  void handleButtonPress(int index){
    if(view == 0){
      setState(() {
        view = index+1 ; 
        isDelete = 'back' ; 
      });
      
    }
    else {
      setState(() {
        text += keyBoardData[view][index] ; 
        isDelete = 'Delete' ; 
        view = 0 ; 
      });
    }
  }

  void handleDeletePress(){
    if(view == 0){
      if(text.isNotEmpty){
        setState(() {
          text = text.substring(0, text.length -1 ); 
        });
      }
    }
    else{
      setState(() {
        view  = 0 ; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Column(
        children: [
          Expanded(
            flex: 10, 
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        onPressed: () => handleButtonPress(0),
                        child: Text(keyBoardData[view][0]),
                      ),
                      
                      ),
                  )
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.yellow,
                  )
                ),
                Expanded(
                  child: Container(
                    color: Colors.blue,
                  )
                )
                
              ],),
          ),
          Expanded(
            flex: 12,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                  )
                ),
                Expanded(
                  child: Container(
                    color: Colors.blue,
                  )
                ),
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 180, 243, 33),
                  )
                )
            ],
            ),
          ), 
          Expanded(
            flex: 10,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 33, 243, 236),
                  )
                ),
                Expanded(
                  child: Container(
                    color: Colors.yellow,
                  )
                ),

                Expanded(
                  child: Container(
                    color: Color.fromARGB(255, 44, 243, 33),
                  )
                )
              ],
              ),
          )
        ],
       ),

    );
  }
}


