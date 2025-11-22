import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';

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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home(), debugShowCheckedModeBanner: false);
  }
}
