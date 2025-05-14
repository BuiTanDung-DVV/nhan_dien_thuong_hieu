import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nhan_dien_thuong_hieu/screen/Agency/AddAgencyScreen.dart';
import 'package:nhan_dien_thuong_hieu/screen/Agency/AgencyDetailScreen.dart';
import 'package:nhan_dien_thuong_hieu/screen/Agency/AgencyListScreen.dart';
import 'package:nhan_dien_thuong_hieu/screen/Staff/StaffInfoScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý ảnh trong nhận diện thương hiệu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
        debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AgencyListScreen(staffId: 'qNvadhfeIMU2QUuXV4ho',),
    const StaffInfoScreen(staffId: 'qNvadhfeIMU2QUuXV4ho',),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddAgencyScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddAgencyScreen(staffId: 'qNvadhfeIMU2QUuXV4ho',)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý ảnh')),
      body: _selectedIndex == 0
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('agency').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final agencies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: agencies.length,
            itemBuilder: (context, index) {
              final agency = agencies[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    agency['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'ID: ${agency['id']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AgencyDetailScreen(agency: agency, staffId: 'qNvadhfeIMU2QUuXV4ho',),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      )
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Thông tin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Người dùng',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: _navigateToAddAgencyScreen,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}