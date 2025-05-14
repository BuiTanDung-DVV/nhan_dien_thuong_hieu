import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Image/AddImageScreen.dart';
import '../Image/ImageDetailScreen.dart';

class CabinetDetailScreen extends StatelessWidget {
  final DocumentSnapshot cabinet;
  final String staffId;
  final String agencyId;

  const CabinetDetailScreen({Key? key, required this.cabinet, required this.staffId, required this.agencyId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết tủ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${cabinet.id}', style: const TextStyle(fontSize: 18)),
            Text('Kích thước tủ: ${cabinet['size']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Mô tả: ${cabinet['description']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Center(
                child: Text('Danh sách ảnh: '),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('imageOfCabinet')
                    .where('cabinetId', isEqualTo: cabinet.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final images = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final image = images[index];
                      return ListTile(
                        leading: image['originalImageUrl'] != null
                            ? Image.network(image['originalImageUrl'])
                            : null,
                        title: Text('Ảnh ${index + 1}'),
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: ((context)=> ImageDetailScreen(
                            staffId: staffId, agencyId: agencyId,
                                cabinetId: cabinet.id, imageOfCabinet: image,)
                          )));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddImageScreen(
              staffId: staffId,
              agencyId: agencyId,
              cabinetId: cabinet.id,

            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    ),
    );
  }
}