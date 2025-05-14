import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import '../../detection/TFLiteService.dart';

class AddImageScreen extends StatefulWidget {
  final String staffId;
  final String agencyId;
  final String cabinetId;

  const AddImageScreen({
    Key? key,
    required this.staffId,
    required this.agencyId,
    required this.cabinetId,
  }) : super(key: key);

  @override
  _AddImageScreenState createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  final ImagePicker _picker = ImagePicker();
  final TFLiteService _tfliteService = TFLiteService();
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  File? _selectedImage;
  File? _detectedImage;
  String? _imageName;
  bool _isLoading = false;
  bool _isDetection = false;

  @override
  void initState() {
    super.initState();
    _loadTFLiteModel();
  }

  Future<void> _loadTFLiteModel() async {
    try {
      await _tfliteService
          .loadModel('assets/best_saved_model/best_float32.tflite');
      print('Model loaded successfully!');
    } catch (e) {
      _showError('Failed to load model: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageName = basename(_selectedImage!.path);
        });
        await _processImage();
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    setState(() => _isDetection = true);

    try {
      if (!_tfliteService.isModelLoaded) {
        throw Exception('Interpreter is not loaded.');
      }
      // Read and preprocess image
      final imageBytes = await _selectedImage!.readAsBytes();
      final preprocessedImage = _tfliteService.preprocessImage(imageBytes);

      // Run inference synchronously to avoid isolate issues
      final output = _tfliteService.runInference(preprocessedImage);

      // Draw bounding boxes on the image
      final img.Image image = img.decodeImage(imageBytes)!;
      final detections = _tfliteService.processOutput(output, 0.25);
      final detectedImage = _tfliteService.drawBoundingBoxes(image, detections);

      // Save detected image to file
      final detectedImageFile =
          File('${_selectedImage!.parent.path}/detected_$_imageName');
      await detectedImageFile.writeAsBytes(img.encodeJpg(detectedImage));

      if (await detectedImageFile.exists()) {
        setState(() => _detectedImage = detectedImageFile);
        print('Detected image saved at: ${detectedImageFile.path}');
      } else {
        print('Failed to save detected image.');
      }
    } catch (e) {
      _showError('Error processing image: $e');
    } finally {
      setState(() => _isDetection = false);
    }
  }

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      final fileName = basename(image.path);
      final destination = 'files/$fileName';
      final ref = _storage.ref(destination);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      _showError('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> _uploadDetectedImage(File detectedImage) async {
    try {
      final fileName = 'detected_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destination = 'detected/$fileName';
      final ref = _storage.ref(destination);
      await ref.putFile(detectedImage);
      return await ref.getDownloadURL();
    } catch (e) {
      _showError('Error uploading detected image: $e');
      return null;
    }
  }

  Future<void> _saveInfoToFirestore(
      String originalUrl, String detectedUrl) async {
    try {
      DocumentReference docref =
          await FirebaseFirestore.instance.collection('imageOfCabinet').add({
        'originalImageUrl': originalUrl,
        'detectedImageUrl': detectedUrl,
        'staffId': widget.staffId,
        'agencyId': widget.agencyId,
        'cabinetId': widget.cabinetId,
        'date': Timestamp.now(),
      });
      await docref.update({'id': docref.id});
    } catch (e) {
      _showError('Error saving to Firestore: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedImage == null) {
      _showError('Please select an image first.');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final originalUrl = await _uploadImageToStorage(_selectedImage!);
      final detectedUrl = await _uploadDetectedImage(_detectedImage!);
      if (originalUrl == null || detectedUrl == null) {
        _showError('Failed to upload original image.');
        return;
      }
      await _saveInfoToFirestore(originalUrl, detectedUrl);

      _showMessage('Upload successful!');
      Navigator.of(this.context).pop();
    } catch (e) {
      _showError('Error uploading file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    debugPrint(message); // Log error
    ScaffoldMessenger.of(this.context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(this.context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _tfliteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Image')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Select Image'),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              Image.file(_selectedImage!),
              Text(_imageName ?? ''),
              const SizedBox(height: 16),
            ],
            if (_detectedImage != null) ...[
              Image.file(_detectedImage!),
              const SizedBox(height: 16),
            ],
            if (_isDetection) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_camera),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadFile,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
