import 'package:aplikasi_informasi_warga/services/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class KelolaInformasiForm extends StatefulWidget {
  final DocumentSnapshot? document;

  KelolaInformasiForm({this.document});

  @override
  _KelolaInformasiFormState createState() => _KelolaInformasiFormState();
}

class _KelolaInformasiFormState extends State<KelolaInformasiForm> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final _youtubeController = TextEditingController();
  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final data = widget.document!.data() as Map<String, dynamic>;
      _judulController.text = data['judul'] ?? '';
      _isiController.text = data['isi'] ?? '';
      _youtubeController.text = data['youtubeVideoId'] != null ? 'https://www.youtube.com/watch?v=${data['youtubeVideoId']}' : '';
    }
  }

  Future<void> _simpanInformasi() async {
    if (_formKey.currentState!.validate()) {
      final collection = FirebaseFirestore.instance.collection('informasi');
      
      String? youtubeId;
      if (_youtubeController.text.isNotEmpty) {
        youtubeId = YoutubePlayer.convertUrlToId(_youtubeController.text);
      }

      final data = {
        'judul': _judulController.text,
        'isi': _isiController.text,
        'youtubeVideoId': youtubeId ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await widget.document!.reference.update(data);
      } else {
        await collection.add(data);
      }

      AudioService.playNotificationSound();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Informasi" : "Tambah Informasi"),
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
                validator: (value) =>
                    value!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _isiController,
                decoration: InputDecoration(
                  labelText: "Isi Informasi",
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) =>
                    value!.isEmpty ? "Isi tidak boleh kosong" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _youtubeController,
                decoration: InputDecoration(
                  labelText: "Link Video YouTube (Opsional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.video_library),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.startsWith('https://www.youtube.com/') && !value.startsWith('https://youtu.be/')) {
                      return 'Masukkan link YouTube yang valid';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpanInformasi,
                child: Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
