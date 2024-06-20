import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas/app/home.dart';
import 'app/firebase_options.dart';
import 'package:uas/auth/login.dart'; // Tambahkan impor ini jika belum ada

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Sora',
        textTheme: TextTheme(
          bodyText1: TextStyle(fontFamily: 'Sora'),
          bodyText2: TextStyle(fontFamily: 'Sora'),
          button: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold),
          headline1: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold),
          headline2: TextStyle(fontFamily: 'Sora'),
          headline3: TextStyle(fontFamily: 'Sora'),
          headline4: TextStyle(fontFamily: 'Sora'),
          headline5: TextStyle(fontFamily: 'Sora'),
          headline6: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.bold),
        ),
      ),
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while checking auth state
        } else if (snapshot.hasData) {
          return HomeScreen(); // Redirect to HomeScreen if the user is logged in
        } else {
          return LoginPage(); // Redirect to LoginPage if the user is not logged in
        }
      },
    );
  }
}
