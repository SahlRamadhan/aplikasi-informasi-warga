import 'package:aplikasi_informasi_warga/screens/admin/admin_home_page.dart';
import 'package:aplikasi_informasi_warga/screens/auth/login_page.dart';
import 'package:aplikasi_informasi_warga/screens/warga/warga_home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAmUSly7JZtj0hXIvTZccQyy09KIHfCjG4",
      appId: "1:958346105988:android:c141983ddbcabb8fb29ed1",
      messagingSenderId: "958346105988",
      projectId: "aplikasiinformasiwarga",
      storageBucket: "aplikasiinformasiwarga.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(), // Set AuthWrapper as the home
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(backgroundColor: Colors.indigo, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.indigo),
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  Future<Map<String, dynamic>> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userRole = prefs.getString('userRole') ?? 'warga';
    return {'isLoggedIn': isLoggedIn, 'userRole': userRole};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          final bool isLoggedIn = snapshot.data?['isLoggedIn'] ?? false;
          final String userRole = snapshot.data?['userRole'] ?? 'warga';

          if (isLoggedIn) {
            if (userRole == 'admin') {
              return AdminHomePage();
            } else {
              return WargaHomePage();
            }
          } else {
            return LoginPage();
          }
        }
      },
    );
  }
}
