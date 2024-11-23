import 'package:flutter/material.dart';
import 'package:flutter_front/camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_front/upload_page.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});
  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> 
{
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  CameraImage? imgCamera;

  @override
  void initState()
  {
    super.initState();
    // initCamera();
  }

  void initCamera() async
  {
    cameras = await availableCameras();
    if(cameras!.isNotEmpty)
    {
      cameraController = CameraController(cameras![0], ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
        ? ImageFormatGroup.bgra8888
        : ImageFormatGroup.yuv420
      );
    }
  }


  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Detection Demo home',
      theme: ThemeData( scaffoldBackgroundColor: Colors.white,),
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            // Icon that triggers the action
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined), // Use Icons.camera_alt_outlined for camera icon
              iconSize: 80.0,
              onPressed: () async {
                
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen()),
                );
                // CameraPreview(cameraController!); // Display camera preview
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed:() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadPage()),
                    );
                  }, child: Text('upload')
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}