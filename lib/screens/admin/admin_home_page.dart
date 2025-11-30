import 'package:aplikasi_informasi_warga/screens/admin/kelola_informasi_page.dart';
import 'package:aplikasi_informasi_warga/screens/admin/kelola_pengaduan_page.dart';
import 'package:aplikasi_informasi_warga/screens/auth/login_page.dart';
import 'package:aplikasi_informasi_warga/screens/admin/user_management_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          _buildWelcomeHeader(),
          SizedBox(height: 20),
          _buildMenuCard(
            context,
            icon: Icons.info,
            title: "Kelola Informasi",
            subtitle: "Atur informasi publik dan video YouTube",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaInformasiPage()));
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.group,
            title: "Kelola Pengguna",
            subtitle: "Lihat dan kelola semua akun pengguna",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserManagementPage()));
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.report_problem,
            title: "Kelola Pengaduan",
            subtitle: "Tanggapi pengaduan dan aspirasi warga",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => KelolaPengaduanPage()));
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.logout,
            title: "Logout",
            subtitle: "Keluar dari sesi admin Anda",
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
        Text(
          "Selamat Datang, Admin",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          _userEmail,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Chip(
          label: Text("Admin", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.indigo,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color? color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: color ?? Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        contentPadding: EdgeInsets.all(16.0),
      ),
    );
  }
}
