import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fsl_prototype/services/camera_service.dart';
import 'package:fsl_prototype/services/tensorflow_service.dart';
import 'package:fsl_prototype/widgets/recognition.dart';
import 'package:fsl_prototype/widgets/camera-header.dart';
import 'package:fsl_prototype/widgets/camera-screen.dart';

class Home extends StatefulWidget {
  // Initialize variables
  final CameraDescription camera;

  const Home({
    Key? key,
    required this.camera,
  }) : super(key:key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin, WidgetsBindingObserver {
  //  Inject the services
  TensorflowService _tensorflowService = TensorflowService();
  CameraService _cameraService = CameraService();
  
  // Future for camera initialization
  Future<void>? _initializeControllerFuture;
  AppLifecycleState? _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //  start the camera, then load the tensorflow model
    startUp();
  }
  
  Future startUp() async {
    if(!mounted) {
      return;
    }
    
    if(_initializeControllerFuture == null) {
      _initializeControllerFuture = _cameraService.startService(widget.camera)
          .then((value) async {
            // print('Controller future done...');
            await _tensorflowService.loadModel();
            startRecognitions();
      });
    } else {
      await _tensorflowService.loadModel();
      startRecognitions();
    }
  }

  // start the classification
  startRecognitions() async {
    try {
      _cameraService.startStreaming();
    } catch (e) {
      print('Error streaming camera image');
      print(e);
    }
  }

  stopRecognition() async {
    // close the streams
    await _cameraService.stopImageStream();
    await _tensorflowService.stopRecognitions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done) {
          //  Display the preview
            return Stack(
              children: [
                //  Camera preview
                CameraScreen(
                  controller: _cameraService.cameraController,
                ),
                //  Camera header with the icon
                CameraHeader(),
                //  Recognition results
                Recognition(ready: true),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if(_appLifecycleState == AppLifecycleState.resumed) {
      // start the camera then reload the tensorflow model
      startUp();
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _tensorflowService.dispose();
    _initializeControllerFuture = null;
    super.dispose();
  }
}