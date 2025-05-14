import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class UpdateStaffInfoScreen extends StatefulWidget {
  final String staffId;

  const UpdateStaffInfoScreen({Key? key, required this.staffId}) : super(key: key);

  @override
  _UpdateStaffInfoScreenState createState() => _UpdateStaffInfoScreenState();
}

class _UpdateStaffInfoScreenState extends State<UpdateStaffInfoScreen> {
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _email = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    DocumentSnapshot staffData = await FirebaseFirestore.instance.collection('staff').doc(widget.staffId).get();
    if (staffData.exists) {
      var data = staffData.data() as Map<String, dynamic>;
      _phoneNumber.text = data['phoneNumber'];
      _address.text = data['address'];
      _email.text = data['email'];
    }
  }


  Future<void> _updateStaffInfo() async {
    Map<String, dynamic> updatedData = {
      'phoneNumber': _phoneNumber.text,
      'address': _address.text,
      'email': _email.text,
    };
    await FirebaseFirestore.instance.collection('nhanVien').doc(widget.staffId).update(updatedData);
  }

  Future<void> _saveChanges() async {
    _updateStaffInfo();
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      const SnackBar(content: Text('Cập nhật thành công!')),
    );
    Navigator.of(context as BuildContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật thông tin nhân viên')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumber,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _saveChanges,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}