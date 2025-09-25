import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_list_app/services/face_recognition_service.dart';

class RegisterFaceScreen extends StatefulWidget {
  const RegisterFaceScreen({super.key});

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final FaceRecognitionService _faceRecognitionService = FaceRecognitionService();
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _faceRecognitionService.loadModel();
  }

  @override
  void dispose() {
    _faceRecognitionService.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerFace() async {
    if (_imageFile == null) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      final faceVector = await _faceRecognitionService.processImageForRecognition(_imageFile!);

      if (faceVector == null) {
        _showSnackBar('Aucun visage n\'a été détecté. Veuillez réessayer.');
        return;
      }

      await _faceRecognitionService.saveRegisteredFace(faceVector);
      _showSnackBar('Visage enregistré avec succès !', isError: false);
      
      // Revenir à l'écran précédent après succès
      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      _showSnackBar('Une erreur est survenue lors de l\'enregistrement.');
      print('Erreur d\'enregistrement: $e');
    } finally {
      if(mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer mon visage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isRegistering 
                ? const Center(child: CircularProgressIndicator()) 
                : (_imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    )),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isRegistering ? null : _pickImage,
              icon: const Icon(Icons.camera_enhance),
              label: const Text('1. Prendre une photo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_imageFile == null || _isRegistering) ? null : _registerFace,
              icon: const Icon(Icons.app_registration),
              label: const Text('2. Enregistrer le visage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_imageFile != null && !_isRegistering) ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
