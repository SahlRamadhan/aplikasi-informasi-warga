import 'package:aplikasi_informasi_warga/screens/warga/audio_player_page.dart';
import 'package:aplikasi_informasi_warga/screens/warga/edit_profile_page.dart';
import 'package:aplikasi_informasi_warga/screens/warga/informasi_list_page.dart';
import 'package:aplikasi_informasi_warga/screens/auth/login_page.dart';
import 'package:aplikasi_informasi_warga/screens/warga/offline_video_list_page.dart';
import 'package:aplikasi_informasi_warga/screens/warga/pengaduan_form_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WargaHomePage extends StatefulWidget {
  @override
  _WargaHomePageState createState() => _WargaHomePageState();
}

class _WargaHomePageState extends State<WargaHomePage> {
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Warga Home")),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          _buildWelcomeHeader(),
          SizedBox(height: 20),
          _buildMenuCard(
            context,
            icon: Icons.info,
            title: "Informasi Publik",
            subtitle: "Lihat informasi terbaru dari desa",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InformasiListPage()),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.report_problem,
            title: "Pengaduan & Aspirasi",
            subtitle: "Kirim pengaduan atau cek status",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PengaduanFormPage()),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.audiotrack,
            title: "Podcast & Audio",
            subtitle: "Dengarkan audio informasi dari warga",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AudioPlayerPage()));
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.video_library,
            title: "Video Komunitas",
            subtitle: "Tonton video kegiatan dan tutorial",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OfflineVideoListPage()));
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.person,
            title: "Edit Profil",
            subtitle: "Perbarui data diri Anda",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.logout,
            title: "Logout",
            subtitle: "Keluar dari akun Anda",
            onTap: _logout,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Selamat Datang,", style: Theme.of(context).textTheme.titleLarge),
        Text(
          _userEmail,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Chip(
          label: Text("Warga", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueGrey,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: color ?? Theme.of(context).primaryColor,
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        contentPadding: EdgeInsets.all(16.0),
      ),
    );
  }
}
