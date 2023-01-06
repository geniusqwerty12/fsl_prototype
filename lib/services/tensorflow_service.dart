// Tensflow service
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class TensorflowService {
  static final TensorflowService _tensorflowService = TensorflowService.internal();
  factory TensorflowService() {
    return _tensorflowService;
  }

  TensorflowService.internal();

  // handle the classification from the camera feed
  StreamController<List<dynamic>?> _recognitionController = StreamController();
  Stream get recognitionStream => this._recognitionController.stream;

  // flag to determine if the model was loaded
  bool _modelLoaded = false;

  //  Load the model first before using it
  Future<void> loadModel() async {
    try {
      this._recognitionController.add(null);
      await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite", // name of the model
        labels: "assets/labels.txt"
      );
      _modelLoaded = true;
    } catch (e) {
      print("Error loading the model");
      print(e);
    }
  }

  //  Run the model
  //  Input camera object containing the image
  Future<void> runModel(CameraImage image) async {
    // check if the model is loaded first
    if (_modelLoaded) {
      List<dynamic>? recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required property
        imageHeight: image.height,
        imageWidth: image.width,
        numResults: 3, // show the number of results
      );

      //  check if the recognition results is not empty
      if (recognitions != null && recognitions.isNotEmpty) {
        print(recognitions[0].toString());
        if (this._recognitionController.isClosed) {
          // restart the controller
          this._recognitionController = StreamController();
        }
        // notify the listeners
        this._recognitionController.add(recognitions);
      }
    }
  }

  Future<void> stopRecognitions() async {
    if(!this._recognitionController.isClosed) {
      this._recognitionController.add(null);
      this._recognitionController.close();
    }
  }

  // remove the serivce from memory
  void dispose() async {
    this._recognitionController.close();
  }
}
