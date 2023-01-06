import 'package:flutter/material.dart';
import 'package:fsl_prototype/widgets/home.dart';
import 'package:camera/camera.dart';

Future<void> main() async {
  //  Ensure that plugin services are initialized so that the availableCameras can be called before runApp
  WidgetsFlutterBinding.ensureInitialized();

  //  Obtain a list of available cameras
  final cameras = await availableCameras(); // from the camera package

  // Get the first camera from the list of cameras
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFF00FF),
      ),
      theme: ThemeData.dark(),
      home: Home(
        camera: firstCamera,
      ),
    )
  );
}
