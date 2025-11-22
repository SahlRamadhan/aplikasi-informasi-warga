import 'package:aplikasi_informasi_warga/edit.dart';
import 'package:aplikasi_informasi_warga/tambah.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  // Fungsi untuk menghapus data
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
                    .whenComplete(() => print("$docId deleted"));
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
    return Scaffold(
      appBar: AppBar(title: Text('Data Warga')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman TambahData
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahData()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text(documentSnapshot["nama"].toString()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(documentSnapshot["email"].toString()),
                        Text(documentSnapshot["alamat"].toString()),
                        Text("No: " + documentSnapshot["no"].toString()),
                        Text("Role: " + documentSnapshot["role"].toString()),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Tombol Edit
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditData(
                                  docId: documentSnapshot.id,
                                  nama: documentSnapshot["nama"],
                                  email: documentSnapshot["email"],
                                  alamat: documentSnapshot["alamat"],
                                  no: documentSnapshot["no"],
                                  role: documentSnapshot["role"],
                                ),
                              ),
                            );
                          },
                        ),
                        // Tombol Delete
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteData(documentSnapshot.id);
                          },
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
