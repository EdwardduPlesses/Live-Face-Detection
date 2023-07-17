import 'dart:developer' as developer;
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
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  List<Direction> directions = [
    Direction('canStart'),
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

  Future<void> updateDirections(Face face) async {
    developer.log('Y: ${face.headEulerAngleY}', level: 1000);
    developer.log('X: ${face.headEulerAngleX}', level: 1200);
    developer.log('Z: ${face.headEulerAngleZ}', level: 1500);

// Define a threshold for how much the face can deviate from looking straight at the camera
    double threshold = 10.0;

// Check if the face is looking at the camera
    if (face.headEulerAngleY!.abs() < threshold &&
        face.headEulerAngleX!.abs() < threshold) {
      setHasLooked(Direction('canStart'));
      checkDirections(face);
    } else {
      // The person is not looking at the camera, don't start the tracing process
      // You might want to display a message to the user asking them to look at the camera
      setHasLooked(Direction('canStart', hasLooked: false));
    }
  }

  void checkDirections(Face face) {
    if (face.headEulerAngleY! < -10) {
      setHasLooked(Direction('right'));
    } else if (face.headEulerAngleY! > 10) {
      setHasLooked(Direction('left'));
    }

    if (face.headEulerAngleX! < -10) {
      setHasLooked(Direction('down'));
    } else if (face.headEulerAngleX! > 10) {
      setHasLooked(Direction('up'));
    }

    if (face.headEulerAngleY! < -10 && face.headEulerAngleX! < -10) {
      setHasLooked(Direction('down-right'));
    } else if (face.headEulerAngleY! > 10 && face.headEulerAngleX! < -10) {
      setHasLooked(Direction('down-left'));
    } else if (face.headEulerAngleY! < -10 && face.headEulerAngleX! > 10) {
      setHasLooked(Direction('up-right'));
    } else if (face.headEulerAngleY! > 10 && face.headEulerAngleX! > 10) {
      setHasLooked(Direction('up-left'));
    }
  }

  void setHasLooked(Direction directionIn, {bool hasLooked = true}) {
    directions
        .firstWhere((direction) => direction.name == directionIn.name)
        .hasLooked = hasLooked;
  }
}
