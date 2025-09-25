import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/screens/shopping_list_page.dart';
import 'package:shopping_list_app/services/face_recognition_service.dart';

class FaceUnlockScreen extends StatefulWidget {
  const FaceUnlockScreen({super.key});

  @override
  State<FaceUnlockScreen> createState() => _FaceUnlockScreenState();
}

class _FaceUnlockScreenState extends State<FaceUnlockScreen> {
  final FaceRecognitionService _faceRecognitionService = FaceRecognitionService();
  CameraController? _cameraController;
  Timer? _timer;

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  List<double>? _registeredFaceVector;
  String _message = "Veuillez centrer votre visage";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _faceRecognitionService.loadModel();
    _registeredFaceVector = await _faceRecognitionService.getRegisteredFace();

    if (_registeredFaceVector == null) {
      setState(() {
        _message = "Aucun visage enregistré. Veuillez d'abord vous enregistrer.";
      });
      return;
    }

    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isProcessing) {
        _captureAndProcessImage();
      }
    });
  }

  Future<void> _captureAndProcessImage() async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final File file = File(imageFile.path);

      final currentFaceVector = await _faceRecognitionService.processImageForRecognition(file);
      await file.delete();

      if (currentFaceVector != null) {
        double distance = _euclideanDistance(_registeredFaceVector!, currentFaceVector);
        print("Distance euclidienne: $distance");

        if (distance < 1.0) {
          _onRecognitionSuccess();
        }
      }
    } catch (e) {
      print("Erreur durant la capture et le traitement de l'image: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onRecognitionSuccess() {
    _timer?.cancel();
    _cameraController?.dispose();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ShoppingListPage()),
      );
    }
  }

  double _euclideanDistance(List<double> v1, List<double> v2) {
    double sum = 0.0;
    for (int i = 0; i < v1.length; i++) {
      sum += pow(v1[i] - v2[i], 2);
    }
    return sqrt(sum);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    _faceRecognitionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            Center(
              child: Text(_message, style: const TextStyle(fontSize: 18, color: Colors.white), textAlign: TextAlign.center,),
            ),
          
          Center(
            child: Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.7), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54
              ),
            ),
          ),
        ],
      ),
    );
  }
}
