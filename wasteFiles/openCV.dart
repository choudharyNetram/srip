import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' ;
import 'package:flutter/widgets.dart'; 


class MyImageView extends StatefulWidget {
  const MyImageView({required this.imageUrl , super.key}) ; 
  final String imageUrl ; 
  @override 
  State<MyImageView>createState() => _MyImageViewState() ; 

}


class _MyImageViewState extends State<MyImageView>{
  final Map<String, dynamic> creationParams = <String, dynamic>{} ; 

  @override 
  void initState(){
    super.initState() ; 
    creationParams["imageUrl"] = widget.imageUrl ; 
  }

  @override 
  Widget build(BuildContext context){
    return Platform.isAndroid
    ? AndroidView(viewType: 'myImageView', 
    layoutDirection: TextDirection.ltr,
    creationParams: creationParams,
    creationParamsCodec: const StandardMessageCodec(),
    )
    : UiKitView(viewType: 'myImageView', 
    layoutDirection: TextDirection.ltr,
    creationParams: creationParams,
    creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
