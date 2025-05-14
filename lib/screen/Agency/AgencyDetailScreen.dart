import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Cabinet/AddCabinetScreen.dart';
import '../Cabinet/CabinetDetailScreen.dart';

class AgencyDetailScreen extends StatelessWidget {
  final DocumentSnapshot agency;
  final String staffId;

  const AgencyDetailScreen(
      {Key? key, required this.agency, required this.staffId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đại lý')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${agency.id}', style: const TextStyle(fontSize: 18)),
            Text('Tên đại lý: ${agency['name']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Địa chỉ: ${agency['address']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Số điện thoại: ${agency['phoneNumber']}',
                style: const TextStyle(fontSize: 18)),
            Text('Email: ${agency['email']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Danh sách tủ:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cabinet')
                    .where('agencyId', isEqualTo: agency.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final cabinets = snapshot.data!.docs;
                  return DataTable(
                    columns: const [
                      DataColumn(label: Expanded(child: Text('Chi tiết'))),
                      DataColumn(label: Text('STT')),
                      DataColumn(label: Text('Id tủ')),
                    ],
                    rows: cabinets.map((cabinet) {
                      return DataRow(
                        cells: [
                          DataCell(
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CabinetDetailScreen(
                                        cabinet: cabinet,
                                        staffId: staffId,
                                        agencyId: agency.id,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Chi tiết',
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                ),
                              ),
                          ),
                          DataCell(
                            Text(
                                (cabinets.indexOf(cabinet) + 1).toString(),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              alignment: Alignment.centerLeft,
                              width: 110,
                              child: Text(
                                cabinet.id,
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddCabinetScreen(agencyId: agency.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}