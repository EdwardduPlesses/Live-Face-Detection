import 'dart:math';

import 'package:app/camera_view.dart';
import 'package:app/direction.dart';
import 'package:app/util/face_detector_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPage extends StatefulWidget {
  const FaceDetectorPage({Key? key}) : super(key: key);

  @override
  State<FaceDetectorPage> createState() => _FaceDetectorPageState();
}

class _FaceDetectorPageState extends State<FaceDetectorPage> {
  //create face detector object
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  List<Direction> directions = [
    Direction('left'),
    Direction('right'),
    Direction('up'),
    Direction('down'),
    Direction('up-right'),
    Direction('up-left'),
    Direction('down-right'),
    Direction('down-left'),
  ];
  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      //customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      initialDirection: CameraLensDirection.front,
      directions: directions,
    );
  }

  Future<void> processImage(final InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = "";
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
      for (final face in faces) {
        updateDirections(face);
        // String text = '';
        // if (face.headEulerAngleY! < -10) {
        //   text += 'Face is turned to the right\n\n';
        // } else if (face.headEulerAngleY! > 10) {
        //   text += 'Face is turned to the left\n\n';
        // }

        // if (face.headEulerAngleX! < -10) {
        //   text += 'Face is looking down\n\n';
        // } else if (face.headEulerAngleX! > 10) {
        //   text += 'Face is looking up\n\n';
        // }
        // _text = text;
      }
    } else {
      String text = 'face found ${faces.length}\n\n';

      _text = text;
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void updateDirections(Face face) {
    if (face.headEulerAngleY! < -10) {
      directions
          .firstWhere((direction) => direction.name == 'right')
          .hasLooked = true;
    } else if (face.headEulerAngleY! > 10) {
      directions.firstWhere((direction) => direction.name == 'left').hasLooked =
          true;
    }

    if (face.headEulerAngleX! < -10) {
      directions.firstWhere((direction) => direction.name == 'down').hasLooked =
          true;
    } else if (face.headEulerAngleX! > 10) {
      directions.firstWhere((direction) => direction.name == 'up').hasLooked =
          true;
    }

    if (face.headEulerAngleY! < -10 && face.headEulerAngleX! < -10) {
      directions
          .firstWhere((direction) => direction.name == 'down-right')
          .hasLooked = true;
    } else if (face.headEulerAngleY! > 10 && face.headEulerAngleX! < -10) {
      directions
          .firstWhere((direction) => direction.name == 'down-left')
          .hasLooked = true;
    } else if (face.headEulerAngleY! < -10 && face.headEulerAngleX! > 10) {
      directions
          .firstWhere((direction) => direction.name == 'up-right')
          .hasLooked = true;
    } else if (face.headEulerAngleY! > 10 && face.headEulerAngleX! > 10) {
      directions
          .firstWhere((direction) => direction.name == 'up-left')
          .hasLooked = true;
    }
  }
}
