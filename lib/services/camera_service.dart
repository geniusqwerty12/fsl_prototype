import 'package:camera/camera.dart';

import 'package:fsl_prototype/services/tensorflow_service.dart';

class CameraService {
  // Camera Service
  static final CameraService _cameraService = CameraService.internal();
  factory CameraService() {
    return _cameraService;
  }

  CameraService.internal();

  //  Load Tensorflow
  TensorflowService _tensorflowService = TensorflowService();

  // Initialize the camera controller
  late CameraController _cameraController;
  CameraController get cameraController => _cameraController;

  // check if camera is available
  bool available = true;

  // start the camera service
  Future startService(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription, // list of cameras available on the device
      ResolutionPreset.high, // set the camera to high
    );

    return _cameraController.initialize();
  }

  // Remove service from memory
  void dispose() {
    _cameraController.dispose();
  }

  // start the camera stream
  Future<void> startStreaming() async {
    _cameraController.startImageStream((image) async {
      try {
        if(available) {
          available = false;
          // run the classification model, input -> image from camera
          await _tensorflowService.runModel(image);
          await Future.delayed(Duration(seconds: 1)); // add a delay on every classification
          available = true;
        }
      } catch (e) {
        print("Error running the model with current frame");
        print(e);
      }
    });
  }

  //  stop the camera stream
  Future stopImageStream() async {
    await this._cameraController.stopImageStream();
  }
}