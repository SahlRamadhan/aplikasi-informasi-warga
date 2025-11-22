import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KelolaMediaForm extends StatefulWidget {
  final String collectionName; // 'audio_komunitas' or 'video_komunitas'
  final DocumentSnapshot? document;

  KelolaMediaForm({required this.collectionName, this.document});

  @override
  _KelolaMediaFormState createState() => _KelolaMediaFormState();
}

class _KelolaMediaFormState extends State<KelolaMediaForm> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _assetPathController = TextEditingController();
  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final data = widget.document!.data() as Map<String, dynamic>;
      _judulController.text = data['judul'] ?? '';
      _deskripsiController.text = data['deskripsi'] ?? '';
      _assetPathController.text = data['assetPath'] ?? '';
    }
  }

  Future<void> _simpanMetadata() async {
    if (_formKey.currentState!.validate()) {
      final collection = FirebaseFirestore.instance.collection(widget.collectionName);
      final data = {
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'assetPath': _assetPathController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await widget.document!.reference.update(data);
      } else {
        await collection.add(data);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.collectionName.contains('audio') ? 'Audio' : 'Video';
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Metadata $type" : "Tambah Metadata $type"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: "Judul",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: "Deskripsi",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Deskripsi tidak boleh kosong" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _assetPathController,
                decoration: InputDecoration(
                  labelText: "Jalur Asset (e.g., assets/audio/contoh.mp3)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jalur asset tidak boleh kosong';
                  }
                  if (!value.startsWith('assets/')) {
                    return "Harus diawali dengan 'assets/'";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpanMetadata,
                child: Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
