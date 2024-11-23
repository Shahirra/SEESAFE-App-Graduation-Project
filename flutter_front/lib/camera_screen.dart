import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Im;
import 'dart:async';
import 'package:flutter_front/box_painter.dart';


class CameraScreen extends StatefulWidget {
  
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String url = 'http://192.168.1.14:5000/api/uploadImage';
  bool isWorking = false;
  int sendCount = 0;
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  CameraImage? imgCamera;
  Uint8List? img_mem;
  Im.Image? imageFromCam;
  Map<String, dynamic>? predicted_bboxes;
  bool prediction_received = false;
  List<String> predictedClasses = [];
  List<List<double>> bboxXYWH = [];

  @override
  void initState()
  {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    
    cameras = await availableCameras();
    if(cameras!.isNotEmpty)
    {
      // setState(() {
        cameraController = CameraController(
          cameras![0], // Assuming the first camera is the one we want to use.
          ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.yuv420, 
           
        );
      // });
    }

    await cameraController!.initialize().then((value) {
      if(!mounted)  return;
      setState(() {
        cameraController?.startImageStream((image) => processImage(image));
      });
    });
  }

  void processImage(CameraImage image) async 
  {
    if (!isWorking) {
      if(sendCount % 20 == 0)
      {
        setState(() => isWorking = true);
        try 
        {
          imageFromCam = await convertYUV420ToImage(image);
          Uint8List jpg_img = Uint8List.fromList(Im.encodeJpg(imageFromCam!));
        
          String base64Img = base64Encode(jpg_img);
          await sendImage(base64Img);
        } catch (e) {
          print('Error processing image: $e');
        }
        setState(() => isWorking = false);

        sendCount = 0;
        predictedClasses.clear();
        bboxXYWH.clear();
      }
      setState(() => prediction_received = false);
      sendCount += 1;
    }
  }

 

  Future<void> sendImage(String base64Img) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        body: base64Img,
        headers: {'Content-type': 'application/json', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) 
      {
        print('Image sent successfully');
        var responseData = jsonDecode(response.body);
        if (responseData != null && responseData.isNotEmpty && responseData is! String) 
        {
          setState(() {
            predicted_bboxes = responseData;
            prediction_received = true;
          });
          for (var i = 0; i < predicted_bboxes!.length; i++) {
            var box = predicted_bboxes!['box$i'];
            if (box != null) {
              predictedClasses.add(box['className']);
              bboxXYWH.add(List<double>.from(box['xywh']));
            }
          }
          print("Predicted objs: $predictedClasses");
          // print("Predicted objs: $bboxXYWH");

        }
      } else {
        print('Failed to send image');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }
  

  Im.Image convertYUV420ToImage(CameraImage cameraImage) {
    final imageWidth = cameraImage.width;
    final imageHeight = cameraImage.height;

    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = Im.Image(imageWidth, imageHeight);

    for (int h = 0; h < imageHeight; h++) {
      int uvh = (h / 2).floor();

      for (int w = 0; w < imageWidth; w++) {
        int uvw = (w / 2).floor();

        final yIndex = (h * yRowStride) + (w * yPixelStride);

        // Y plane should have positive values belonging to [0...255]
        final int y = yBuffer[yIndex];

        // U/V Values are subsampled i.e. each pixel in U/V chanel in a
        // YUV_420 image act as chroma value for 4 neighbouring pixels
        final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

        // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
        // [0, 255] range they are scaled up and centered to 128.
        // Operation below brings U/V values to [-128, 127].
        final int u = uBuffer[uvIndex];
        final int v = vBuffer[uvIndex];

        // Compute RGB values per formula above.
        int r = (y + v * 1436 / 1024 - 179).round();
        int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
        int b = (y + u * 1814 / 1024 - 227).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        final int argbIndex = h * imageWidth + w;

        image.data[argbIndex] = 0xff000000 |
            ((b << 16) & 0xff0000) |
            ((g << 8) & 0xff00) |
            (r & 0xff);
      }
    }

    return image;
  }
  

  // Widget
  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    else{
      return Scaffold(
        body:Center(
              child: Stack(
                children: [
                  // This ensures the CameraPreview fills the parent container
                  Positioned.fill(
                    child: CameraPreview(cameraController!),
                  ),
                  if (predicted_bboxes != null)...[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BoPainter(predicted_bboxes!),
                        ),
                    ),
                  ],
                ],
            ),
          )
      );
    }
    
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
