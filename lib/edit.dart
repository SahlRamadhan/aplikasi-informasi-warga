import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class EditData extends StatefulWidget {
  final String docId;
  final String nama;
  final String email;
  final String alamat;
  final int no;
  final String role;

  EditData({
    required this.docId,
    required this.nama,
    required this.email,
    required this.alamat,
    required this.no,
    required this.role,
  });

  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  late TextEditingController namaController;
  late TextEditingController emailController;
  late TextEditingController alamatController;
  late TextEditingController noController;
  late TextEditingController roleController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    emailController = TextEditingController(text: widget.email);
    alamatController = TextEditingController(text: widget.alamat);
    noController = TextEditingController(text: widget.no.toString());
    roleController = TextEditingController(text: widget.role);
  }

  void updateData() {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.docId);

    Map<String, dynamic> wrg = {
      "nama": namaController.text,
      "email": emailController.text,
      "alamat": alamatController.text,
      "no": int.parse(noController.text),
      "role": roleController.text,
    };

    documentReference
        .update(wrg)
        .whenComplete(() => print('${namaController.text} updated'));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Home()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EDIT DATA")),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Text(
              "Edit Data Mahasiswa",
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
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: roleController,
              decoration: InputDecoration(labelText: "Role"),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                updateData();
              },
              child: Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
