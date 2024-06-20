import 'package:flutter/material.dart'; // Import dasar untuk Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk menggunakan SharedPreferences
import 'package:uas/auth/login.dart'; // Import halaman Login, pastikan path dan nama file sesuai

void main() {
  runApp(MyApp()); // Memulai aplikasi dengan widget MyApp
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
          AppProfileScreen(), // Menetapkan halaman utama aplikasi sebagai AppProfileScreen
    );
  }
}

class AppProfileScreen extends StatefulWidget {
  @override
  _AppProfileScreenState createState() => _AppProfileScreenState();
}

class _AppProfileScreenState extends State<AppProfileScreen> {
  String username = ''; // Variabel untuk menyimpan username
  String email = ''; // Variabel untuk menyimpan email
  String phoneNumber = ''; // Variabel untuk menyimpan nomor telepon
  String address = ''; // Variabel untuk menyimpan alamat

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Memuat data pengguna saat inisialisasi widget
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Menginisialisasi SharedPreferences
    setState(() {
      // Mengambil data dari SharedPreferences atau menggunakan nilai default jika kosong
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      phoneNumber = prefs.getString('phone_number') ?? '';
      address = prefs.getString('address') ?? '';
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Menginisialisasi SharedPreferences
    await prefs
        .clear(); // Menghapus semua data dari SharedPreferences saat logout
    // Navigasi kembali ke halaman login setelah logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> developerData1 = [
      {
        'key': 'Username',
        'value': username,
        'icon': Icons.person
      }, // Data untuk item username
      {
        'key': 'Email',
        'value': email,
        'icon': Icons.email
      }, // Data untuk item email
      {
        'key': 'No. Telp',
        'value': phoneNumber,
        'icon': Icons.phone
      }, // Data untuk item nomor telepon
      {
        'key': 'Alamat',
        'value': address,
        'icon': Icons.home
      }, // Data untuk item alamat
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 5,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 50), // Spasi kosong untuk estetika
                  Text(
                    'Profile Pengguna', // Judul profil pengguna
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Omura Laundry', // Nama aplikasi atau perusahaan
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        itemCount:
                            developerData1.length, // Jumlah item dalam daftar
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            color: Colors
                                .blue.shade800, // Warna latar belakang card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              leading: Icon(
                                developerData1[index]
                                    ['icon'], // Icon untuk setiap item
                                color: Colors.white,
                              ),
                              title: Text(
                                developerData1[index]
                                    ['key']!, // Label untuk setiap item
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                developerData1[index]
                                    ['value']!, // Nilai untuk setiap item
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios, // Icon navigasi
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Spasi kosong untuk estetika
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            logout(); // Memanggil method logout saat tombol ditekan
                          },
                          icon: Icon(Icons.logout), // Icon di dalam tombol
                          label: Text('Logout'), // Label di dalam tombol
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .blue.shade800, // Warna latar belakang tombol
                            foregroundColor: Colors.white, // Warna teks tombol
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Spasi kosong untuk estetika
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    AssetImage('assets/profile.jpg'), // Gambar profil pengguna
              ),
            ),
          ),
        ],
      ),
    );
  }
}
