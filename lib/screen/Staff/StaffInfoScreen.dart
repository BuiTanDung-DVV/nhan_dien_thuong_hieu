import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UpdateStaffInfoScreen.dart';

class StaffInfoScreen extends StatelessWidget {
  final String staffId;

  const StaffInfoScreen({Key? key, required this.staffId}) : super(key: key);

  Future<DocumentSnapshot> _getStaffData() async {
    return await FirebaseFirestore.instance.collection('staff').doc(staffId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin nhân viên')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getStaffData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải dữ liệu'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Không tìm thấy dữ liệu'));
          }

          var staffData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${staffId}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Họ và tên: ${staffData['staffName']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Số điện thoại: ${staffData['phoneNumber']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Địa Chỉ: ${staffData['address']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Email: ${staffData['email']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
               Text('Số lượng cửa hàng quản lý: ${staffData['numberOfStoresManaged']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UpdateStaffInfoScreen(staffId: staffId),
                      ),
                    );
                  },
                  child: Center( child: const Text('Thay đổi thông tin')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}