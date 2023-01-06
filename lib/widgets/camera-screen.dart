import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.controller}) : super(key: key);
  final CameraController controller;
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final aspect_ratio = MediaQuery.of(context).size.aspectRatio;
    return Container(
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.transparent]
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height / 4));
        },
        blendMode: BlendMode.darken,
        child: Transform.scale(
          scale: 1.0,
          child: AspectRatio(
            aspectRatio: aspect_ratio,
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Container(
                  width: size,
                  height: size / aspect_ratio,
                  child: Stack(
                    children: [
                      CameraPreview(
                        widget.controller,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
