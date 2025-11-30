import 'package:aplikasi_informasi_warga/services/audio_service.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class PengaduanFormPage extends StatefulWidget {
  @override
  _PengaduanFormPageState createState() => _PengaduanFormPageState();
}

class _PengaduanFormPageState extends State<PengaduanFormPage> {
  final TextEditingController _pengaduanController = TextEditingController();
  late Future<String?> _userEmailFuture;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _userEmailFuture = _loadUserEmail();
  }

  Future<String?> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  await _pickImage(ImageSource.gallery);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () async {
                  await _pickImage(ImageSource.camera);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _kirimPengaduan() async {
    final userEmail = await _userEmailFuture;
    if (_pengaduanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi pengaduan tidak boleh kosong.')),
      );
      return;
    }

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda harus login untuk mengirim pengaduan.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    String? imagePath;
    if (_image != null) {
      // Get the application's documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      // Create a unique file name from the temporary file's name
      final String fileName = p.basename(_image!.path);
      final String permanentPath = p.join(appDocDir.path, fileName);

      // Copy the file from the temporary path to the permanent path
      final File newImage = await _image!.copy(permanentPath);
      imagePath = newImage.path;
    }

    await FirebaseFirestore.instance.collection('pengaduan').add({
      'isi': _pengaduanController.text,
      'createdBy': userEmail,
      'status': 'Terkirim',
      'timestamp': FieldValue.serverTimestamp(),
      'imagePath': imagePath, // Save the permanent local file path
    });

    // Play sound on success
    AudioService.playNotificationSound();

    _pengaduanController.clear();
    setState(() {
      _image = null;
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Pengaduan berhasil dikirim!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pengaduan & Aspirasi")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Buat Pengaduan Baru",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _pengaduanController,
              decoration: InputDecoration(
                labelText: "Tulis pengaduan Anda di sini...",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            _image == null
                ? OutlinedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text("Tambah Foto Bukti"),
                    onPressed: () => _showPicker(context),
                  )
                : Column(
                    children: [
                      Image.file(
                        _image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        child: Text("Ganti Foto"),
                        onPressed: () => _showPicker(context),
                      ),
                    ],
                  ),
            SizedBox(height: 16),
            _isSubmitting
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _kirimPengaduan,
                    child: Text("Kirim Pengaduan"),
                  ),
            Divider(height: 40),
            Text(
              "Status Pengaduan Anda",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _buildStatusPengaduan(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPengaduan() {
    return FutureBuilder<String?>(
      future: _userEmailFuture,
      builder: (context, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!futureSnapshot.hasData || futureSnapshot.data == null) {
          return Center(child: Text("Tidak bisa memuat data pengguna."));
        }

        final userEmail = futureSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pengaduan')
              .where('createdBy', isEqualTo: userEmail)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (streamSnapshot.hasError) {
              return Center(child: Text("Error: ${streamSnapshot.error}"));
            }
            if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Anda belum membuat pengaduan."),
                ),
              );
            }

            final docs = streamSnapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                // Use 'imagePath' which is a local file path
                final imagePath = data['imagePath'];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: imagePath != null
                        // Display image from local file path
                        ? Image.file(
                            File(imagePath),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : null,
                    title: Text(data['isi'] ?? 'Tidak ada isi'),
                    subtitle: Text("Status: ${data['status'] ?? 'N/A'}"),
                    trailing: Chip(label: Text(data['status'] ?? 'N/A')),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
