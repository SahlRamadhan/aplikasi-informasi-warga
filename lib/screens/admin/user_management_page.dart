import 'package:aplikasi_informasi_warga/services/audio_service.dart';
import 'dart:io';
import 'package:aplikasi_informasi_warga/screens/admin/edit_data_page.dart';
import 'package:aplikasi_informasi_warga/screens/admin/tambah_data_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('userRole') ?? 'warga';
    });
  }

  void deleteData(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus Data"),
          content: Text("Apakah Anda yakin ingin menghapus data ini?"),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Hapus"),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docId)
                    .delete()
                    .then((_) {
                      AudioService.playNotificationSound();
                      print("$docId deleted");
                    });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = _userRole == 'admin';

    return Scaffold(
      appBar: AppBar(title: Text("Kelola Pengguna")),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TambahDataPage()),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
                Map<String, dynamic> data =
                    documentSnapshot.data() as Map<String, dynamic>;
                String? profileImagePath = data['profileImagePath'];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: profileImagePath != null
                                ? FileImage(File(profileImagePath))
                                : null,
                            child: profileImagePath == null
                                ? Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.grey[800],
                                  )
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                data["nama"].toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 4.0),
                              Text(data["email"].toString()),
                              Text(data["alamat"].toString()),
                              Text("No: " + data["no"].toString()),
                              Text("Role: " + data["role"].toString()),
                            ],
                          ),
                        ),
                        if (isAdmin)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditDataPage(
                                        docId: documentSnapshot.id,
                                        nama: data["nama"],
                                        email: data["email"],
                                        alamat: data["alamat"],
                                        no: data["no"],
                                        role: data["role"],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  deleteData(documentSnapshot.id);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
