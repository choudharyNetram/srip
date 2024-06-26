import 'package:flutter/material.dart';

class Keyboard extends StatefulWidget {
  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  final List<List<String>> keyBoardData = [
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

  String text = 'Starting Text:';
  int view = 0;
  String isDelete = "Delete";

  void handleButtonPress(int index) {
    if (view == 0) {
      setState(() {
        view = index+1;
        isDelete = 'Back';
      });
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0 ; 
        isDelete = 'Delete' ; 
      });
    }
  }

  void handleDeletePress() {
    if (view == 0) {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1);
        });
      }
    } else {
      setState(() {
        view = 0;
        isDelete = 'Delete';
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
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.orange,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        onPressed: () => handleButtonPress(1),
                        child: Text(keyBoardData[view][1]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        onPressed: () => handleButtonPress(2),
                        child: Text(keyBoardData[view][2]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 12,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.orange,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(),
                            onPressed: () => handleButtonPress(3),
                            child: Text(keyBoardData[view][3]),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(),
                            onPressed: () => handleButtonPress(5),
                            child: Text(keyBoardData[view][5]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            text = value;
                          });
                        },
                        controller: TextEditingController(text: text),
                        maxLines: 8,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(),
                            onPressed: () => handleButtonPress(4),
                            child: Text(keyBoardData[view][4]),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(),
                            onPressed: () => handleButtonPress(6),
                            child: Text(keyBoardData[view][6]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        onPressed: () => handleButtonPress(7),
                        child: Text(keyBoardData[view][7]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.orange,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        onPressed: () => handleButtonPress(8),
                        child: Text(keyBoardData[view][8]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        onPressed: handleDeletePress,
                        child: Text(isDelete),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
