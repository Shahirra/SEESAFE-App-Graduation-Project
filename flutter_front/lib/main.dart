import 'package:flutter/material.dart';
import 'package:flutter_front/home2.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // WidgetsFlutterBinding.ensureInitialized(),
      debugShowCheckedModeBanner: false,
      home: 
      
      HomePage2(),
    );
  }
}