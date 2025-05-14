import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddAgencyScreen extends StatefulWidget {
  final String staffId;
  const AddAgencyScreen({Key? key, required this.staffId}) : super(key: key);

  @override
  _AddAgencyScreenState createState() => _AddAgencyScreenState();
}

class _AddAgencyScreenState extends State<AddAgencyScreen> {
  final TextEditingController _agencyNameController = TextEditingController();
  final TextEditingController _agencyAddressController = TextEditingController();
  final TextEditingController _agencyPhoneController = TextEditingController();
  final TextEditingController _agencyEmailController = TextEditingController();

  Future<void> _saveAgency() async {
    final agencyName = _agencyNameController.text;
    final agencyAddress = _agencyAddressController.text;
    final agencyPhone = _agencyPhoneController.text;
    final agencyEmail = _agencyEmailController.text;
    final staffId = widget.staffId;

    if (agencyName.isNotEmpty && agencyAddress.isNotEmpty && agencyPhone.isNotEmpty && agencyEmail.isNotEmpty) {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('agency').add({
        'name': agencyName,
        'address': agencyAddress,
        'phoneNumber': agencyPhone,
        'email': agencyEmail,
        'staffId': staffId,
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
      appBar: AppBar(title: const Text('Thêm đại lý')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _agencyNameController,
              decoration: const InputDecoration(labelText: 'Tên đại lý'),
            ),
            TextField(
              controller: _agencyAddressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ đại lý'),
            ),
            TextField(
              controller: _agencyPhoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại đại lý'),
            ),
            TextField(
              controller: _agencyEmailController,
              decoration: const InputDecoration(labelText: 'Email đại lý'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveAgency,
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}