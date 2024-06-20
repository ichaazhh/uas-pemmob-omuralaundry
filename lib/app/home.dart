import 'package:cloud_firestore/cloud_firestore.dart'; // Import untuk menggunakan Firestore dari Firebase
import 'package:flutter/material.dart'; // Import untuk menggunakan Material Design Widgets dari Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk menggunakan SharedPreferences
import 'package:uas/paket/standard_wash_screen.dart'; // Import untuk layar Standard Wash
import 'package:uas/paket/dry_cleaning_screen.dart'; // Import untuk layar Dry Cleaning
import 'package:uas/paket/premium_wash_screen.dart'; // Import untuk layar Premium Wash
import 'package:uas/paket/ironing_screen.dart'; // Import untuk layar Ironing
import 'package:uas/app/feedback_form.dart'; // Import untuk layar Feedback Form
import 'package:uas/profile/profil_satu.dart'; // Import untuk layar Profil Satu
import 'package:uas/profile/profil_dua.dart'; // Import untuk layar Profil Dua
import 'package:uas/profile/profile.dart'; // Import untuk layar Profil
import 'package:uas/app/history.dart'; // Import untuk layar History
import 'package:carousel_slider/carousel_slider.dart'; // Import untuk Carousel Slider

void main() {
  runApp(
      MyApp()); // Menjalankan aplikasi Flutter dengan MyApp sebagai root widget
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App', // Judul aplikasi
      home: HomeScreen(), // Menampilkan HomeScreen sebagai layar utama
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Indeks dari tab yang dipilih saat ini

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(), // Konten untuk tab Home
    OrderHistoryPage(), // Konten untuk tab History
    FeedbackPage(), // Konten untuk tab Feedback
    AppProfileScreen(), // Konten untuk tab Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Expanded(
              child: Center(
                child: Text(''), // Placeholder untuk judul tengah
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.signal_cellular_alt),
                const SizedBox(width: 8),
                Icon(Icons.wifi),
                const SizedBox(width: 8),
                Icon(Icons.battery_full),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade800, // Warna background header drawer
              ),
              child: Center(
                child: Text(
                  'Profil Pengembang',
                  style: TextStyle(
                    color: Colors.white, // Warna teks header drawer
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/ichaa.jpeg'), // Foto profil
              ),
              title: Text('Nurul Izzah'), // Nama profil
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AppProfileSatu()), // Navigasi ke layar profil satu
                );
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/marisca.jpeg'), // Foto profil
              ),
              title: Text('Marisca Amanda'), // Nama profil
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AppProfileDua()), // Navigasi ke layar profil dua
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _widgetOptions.elementAt(
              _selectedIndex), // Menampilkan konten sesuai dengan tab yang dipilih
          if (_selectedIndex ==
              0) // Tampilkan DropDownContainer hanya ketika tab Home dipilih
            Align(
              alignment: Alignment.bottomCenter,
              child: DropDownContainer(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Tipe BottomNavigationBar
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Label untuk tab Home
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History', // Label untuk tab History
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback', // Label untuk tab Feedback
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // Label untuk tab Profile
          ),
        ],
        currentIndex: _selectedIndex, // Indeks tab yang dipilih saat ini
        selectedItemColor: Colors.blue.shade800, // Warna item yang dipilih
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Mengubah indeks tab yang dipilih
          });
        },
      ),
    );
  }
}

class DropDownContainer extends StatefulWidget {
  @override
  _DropDownContainerState createState() => _DropDownContainerState();
}

class _DropDownContainerState extends State<DropDownContainer> {
  bool _expanded =
      false; // Menyimpan status apakah container diperluas atau tidak

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade800, // Warna background container
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, -3), // Offset untuk bayangan
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Sedang Berlangsung',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Warna teks
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _expanded =
                        !_expanded; // Mengubah status diperluas atau tidak
                  });
                },
              ),
            ),
            if (_expanded)
              FutureBuilder<List<DocumentSnapshot>>(
                future:
                    getInProgressOrders(), // Mendapatkan pesanan yang sedang berlangsung
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Menampilkan loading jika data belum tersedia
                  } else if (snapshot.hasError) {
                    return Text(
                        'Error: ${snapshot.error}'); // Menampilkan error jika ada
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                        'No in-progress orders found'); // Menampilkan pesan jika tidak ada data
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var order = snapshot.data![index].data()
                            as Map<String, dynamic>;
                        String invoice = order['invoice'] ?? 'No Invoice';
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading:
                                Icon(Icons.timer, color: Colors.blue.shade800),
                            title: Text(
                              'Invoice $invoice',
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              order['status'] ?? 'No status',
                              style: TextStyle(color: Colors.black),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blue.shade800,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OrderHistoryPage()), // Navigasi ke halaman riwayat pesanan
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> getInProgressOrders() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('histories')
        .where('status', isEqualTo: 'Diproses')
        .get();
    return querySnapshot
        .docs; // Mendapatkan data pesanan yang sedang diproses dari Firestore
  }
}

class HomeContent extends StatelessWidget {
  // TODO 1: Retrieve data where status is "Selesai"
  Future<List<DocumentSnapshot>> getCompletedOrders() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('histories')
        .where('status', isEqualTo: 'Selesai')
        .get();
    return querySnapshot
        .docs; // Mengembalikan daftar dokumen pesanan yang telah selesai
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUsername(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        String greetingText = 'Hello';
        if (snapshot.connectionState == ConnectionState.waiting) {
          greetingText = 'Loading...';
        } else if (snapshot.hasError) {
          greetingText = 'Error loading username';
        } else if (snapshot.hasData) {
          greetingText = 'Hello ${snapshot.data}';
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greetingText,
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Jl. Ngagel Rejo Kidul No.77, Surabaya',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AspectRatio(
                    aspectRatio: 640 / 145,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 640 / 182,
                        enlargeCenterPage: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: [
                        'assets/laundry.png',
                        'assets/laundry2.png',
                        'assets/laundry3.png',
                      ].map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.asset(
                              i,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ServiceButton(
                        icon: Icons.local_laundry_service,
                        label: 'Standard wash',
                        page: StandardWashScreen(),
                        backgroundColor: Colors.blue.shade800,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                      ServiceButton(
                        icon: Icons.dry_cleaning,
                        label: 'Dry cleaning',
                        page: DryCleaningScreen(),
                        backgroundColor: Colors.blue.shade800,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                      ServiceButton(
                        icon: Icons.local_laundry_service_outlined,
                        label: 'Premium wash',
                        page: PremiumWashScreen(),
                        backgroundColor: Colors.blue.shade800,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                      ServiceButton(
                        icon: Icons.iron,
                        label: 'Ironing',
                        page: IroningScreen(),
                        backgroundColor: Colors.blue.shade800,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Order Selesai',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder<List<DocumentSnapshot>>(
                  future: getCompletedOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Menampilkan loading jika data belum tersedia
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Menampilkan error jika ada
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text(
                          'No completed orders found'); // Menampilkan pesan jika tidak ada data
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var order = snapshot.data![index].data()
                              as Map<String, dynamic>;
                          String invoice = order['invoice'] ?? 'No Invoice';
                          return Card(
                            color: Color(0xFF1565C0),
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading:
                                  Icon(Icons.check_circle, color: Colors.white),
                              title: Text(
                                'Invoice $invoice',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                order['status'] ?? 'No status',
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.white),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderHistoryPage(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ??
        ''; // Mendapatkan username dari SharedPreferences
  }
}

class ServiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget page;
  final Color backgroundColor; // Warna latar belakang tombol
  final Color iconColor; // Warna ikon tombol
  final Color textColor; // Warna teks tombol

  const ServiceButton({
    required this.icon,
    required this.label,
    required this.page,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor, // Mengatur warna latar belakang sesuai properti
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    page), // Navigasi ke halaman yang sesuai dengan properti
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon,
                size: 50,
                color: iconColor), // Mengatur warna ikon sesuai properti
            SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 16,
                    color: textColor)), // Mengatur warna teks sesuai properti
          ],
        ),
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // TODO: Retrieve data where status is "Selesai"
  Future<List<DocumentSnapshot>> getCompletedOrders() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('histories')
        .where('status', isEqualTo: 'Selesai')
        .get();
    return querySnapshot
        .docs; // Mengembalikan daftar dokumen pesanan yang telah selesai
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.orange,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Order Selesai',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: getCompletedOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  ); // Menampilkan loading jika data belum tersedia
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  ); // Menampilkan error jika ada
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No completed orders found'),
                  ); // Menampilkan pesan jika tidak ada data
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var order =
                          snapshot.data![index].data() as Map<String, dynamic>;
                      String invoice = order['invoice'] ?? 'No Invoice';
                      double productRating =
                          order['productRating']?.toDouble() ?? 0;

                      return Card(
                        elevation: 2.0,
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        color: Colors.blue.shade800, // Warna biru pada card
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          leading: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Invoice $invoice',
                                style: TextStyle(
                                    color: Colors.white), // Tulisannya putih
                              ),
                              if (productRating > 0)
                                _buildStarRating(productRating),
                            ],
                          ),
                          trailing: productRating == 0
                              ? Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Nilai',
                                    style:
                                        TextStyle(color: Colors.blue.shade800),
                                  ),
                                )
                              : null,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FeedbackForm(invoice: invoice)),
                            ); // Navigasi ke halaman formulir umpan balik dengan nomor invoice
                            if (result == true) {
                              setState(() {});
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

getCompletedOrders() {}
