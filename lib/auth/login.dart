import 'package:flutter/material.dart'; // Package untuk UI Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore untuk database
import 'package:material_dialogs/material_dialogs.dart'; // Package untuk dialogs kustom
import 'package:material_dialogs/widgets/buttons/icon_button.dart'; // Widget button kustom untuk dialogs
import 'package:shared_preferences/shared_preferences.dart'; // Package untuk menyimpan data lokal
import 'package:uas/app/home.dart'; // Import HomeScreen untuk navigasi
import 'package:uas/auth/register.dart'; // Import RegisterPage untuk navigasi
import 'package:lottie/lottie.dart'; // Package untuk menampilkan animasi Lottie

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  final TextEditingController _emailController =
      TextEditingController(); // Controller untuk input email
  final TextEditingController _passwordController =
      TextEditingController(); // Controller untuk input password

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future:
          checkLoginStatus(), // FutureBuilder untuk menampilkan halaman berdasarkan status login
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return HomeScreen(); // Jika sudah login, navigasi ke HomeScreen
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(''), // Judul AppBar kosong
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.signal_cellular_alt), // Icon sinyal seluler
                      SizedBox(width: 8), // Spacer
                      Icon(Icons.wifi), // Icon wifi
                      SizedBox(width: 8), // Spacer
                      Icon(Icons.battery_full), // Icon baterai penuh
                    ],
                  ),
                ],
              ),
              centerTitle: true, // Pusatkan judul AppBar
            ),
            body: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade800,
                      Colors.blue.shade400
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 80), // Spacer atas
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Masuk", // Judul halaman login
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10), // Spacer
                          Text(
                            "Selamat datang kembali di Omura Laundry!", // Subjudul
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20), // Spacer
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 40), // Spacer
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Form(
                                key: _formKey, // Key form untuk validasi
                                child: Column(
                                  children: <Widget>[
                                    _buildTextFormField("Email",
                                        _emailController), // Input email
                                    SizedBox(height: 20), // Spacer
                                    _buildTextFormField(
                                        "Kata Sandi", _passwordController,
                                        isObscure:
                                            true), // Input password (tersembunyi)
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20), // Spacer
                            Text(
                              "Lupa kata sandi?", // Lupa password
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 20), // Spacer
                            MaterialButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  try {
                                    // Fetch user data from Firestore
                                    QuerySnapshot users =
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .where('email',
                                                isEqualTo:
                                                    _emailController.text)
                                            .where('password',
                                                isEqualTo:
                                                    _passwordController.text)
                                            .get();

                                    if (users.docs.isNotEmpty) {
                                      // Save login data to local storage
                                      String username =
                                          users.docs.first.get('username');
                                      String address =
                                          users.docs.first.get('address');
                                      String phoneNumber =
                                          users.docs.first.get('phone_number');

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'username', username);
                                      await prefs.setString('address', address);
                                      await prefs.setString(
                                          'phone_number', phoneNumber);
                                      await prefs.setString(
                                          'email', _emailController.text);
                                      await prefs.setString(
                                          'password', _passwordController.text);

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeScreen()),
                                      );
                                    } else {
                                      // Jika login gagal, tampilkan dialog
                                      Dialogs.materialDialog(
                                        color: Colors.white,
                                        msg:
                                            'Mohon masukkan email dan password yang benar',
                                        title: 'Email atau Password Salah!',
                                        lottieBuilder: Lottie.asset(
                                          'assets/failed.json',
                                          fit: BoxFit.contain,
                                        ),
                                        context: context,
                                        msgAlign: TextAlign
                                            .center, // Pusatkan teks pada dialog
                                        actions: [
                                          IconsButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginPage()),
                                              );
                                            },
                                            text: 'Close',
                                            iconData: Icons.done,
                                            color: Colors.blue,
                                            textStyle:
                                                TextStyle(color: Colors.white),
                                            iconColor: Colors.white,
                                          ),
                                        ],
                                      );
                                    }
                                  } catch (e) {
                                    print(
                                        e); // Tangkap dan cetak error jika ada
                                  }
                                }
                              },
                              height: 50, // Tinggi button
                              color: Colors.blue.shade900, // Warna button
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(50), // Bentuk button
                              ),
                              child: Center(
                                child: Text(
                                  "Masuk", // Teks button
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20), // Spacer
                            MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegisterPage()), // Navigasi ke halaman registrasi
                                );
                              },
                              height: 50, // Tinggi button
                              color: Colors.blue.shade900, // Warna button
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(50), // Bentuk button
                              ),
                              child: Center(
                                child: Text(
                                  "Daftar", // Teks button
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') !=
        null; // Mengembalikan true jika username tersimpan
  }

  Widget _buildTextFormField(String title, TextEditingController controller,
      {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 10), // Spacer
        TextFormField(
          controller: controller,
          obscureText:
              isObscure, // Jika true, textfield akan menyembunyikan input
          decoration: InputDecoration(
            hintText: "Masukkan $title", // Hint text
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.blue.shade900),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.blue.shade900),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$title harus diisi'; // Validasi jika input kosong
            }
            return null;
          },
        ),
      ],
    );
  }
}
