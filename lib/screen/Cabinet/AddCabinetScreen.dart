import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCabinetScreen extends StatefulWidget {
  final String agencyId;
  const AddCabinetScreen({Key? key, required this.agencyId}) : super(key: key);

  @override
  _AddCabinetScreenState createState() => _AddCabinetScreenState();
}

class _AddCabinetScreenState extends State<AddCabinetScreen> {
  final TextEditingController _cabinetSizeController = TextEditingController();
  final TextEditingController _cabinetDescriptionController = TextEditingController();


  Future<void> _saveCabinet() async {
    final cabinetSize = _cabinetSizeController.text;
    final cabinetDescription = _cabinetDescriptionController.text;
    final agencyId = widget.agencyId;

    if (cabinetSize.isNotEmpty && cabinetDescription.isNotEmpty) {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('cabinet').add({
        'size': cabinetSize,
        'description': cabinetDescription,
        'agencyId': agencyId,
      });

      await docRef.update({'id': docRef.id});

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy điền đầy đủ các thông tin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Tủ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cabinetSizeController,
              decoration: const InputDecoration(labelText: 'Kích thước tủ'),
            ),
            TextField(
              controller: _cabinetDescriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả tủ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveCabinet,
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}