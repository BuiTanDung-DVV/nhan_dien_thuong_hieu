import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart';

class TFLiteService {
  Interpreter? _interpreter;

  Future<void> loadModel(String modelPath) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  bool get isModelLoaded => _interpreter != null;

  Float32List preprocessImage(Uint8List imageData) {
    if (_interpreter == null) {
      throw Exception('Interpreter is not loaded.');
    }
    Image? image = decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image. Please check the input data.');
    }

    Image resizedImage = copyResize(image, width: 640, height: 640);

    Float32List input = Float32List(1 * 640 * 640 * 3);
    for (int y = 0; y < 640; y++) {
      for (int x = 0; x < 640; x++) {
        int pixel = resizedImage.getPixel(x, y);
        input[(y * 640 + x) * 3 + 0] = (getRed(pixel) / 255.0);
        input[(y * 640 + x) * 3 + 1] = (getGreen(pixel) / 255.0);
        input[(y * 640 + x) * 3 + 2] = (getBlue(pixel) / 255.0);
      }
    }

    return input;
  }

  List<dynamic> runInference(Float32List inputData) {
    if (_interpreter == null) {
      throw Exception('Interpreter is not loaded.');
    }

    // Get input and output shapes
    var inputShape = _interpreter!.getInputTensor(0).shape;
    var outputShape = _interpreter!.getOutputTensor(0).shape;

    // Prepare input buffer
    var input = inputData.reshape(inputShape);
    // Prepare output buffer with the correct shape
    var output = List.generate(
        outputShape[1],
            (_) => List.filled(outputShape[2], 0.0)
    ).reshape(outputShape);

    print('Input shape: $inputShape');
    print('Output shape expected: $outputShape');

    _interpreter!.run(input, output);

    print('Raw output: $output');
    return output;
  }

  List<Map<String, dynamic>> processOutput(List<dynamic> output, double confidenceThreshold) {
    List<Map<String, dynamic>> detections = [];

    // Truy cập mảng output đầu tiên (nếu batch_size = 1)
    for (var detection in output[0]) {
      if (detection is List && detection.length == 6) {
        final double confidence = detection[4]; // Lấy confidence
        if (confidence > confidenceThreshold) {
          detections.add({
            'x': detection[0],
            'y': detection[1],
            'width': detection[2],
            'height': detection[3],
            'confidence': confidence,
            'class': detection[5],
          });
        }
      }
    }
    print('Detections: $detections');
    return detections;
  }


  Image drawBoundingBoxes(Image image, List<Map<String, dynamic>> detections) {
    const int borderThickness = 5; // Độ dày đường viền

    for (var detection in detections) {
      final x = (detection['x'] as double) * image.width;
      final y = (detection['y'] as double) * image.height;
      final w = (detection['width'] as double) * image.width;
      final h = (detection['height'] as double) * image.height;

      // Ensure coordinates are within bounds
      final int xStart = x.clamp(0, image.width - 1).toInt();
      final int yStart = y.clamp(0, image.height - 1).toInt();
      final int xEnd = (x + w).clamp(0, image.width - 1).toInt();
      final int yEnd = (y + h).clamp(0, image.height - 1).toInt();

      // Draw a thick rectangle border
      for (int i = 0; i < borderThickness; i++) {
        drawRect(image, xStart - i, yStart - i, xEnd + i, yEnd + i, getColor(255, 0, 0));
      }

      // Prepare label text (class + confidence)
      final String label =
          '${detection['class']} (${((detection['confidence'] as double) * 100).toStringAsFixed(1)}%)';

      // Draw the label above the bounding box
      final int labelX = xStart;
      final int labelY = yStart - 20; // Slightly above the box
      drawString(
        image,
        arial_14, // Font, use an appropriate font available in the `image` package
        labelX,
        labelY.clamp(0, image.height - 1).toInt(),
        label,
        color: getColor(255, 255, 255), // White color for text
      );
    }

    print('Detections: $detections');
    return image;
  }


  void close() {
    _interpreter?.close();
    print('Interpreter closed.');
  }
}