import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this to use SystemChrome

class KeyboardNew1 extends StatefulWidget {
  @override
  KeyboardState createState() => KeyboardState();
}

class KeyboardState extends State<KeyboardNew1> {
  final List<List<String>> keyBoardData = [
    ["ABCD\nEFGH", "IJKL\nMNOP", "QRST\nUVWX", "YZab\ncdef", "ghij\nklmn", "opqr\nstuv", "wxyz\n., 0", "delete"],
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
    ['I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'],
    ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X'],
    ['Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f'],
    ['g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'],
    ['o', 'p', 'q', 'r', 's', 't', 'u', 'v'],
    ['w', 'x', 'y', 'z', '.', ',', ' ', '0'],
    ['DELETE']
  ];

  String text = 'Starting Text:';
  int view = 0;
  String isDelete = "Delete";

  @override
  void initState() {
    super.initState();
    // Hide the status bar and make the app full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void handleButtonPress(int index) {
    if (view == 0) {
      setState(() {
        view = index + 1;
        isDelete = 'Back';
      });
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0;
        isDelete = 'Delete';
      });
    }
  }

  void handleDeletePress(int index) {
    if (view == 0) {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1);
        });
      }
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  buildButton(0, Alignment.topLeft),
                  buildButton(1, Alignment.topCenter, flex: 2),
                  buildButton(2, Alignment.topRight),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  buildButton(3, Alignment.centerLeft),
                  Expanded(
                    flex: 2,
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
                  buildButton(4, Alignment.centerRight),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  buildButton(5, Alignment.bottomLeft),
                  buildButton(6, Alignment.bottomCenter, flex: 2),
                  buildButton(7, Alignment.bottomRight, isDeleteButton: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildButton(int index, Alignment alignment, {int flex = 1, bool isDeleteButton = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 149, 243, 33),
            foregroundColor: const Color.fromARGB(255, 54, 89, 244),
            fixedSize: const Size(60, 48),
            padding: EdgeInsets.zero, // Remove default padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
            ),
          ),
          onPressed: () => isDeleteButton ? handleDeletePress(index) : handleButtonPress(index),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(0), // Adjust padding as necessary
              child: Text(
                keyBoardData[view][index],
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';

class KeyboardNew extends StatefulWidget {
  @override
  KeyboardState createState() => KeyboardState();
}

// options: remove capital words (no such great need of it)
// 8  button (no back button) in second level nodes (first page:)
// 7 button + 1 back button 
// first 
class KeyboardState extends State<KeyboardNew> {
  final List<List<String>> keyBoardData = [
    ["ABCD\nEFGH", "IJKL\nMNOP", "QRST\nUVWX", "YZab\ncdef", "ghij\nklmn", "opqr\nstuv", "wxyz\n., 0", "delete"],
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
    ['I', 'J', 'K', 'L', 'M', 'N', 'O', 'P' ],
    ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X'],
    ['Y', 'Z','a', 'b', 'c', 'd', 'e', 'f'],
    ['g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'],
    ['o', 'p', 'q', 'r', 's', 't', 'u', 'v'],
    ['w', 'x', 'y', 'z', '.' , ',', ' ', '0'],
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

  void handleDeletePress(int index) {
    if (view == 0) {
      if (text.isNotEmpty) {
        setState(() {
          text = text.substring(0, text.length - 1);
        });
      }
    } else {
      setState(() {
        text += keyBoardData[view][index];
        view = 0 ; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child:  Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleButtonPress(0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][0],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),


                Expanded(
                  flex: 2,
                    child: Align(
                    alignment: Alignment.topCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleButtonPress(1),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][1],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleButtonPress(2),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][2],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleButtonPress(3),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][3],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
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
                Expanded(
                    child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleButtonPress(4),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][4],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleButtonPress(5),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][5],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                    child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleButtonPress(6),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][6],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 149, 243, 33),
                        foregroundColor: const Color.fromARGB(255, 54, 89, 244),
                        fixedSize: const Size(45, 48),
                        padding: EdgeInsets.zero, // Remove default padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Set border radius to zero for rectangular shape
                        ),
                      ),
                      onPressed: () => handleDeletePress(7),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(0), // Adjust padding as necessary
                          child: Text(
                            keyBoardData[view][7],
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }
}
*/