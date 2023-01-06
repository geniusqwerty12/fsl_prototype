import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fsl_prototype/services/tensorflow_service.dart';

class Recognition extends StatefulWidget {
  const Recognition({Key? key, required this.ready}) : super(key: key);

  // indicate if the animation is finished
  final bool ready;

  @override
  State<Recognition> createState() => _RecognitionState();
}

// track the subscription state during the lifecycle of the custom widget
enum SubscriptionState { Active, Done }

class _RecognitionState extends State<Recognition> {
  // list of recognitions
  List<dynamic> _currentRecognition = [];

  // listens the changes in tensorflow
  StreamSubscription? _streamSubscription;

  // tensorflow service injection
  TensorflowService _tensorflowService = TensorflowService();

  @override
  void initState() {
    _startRecognitionStreaming();
  }

  _startRecognitionStreaming() {
    if(_streamSubscription == null) {
      _streamSubscription = _tensorflowService.recognitionStream
          .listen((recognition) {
            // print(recognition.length);
            if(recognition != null) {
            //  rebuild/refresh the screen with new recognition results
              setState(() {
                _currentRecognition = recognition;
              });
            } else {
              _currentRecognition = [];
            }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF120320),
                  ),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: widget.ready ? [
                      _titleWidget(), // recognition title
                      _contentWidget(), // recognition results
                    ] : [],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

  // Title component
  Widget _titleWidget() {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 20, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recognitions",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _contentWidget() {
    // content settings
    var _width = MediaQuery.of(context).size.width;
    var _padding = 20.0;
    var _labelWidth = 150.0;
    var _labelConfidence = 3.0;
    var _barWidth = _width - _labelWidth - _labelConfidence - _padding * 2.0;

    if(_currentRecognition.length > 0) {
      return Container(
        height: 150,
        child: ListView.builder(
          itemCount: _currentRecognition.length,
          itemBuilder: (context, index) {
            if(_currentRecognition.length > index) {
              return Container(
                height: 40,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: _padding, right: _padding),
                      width: _labelWidth,
                      child: Text(
                        _currentRecognition[index]['label'], // display the label of the result
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Show the confidence percentage as a bar
                    Container(
                      width: _barWidth,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        value: _currentRecognition[index]['confidence'],
                      ),
                    ),
                    Container(
                      width: _labelConfidence,
                      child: Text(
                        (_currentRecognition[index]['confidence'] * 100).toStringAsFixed(0) + '%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      );
    } else {
      return Text('');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
