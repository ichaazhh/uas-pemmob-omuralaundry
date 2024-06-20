import 'package:flutter/material.dart'; // Package untuk UI Flutter
import 'package:url_launcher/url_launcher.dart'; // Package untuk membuka URL

void main() {
  runApp(MyApp()); // Menjalankan aplikasi Flutter
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
          AppProfileDua(), // Menggunakan halaman AppProfileDua sebagai halaman utama
    );
  }
}

class AppProfileDua extends StatelessWidget {
  // Data pengembang dalam bentuk List<Map<String, String>>
  final List<Map<String, String>> developerData1 = [
    {'key': 'Tempat Lahir', 'value': 'Magetan'},
    {'key': 'Tanggal Lahir', 'value': '06 November 2003'},
    {'key': 'Alamat', 'value': 'Jln. Bibis Tama III-A/1-A'},
    {'key': 'No. Telp', 'value': '085645641417'},
    {'key': 'Email', 'value': '22082010065@student.upnjatim.ac.id'},
    {'key': 'LinkedIn', 'value': 'https://www.linkedin.com/in/marisca-amanda'},
    {'key': 'GitHub', 'value': 'https://github.com/Marisca06'},
    {'key': 'Riwayat Pendidikan', 'value': 'SMAN 12 Surabaya'},
    {'key': 'Penghargaan', 'value': 'Juara 2 Lomba UI/UX T-DAYS#12 2023 UAD'},
  ];

  // Method untuk membuka URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url); // Buka URL jika bisa
    } else {
      throw 'Could not launch $url'; // Tangani jika tidak bisa membuka URL
    }
  }

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
      ),
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
            padding: const EdgeInsets.only(top: 150.0),
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
                  SizedBox(height: 60), // Spacer
                  Text(
                    'Marisca Amanda Hidayat', // Nama pengembang
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '22082010065', // NIM atau identitas lain
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: ListView.builder(
                        itemCount: developerData1.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            color: Colors.blue.shade800, // Warna latar Card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                developerData1[index]['key']!, // Judul atribut
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: GestureDetector(
                                onTap: () {
                                  final value = developerData1[index]['value']!;
                                  if (value.startsWith('http')) {
                                    _launchURL(
                                        value); // Buka URL jika dimulai dengan 'http'
                                  }
                                },
                                child: Text(
                                  developerData1[index]
                                      ['value']!, // Nilai atribut
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: developerData1[index]['value']!
                                            .startsWith('http')
                                        ? TextDecoration
                                            .underline // Beri garis bawah jika berupa URL
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/marisca.jpeg'), // Gambar profil pengembang
              ),
            ),
          ),
        ],
      ),
    );
  }
}
