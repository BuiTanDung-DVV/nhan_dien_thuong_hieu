import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImageDetailScreen extends StatefulWidget {
  final DocumentSnapshot imageOfCabinet;
  final String staffId;
  final String agencyId;
  final String cabinetId;

  const ImageDetailScreen(
      {Key? key,
      required this.staffId,
      required this.agencyId,
      required this.cabinetId,
      required this.imageOfCabinet})
      : super(key: key);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết ảnh')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.imageOfCabinet['originalImageUrl']),
            Image.network(widget.imageOfCabinet['detectedImageUrl']),
            const SizedBox(height: 30),
            Text('ID ảnh: ${widget.imageOfCabinet.id}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ID tủ: ${widget.cabinetId}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ID nhân viên: ${widget.staffId}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('ID đại lý: ${widget.agencyId}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Ngày chụp: ${widget.imageOfCabinet['date'].toDate()}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Đường dẫn ảnh: ${widget.imageOfCabinet['originalImageUrl']}',
                style: const TextStyle(fontSize: 18)),
            Text('Đường dẫn ảnh: ${widget.imageOfCabinet['detectedImageUrl']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
