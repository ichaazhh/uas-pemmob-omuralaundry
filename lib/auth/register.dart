import 'package:flutter/material.dart'; // Package untuk UI Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore untuk database
import 'package:material_dialogs/material_dialogs.dart'; // Package untuk dialogs kustom
import 'package:material_dialogs/widgets/buttons/icon_button.dart'; // Widget button kustom untuk dialogs
import 'package:uas/app/home.dart'; // Import HomeScreen untuk navigasi
import 'package:lottie/lottie.dart'; // Package untuk menampilkan animasi Lottie

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Key untuk validasi form
  final TextEditingController _nameController =
      TextEditingController(); // Controller untuk input nama
  final TextEditingController _emailController =
      TextEditingController(); // Controller untuk input email
  final TextEditingController _phoneNumberController =
      TextEditingController(); // Controller untuk input nomor telepon
  final TextEditingController _addressController =
      TextEditingController(); // Controller untuk input alamat
  final TextEditingController _passwordController =
      TextEditingController(); // Controller untuk input password

  @override
  Widget build(BuildContext context) {
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
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue.shade900,
            Colors.blue.shade800,
            Colors.blue.shade400
          ])),
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
                      "Daftar", // Judul halaman registrasi
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10), // Spacer
                    Text(
                      "Buat akun kamu untuk menikmati layanan omura laundry", // Subjudul
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Spacer
              SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade900.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Form(
                      key: _formKey, // Key form untuk validasi
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20), // Spacer
                          _buildTextFormField("Nama"), // Input nama
                          SizedBox(height: 20), // Spacer
                          _buildTextFormField("Email"), // Input email
                          SizedBox(height: 20), // Spacer
                          _buildTextFormField(
                              "Nomor Telepon"), // Input nomor telepon
                          SizedBox(height: 20), // Spacer
                          _buildTextFormField("Alamat"), // Input alamat
                          SizedBox(height: 20), // Spacer
                          _buildTextFormField("Buat Kata Sandi",
                              isObscure: true), // Input password (tersembunyi)
                          SizedBox(height: 40), // Spacer
                          MaterialButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Validasi form berhasil
                                _registerUser(
                                    context); // Panggil fungsi pendaftaran
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
                                "Daftar Sekarang", // Teks button
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String title, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900, // Warna biru pada judul
          ),
        ),
        SizedBox(height: 10), // Spacer
        TextFormField(
          obscureText:
              isObscure, // Jika true, textfield akan menyembunyikan input
          controller: _getControllerByTitle(
              title), // Ambil controller berdasarkan judul
          decoration: InputDecoration(
            hintText: "Masukkan $title", // Hint text
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                  color: Colors.blue
                      .shade900), // Warna biru pada border ketika tidak di-fokus
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                  color: Colors
                      .blue.shade900), // Warna biru pada border ketika di-fokus
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

  TextEditingController? _getControllerByTitle(String title) {
    switch (title) {
      case 'Nama':
        return _nameController; // Mengembalikan controller nama
      case 'Email':
        return _emailController; // Mengembalikan controller email
      case 'Nomor Telepon':
        return _phoneNumberController; // Mengembalikan controller nomor telepon
      case 'Alamat':
        return _addressController; // Mengembalikan controller alamat
      case 'Buat Kata Sandi':
        return _passwordController; // Mengembalikan controller password
      default:
        return null;
    }
  }

  void _registerUser(BuildContext context) async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      // Validasi form berhasil
      try {
        await FirebaseFirestore.instance.collection('users').add({
          'username': _nameController.text,
          'email': _emailController.text,
          'phone_number': _phoneNumberController.text,
          'address': _addressController.text,
          'password': _passwordController.text,
        });

        // Tampilkan dialog pendaftaran berhasil
        Dialogs.materialDialog(
          color: Colors.white,
          msg: 'Selamat Anda Berhasil Mendaftar',
          title: 'Pendaftaran Berhasil!',
          lottieBuilder: Lottie.asset(
            'assets/success.json',
            fit: BoxFit.contain,
          ),
          context: context,
          msgAlign: TextAlign.center, // Pusatkan teks pada dialog
          actions: [
            IconsButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              text: 'Close',
              iconData: Icons.done,
              color: Colors.blue,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ],
        );
      } catch (e) {
        // Tangani kesalahan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Kesalahan"),
              content: Text("Terjadi kesalahan: $e"), // Tampilkan pesan error
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
