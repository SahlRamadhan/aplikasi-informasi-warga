import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class TambahData extends StatefulWidget {
  @override
  _TambahDataState createState() => _TambahDataState();
}

class _TambahDataState extends State<TambahData> {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController noController = TextEditingController();
  TextEditingController roleController = TextEditingController();

  void addData() {
    FirebaseFirestore.instance
        .collection('users')
        .add({
          'nama': namaController.text,
          'email': emailController.text,
          'alamat': alamatController.text,
          'no': noController.text,
          'role': roleController.text,
        })
        .then((docRef) => print('Document added with ID: ${docRef.id}'))
        .catchError((error) => print("Failed to add document: $error"));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ADD DATA")),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Input Data Mahasiswa",
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: alamatController,
              decoration: InputDecoration(labelText: "Alamat"),
            ),
            TextFormField(
              controller: noController,
              decoration: InputDecoration(labelText: "No"),
            ),
            TextFormField(
              controller: roleController,
              decoration: InputDecoration(labelText: "Role"),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                addData();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
