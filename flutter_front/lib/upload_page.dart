import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'dart:convert';
import 'dart:io';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  File? _file;
  @override
  void initState()
  {
    super.initState();
    uploadImage();
  }

  Future uploadImage() async
  {
    var pickedImg = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _file = File(pickedImg!.path);
    });
  }

  void describeImage(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(

        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children:[
                  _file == null 
                  ? Text('Image can not be uploaded')
                  : Image.file(_file!)
                ]
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed:() => describeImage(), child: Text('Detect')),
                ],
              ),
            ],
          ),
          
        ),
      ),
    );
  }
}