import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _alamatController;
  late TextEditingController _noController;
  String _userDocId = '';
  bool _isLoading = false;

  File? _image;
  File? _video;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _emailController = TextEditingController();
    _alamatController = TextEditingController();
    _noController = TextEditingController();
    _loadUserData();
    _loadMedia();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _noController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? docId = prefs.getString('docId');

    if (docId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _userDocId = userDoc.id;
        _namaController.text = userData['nama'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _alamatController.text = userData['alamat'] ?? '';
        _noController.text = userData['no'] ?? '';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMedia() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    String? videoPath = prefs.getString('profile_video');

    if (imagePath != null) {
      setState(() {
        _image = File(imagePath);
      });
    }

    if (videoPath != null) {
      setState(() {
        _video = File(videoPath);
      });
      _videoController = VideoPlayerController.file(_video!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = path.join(
        directory.path,
        path.basename(imageFile.path),
      );
      final File newImage = await imageFile.copy(newPath);

      setState(() {
        _image = newImage;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', newImage.path);
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final pickedFile = await _picker.pickVideo(source: source);

    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = path.join(
        directory.path,
        path.basename(videoFile.path),
      );
      final File newVideo = await videoFile.copy(newPath);

      setState(() {
        _video = newVideo;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_video', newVideo.path);

      _videoController = VideoPlayerController.file(_video!)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
        });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userDocId)
          .update({
            'nama': _namaController.text,
            'email': _emailController.text,
            'alamat': _alamatController.text,
            'no': _noController.text,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui!')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profil")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showPicker(context, 'image'),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : null,
                        child: _image == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_video != null && _videoController != null)
                      _videoController!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : Container(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _showPicker(context, 'video'),
                      child: Text(
                        _video == null ? 'Pilih Video' : 'Ganti Video',
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Nama tidak boleh kosong" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(
                        labelText: "Alamat",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Alamat tidak boleh kosong" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _noController,
                      decoration: InputDecoration(
                        labelText: "No. HP",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value!.isEmpty ? "No. HP tidak boleh kosong" : null,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text("Simpan Perubahan"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showPicker(context, String type) {
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
                  if (type == 'image') {
                    await _pickImage(ImageSource.gallery);
                  } else {
                    await _pickVideo(ImageSource.gallery);
                  }
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () async {
                  if (type == 'image') {
                    await _pickImage(ImageSource.camera);
                  } else {
                    await _pickVideo(ImageSource.camera);
                  }
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
}
