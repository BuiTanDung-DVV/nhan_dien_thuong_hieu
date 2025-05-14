import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhan_dien_thuong_hieu/screen/Agency/AddAgencyScreen.dart';
import 'package:nhan_dien_thuong_hieu/screen/Agency/AgencyDetailScreen.dart';

class AgencyListScreen extends StatelessWidget {
  final String staffId;

  const AgencyListScreen({Key? key, required this.staffId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đại lý'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddAgencyScreen(staffId: staffId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('agency').where('staffId', isEqualTo: staffId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có đại lý nào được tìm thấy.'));
          }
          final agencies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: agencies.length,
            itemBuilder: (context, index) {
              final agency = agencies[index];
              return ListTile(
                title: Text(agency['name']),
                subtitle: Text('${agency['id']}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AgencyDetailScreen(agency: agency, staffId: staffId,),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}