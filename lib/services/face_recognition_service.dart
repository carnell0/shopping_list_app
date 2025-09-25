import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:hive/hive.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;
  final FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions());

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/mobile_face_net.tflite');
      print('Modèle TFLite chargé avec succès.');
    } catch (e) {
      print('Erreur lors du chargement du modèle TFLite: $e');
    }
  }

  Future<List<double>?> processImageForRecognition(File imageFile) async {
    if (_interpreter == null) {
      print('Interprète TFLite non initialisé.');
      return null;
    }

    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      print('Aucun visage détecté dans l\'image.');
      return null;
    }

    final face = faces.first;
    final originalImage = img.decodeImage(await imageFile.readAsBytes());
    if (originalImage == null) return null;

    final faceRect = face.boundingBox;
    final croppedFace = img.copyCrop(
      originalImage,
      x: faceRect.left.toInt(),
      y: faceRect.top.toInt(),
      width: faceRect.width.toInt(),
      height: faceRect.height.toInt(),
    );

    final resizedFace = img.copyResize(croppedFace, width: 112, height: 112);

    final imageMatrix = List.generate(
      112,
      (y) => List.generate(
        112,
        (x) {
          final pixel = resizedFace.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        },
      ),
    );

    //Exécuter le modèle
    final input = [imageMatrix];
    final output = List.filled(1 * 192, 0.0).reshape([1, 192]);

    _interpreter!.run(input, output);

    return (output[0] as List<double>);
  }

  Future<void> saveRegisteredFace(List<double> faceVector) async {
    final box = await Hive.openBox('userData');
    await box.put('registered_face_vector', faceVector);
    print('Vecteur facial enregistré avec succès dans Hive.');
  }

  Future<List<double>?> getRegisteredFace() async {
    final box = await Hive.openBox('userData');
    final faceVector = box.get('registered_face_vector');
    if (faceVector == null) return null;
    return (faceVector as List).cast<double>();
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}
