import 'dart:math'; // Mengimpor library dart untuk menggunakan fungsi Random
import 'package:flutter/material.dart'; // Mengimpor package material dari Flutter
import 'package:flutter/services.dart'; // Mengimpor package services dari Flutter
import 'package:uas/payment/paymentscreen.dart'; // Mengimpor file PaymentScreen dari package payment
import 'package:cloud_firestore/cloud_firestore.dart'; // Mengimpor library cloud_firestore untuk mengakses Firestore

void main() {
  runApp(const MyApp()); // Menjalankan aplikasi MyApp
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: IroningScreen(), // Menentukan layar utama aplikasi
    );
  }
}

class IroningScreen extends StatefulWidget {
  const IroningScreen({super.key});

  @override
  _IroningScreenState createState() => _IroningScreenState();
}

class _IroningScreenState extends State<IroningScreen> {
  final CollectionReference<Map<String, dynamic>> historiesCollection =
      FirebaseFirestore.instance
          .collection('histories'); // Mengakses koleksi histories di Firestore

  final CollectionReference<Map<String, dynamic>> packagesCollection =
      FirebaseFirestore.instance
          .collection('packages'); // Mengakses koleksi packages di Firestore

  List<Map<String, dynamic>> packages =
      []; // Menyimpan data paket dari Firestore
  bool isLoading = true; // Menyimpan status loading

  bool showDeliveryCard =
      false; // Menyimpan status tampil tidaknya kartu pengiriman
  TextEditingController addressController =
      TextEditingController(); // Mengontrol input alamat
  int? selectedMachine; // Menyimpan mesin yang dipilih
  int? selectedPackage; // Menyimpan paket yang dipilih
  TextEditingController weightController =
      TextEditingController(); // Mengontrol input berat
  String? selectedLocation; // Menyimpan lokasi pengiriman yang dipilih
  List<String> deliveryLocations = [
    // Daftar lokasi pengiriman
    'Wonokromo',
    'Jagir',
    'Darmo',
    'Ngagel',
    'Ngagel Rejo'
  ];
  int? estimatedCost; // Menyimpan estimasi ongkos kirim
  int? totalCost; // Menyimpan total biaya
  String? selectedTimeSlot; // Menyimpan slot waktu yang dipilih

  @override
  void initState() {
    super.initState();
    fetchPackages(); // Memanggil fungsi untuk mengambil data paket saat inisialisasi
  }

  Future<void> fetchPackages() async {
    try {
      QuerySnapshot querySnapshot = await packagesCollection
          .where('serviceType', isEqualTo: "Standard Wash")
          .get(); // Mengambil data paket dari Firestore berdasarkan serviceType
      setState(() {
        packages = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList(); // Menyimpan data paket ke dalam list
        isLoading = false; // Mengubah status loading menjadi false
      });
    } catch (e) {
      setState(() {
        isLoading =
            false; // Mengubah status loading menjadi false jika terjadi error
        // Handle error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Expanded(
              child: Center(
                child: Text(''),
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
      body: Stack(
        children: [
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AspectRatio(
                  aspectRatio: 640 / 312, // Menentukan rasio gambar
                  child: Image.asset(
                    'assets/omuraa.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 200), // Mengatur jarak vertikal
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(40.0, 40.0, 40.0, 40.0),
                    color: Color(0xFF3B41C9), // Mengatur warna background
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Pilih Mesin Tersedia:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // Menentukan jumlah kolom grid
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: 8, // Menentukan jumlah item
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMachine =
                                      index; // Menyimpan mesin yang dipilih
                                });
                              },
                              child: MachineCard(
                                index: index,
                                isSelected: selectedMachine ==
                                    index, // Menentukan status terpilih
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Pilih Paket:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Wrap(
                                  spacing: 8.0, // Spasi horizontal antar widget
                                  runSpacing:
                                      8.0, // Spasi vertikal antar widget saat wrap
                                  children:
                                      packages.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final pkg = entry.value;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedPackage =
                                              index; // Menyimpan paket yang dipilih
                                        });
                                      },
                                      child: PackageCard(
                                        name: pkg['name'],
                                        time: pkg['time'],
                                        price: pkg['price'],
                                        estimate: pkg['estimate'],
                                        isSelected: selectedPackage ==
                                            index, // Menentukan status terpilih
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                        const SizedBox(height: 20),
                        Text(
                          'Masukkan Berat Cucian (kg):',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  int currentValue =
                                      int.tryParse(weightController.text) ?? 0;
                                  setState(() {
                                    if (currentValue > 1) {
                                      currentValue--;
                                      weightController.text = currentValue
                                          .toString(); // Mengurangi berat cucian
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8), // Mengatur jarak antar widget
                              Container(
                                width: 120, // Mengatur lebar TextFormField
                                child: TextFormField(
                                  controller: weightController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign
                                      .center, // Mengatur alignment teks
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Berat (kg)',
                                    hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.3)),
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Berat cucian harus diisi';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 8), // Mengatur jarak antar widget
                              GestureDetector(
                                onTap: () {
                                  int currentValue =
                                      int.tryParse(weightController.text) ?? 0;
                                  setState(() {
                                    currentValue++;
                                    weightController.text = currentValue
                                        .toString(); // Menambah berat cucian
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Pilih Jam:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child:
                              buildTimeSlotDropdown(), // Memanggil dropdown untuk memilih slot waktu
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Pilih Opsi Pengiriman:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        CheckboxListTile(
                          title: Text(
                            'Pengiriman',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: showDeliveryCard,
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                          onChanged: (newValue) {
                            setState(() {
                              showDeliveryCard =
                                  newValue!; // Menyimpan status kartu pengiriman
                            });
                          },
                        ),
                        if (showDeliveryCard)
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi Pengiriman:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),
                                  DropdownButtonFormField<String>(
                                    value: selectedLocation,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedLocation =
                                            newValue!; // Menyimpan lokasi pengiriman yang dipilih
                                        _updateEstimatedCost(); // Memanggil fungsi untuk memperbarui estimasi ongkos kirim
                                        _updateTotalCost(); // Memanggil fungsi untuk memperbarui total biaya
                                      });
                                    },
                                    items: deliveryLocations.map((location) {
                                      return DropdownMenuItem<String>(
                                        value: location,
                                        child: Text(location),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      hintText: 'Pilih lokasi pengiriman',
                                    ),
                                    dropdownColor: Color(0xFFFFFFFF),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Alamat Pengiriman:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: addressController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Masukkan alamat pengiriman detail',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Estimasi Ongkir:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    estimatedCost != null
                                        ? '$estimatedCost'
                                        : 'Pilih lokasi untuk estimasi ongkir',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog(); // Menampilkan dialog konfirmasi
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  Size(double.infinity, 50)),
                            ),
                            child: TextButton(
                              child: Text('Konfirmasi Pesan'),
                              onPressed: () {
                                Navigator.of(context).pop(); // Menutup dialog
                                _saveOrderToFirestore(); // Menyimpan pesanan ke Firestore
                                // Membuat objek order
                                final String invoice =
                                    'INV-${100000 + Random().nextInt(900000)}';
                                final String date = DateTime.now().toString();
                                final order = Order(
                                  service: "Standart Wash",
                                  selectedMachine: selectedMachine,
                                  selectedPackage: selectedPackage,
                                  selectedTimeSlot: selectedTimeSlot,
                                  showDeliveryCard: showDeliveryCard,
                                  selectedLocation: selectedLocation,
                                  address: addressController.text,
                                  estimatedCost: estimatedCost,
                                  totalCost: totalCost,
                                  date: date,
                                  invoice: invoice,
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                        order:
                                            order), // Menavigasi ke layar pembayaran
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOrderToFirestore() async {
    // Fungsi untuk menyimpan pesanan ke Firestore
    final randomCode =
        'AL-${100000 + Random().nextInt(900000)}'; // Generate kode acak
    final invoice =
        'INV-${100000 + Random().nextInt(900000)}'; // Generate invoice acak
    final currentDate =
        DateTime.now().toString(); // Mendapatkan tanggal saat ini
    final defaultProgress = 2; // Progress default
    final defaultStatus = 'Belum Bayar'; // Status default

    try {
      await historiesCollection.add({
        // Menambahkan data ke koleksi histories di Firestore
        "service": "Standart Wash", // Layanan yang dipilih
        'invoice': invoice, // Invoice
        'selectedMachine': selectedMachine, // Mesin yang dipilih
        'selectedPackage': selectedPackage, // Paket yang dipilih
        'weight': double.parse(weightController.text), // Berat cucian
        'selectedTimeSlot': selectedTimeSlot, // Slot waktu yang dipilih
        'selectedLocation': selectedLocation, // Lokasi yang dipilih
        'showDeliveryCard': showDeliveryCard, // Menampilkan kartu pengiriman
        'address': addressController.text, // Alamat
        'estimatedCost': estimatedCost, // Estimasi biaya
        'totalCost': totalCost, // Total biaya
        'code': randomCode, // Kode acak
        'date': currentDate, // Tanggal pesanan
        'orderType': packages[selectedPackage!]
            ['name'], // Tipe pesanan berdasarkan paket yang dipilih
        'progress': defaultProgress, // Progress pesanan
        'status': defaultStatus, // Status pesanan
      });
    } catch (e) {
      showDialog(
        // Menampilkan dialog jika terjadi error
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"), // Judul dialog error
            content: Text("${e}"), // Konten dialog berisi pesan error
          );
        },
      );
    }
  }

  void _showConfirmationDialog() {
    // Fungsi untuk menampilkan dialog konfirmasi pesanan
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            // Baris judul dialog
            children: [
              Icon(Icons.check_circle,
                  color: Colors.green), // Ikon centang hijau
              SizedBox(width: 8),
              Text('Konfirmasi Pesanan'), // Teks judul dialog
            ],
          ),
          content: Text(
              'Apakah Anda yakin ingin memesan layanan ini?'), // Konten dialog
          actions: <Widget>[
            TextButton(
              child: Text('Batal'), // Teks tombol Batal
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Menutup dialog saat tombol Batal ditekan
              },
            ),
            TextButton(
              child: Text('Pesan'), // Teks tombol Pesan
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Menutup dialog saat tombol Pesan ditekan
                final String invoice =
                    'INV-${100000 + Random().nextInt(900000)}'; // Generate invoice acak
                final String date =
                    DateTime.now().toString(); // Mendapatkan tanggal saat ini
                final order = Order(
                  // Membuat objek order
                  service: "Standart Wash", // Layanan yang dipilih
                  selectedMachine: selectedMachine, // Mesin yang dipilih
                  selectedPackage: selectedPackage, // Paket yang dipilih
                  selectedTimeSlot: selectedTimeSlot, // Slot waktu yang dipilih
                  showDeliveryCard:
                      showDeliveryCard, // Menampilkan kartu pengiriman
                  selectedLocation: selectedLocation, // Lokasi yang dipilih
                  address: addressController.text, // Alamat
                  estimatedCost: estimatedCost, // Estimasi biaya
                  totalCost: totalCost, // Total biaya
                  invoice: invoice, // Invoice
                  date: date, // Tanggal pesanan
                );
                Navigator.of(context).push(
                  // Navigasi ke layar pembayaran
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                        order:
                            order), // Membuka layar PaymentScreen dengan order sebagai parameter
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _updateEstimatedCost() {
    // Fungsi untuk mengupdate estimasi biaya
    if (selectedLocation != null) {
      // Jika lokasi dipilih
      setState(() {
        switch (selectedLocation) {
          // Cek lokasi yang dipilih
          case 'Wonokromo':
            estimatedCost = 18000;
            break;
          case 'Jagir':
            estimatedCost = 14000;
            break;
          case 'Darmo':
            estimatedCost = 16000;
            break;
          case 'Ngagel':
            estimatedCost = 20000;
            break;
          case 'Ngagel Rejo':
            estimatedCost = 20000;
            break; // Handle lokasi lainnya atau set default
        }
      });
    }
  }

  void _updateTotalCost() {
    // Fungsi untuk mengupdate total biaya
    if (selectedPackage != null && weightController.text.isNotEmpty) {
      // Jika paket dan berat sudah diisi
      int weight =
          int.tryParse(weightController.text) ?? 0; // Parsing berat cucian
      double packagePrice =
          double.tryParse(packages[selectedPackage!]['price'].toString()) ??
              0.0; // Parsing harga paket
      setState(() {
        totalCost = (weight * packagePrice)
            as int?; // Menghitung total biaya berdasarkan berat dan harga paket
        totalCost = (totalCost! + estimatedCost!)
            as int?; // Menambahkan estimasi biaya ke total biaya
      });
    }
  }

  Widget buildTimeSlotDropdown() {
    // Widget dropdown untuk memilih slot waktu
    return DropdownButtonFormField<String>(
      value: selectedTimeSlot, // Nilai yang dipilih
      onChanged: (newValue) {
        // Fungsi saat nilai berubah
        setState(() {
          selectedTimeSlot = newValue; // Update nilai slot waktu yang dipilih
        });
      },
      items: [
        // Item-item dropdown
        '08:00 - 10:00',
        '10:00 - 12:00',
        '12:00 - 14:00',
        '14:00 - 16:00'
      ].map((timeSlot) {
        // Mapping item ke DropdownMenuItem
        return DropdownMenuItem<String>(
          value: timeSlot,
          child: Text(timeSlot), // Teks item dropdown
        );
      }).toList(),
      decoration: InputDecoration(
        hintText: 'Pilih jam', // Teks hint untuk dropdown
      ),
    );
  }
}

class MachineCard extends StatelessWidget {
  // Kelas untuk kartu mesin
  final int index; // Indeks mesin
  final bool isSelected; // Status terpilih atau tidak

  MachineCard(
      {required this.index,
      required this.isSelected}); // Konstruktor dengan parameter wajib

  @override
  Widget build(BuildContext context) {
    // Metode build untuk membuat tampilan
    return Container(
      decoration: BoxDecoration(
        // Dekorasi container
        color: isSelected
            ? Colors.blue
            : Colors.white, // Warna berdasarkan status terpilih
        borderRadius: BorderRadius.circular(10), // Sudut melingkar
        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(0.5), // Warna bayangan dengan opasitas
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 2), // Offset bayangan
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Mesin ${index + 1}', // Teks nama mesin berdasarkan indeks
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.black, // Warna teks berdasarkan status terpilih
            fontWeight: FontWeight.bold, // Ketebalan font
          ),
        ),
      ),
    );
  }
}

class PackageCard extends StatelessWidget {
  // Kelas untuk kartu paket
  final String name; // Nama paket
  final String time; // Waktu paket
  final int price; // Harga paket
  final String estimate; // Estimasi paket
  final bool isSelected; // Status terpilih atau tidak

  const PackageCard({
    super.key,
    required this.name, // Nama paket wajib
    required this.time, // Waktu paket wajib
    required this.price, // Harga paket wajib
    required this.estimate, // Estimasi paket wajib
    required this.isSelected, // Status terpilih wajib
  });

  @override
  Widget build(BuildContext context) {
    // Metode build untuk membuat tampilan
    return Container(
      decoration: BoxDecoration(
        // Dekorasi container
        color: isSelected
            ? Colors.blue
            : Colors.white, // Warna berdasarkan status terpilih
        borderRadius: BorderRadius.circular(10), // Sudut melingkar
        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.withOpacity(0.5), // Warna bayangan dengan opasitas
            spreadRadius: 2,
            blurRadius: 2, // Radius bayangan
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0), // Padding container
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Posisi utama di tengah
        children: [
          Text(
            name, // Nama paket
            style: TextStyle(
              fontWeight: FontWeight.bold, // Ketebalan font
              color: isSelected
                  ? Colors.white
                  : Colors.black, // Warna teks berdasarkan status terpilih
            ),
          ),
          const SizedBox(height: 4), // Jarak vertikal
          Text(
            time, // Waktu paket
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.black, // Warna teks berdasarkan status terpilih
            ),
          ),
          const SizedBox(height: 4), // Jarak vertikal
          Text(
            'Rp. $price/kg', // Harga paket per kg
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.black, // Warna teks berdasarkan status terpilih
            ),
          ),
          const SizedBox(height: 4), // Jarak vertikal
          Text(
            estimate, // Estimasi paket
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.black, // Warna teks berdasarkan status terpilih
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  // Kelas untuk objek pesanan
  final String service; // Layanan yang dipilih
  final String invoice; // Invoice
  final String date; // Tanggal pesanan
  final int? selectedMachine; // Mesin yang dipilih
  final int? selectedPackage; // Paket yang dipilih
  final int? weight; // Berat cucian
  final String? selectedTimeSlot; // Slot waktu yang dipilih
  final bool showDeliveryCard; // Menampilkan kartu pengiriman
  final String? selectedLocation; // Lokasi yang dipilih
  final String address; // Alamat
  final int? estimatedCost; // Estimasi biaya
  final int? totalCost; // Total biaya

  Order({
    // Konstruktor kelas Order
    required this.service, // Layanan wajib
    required this.invoice, // Invoice wajib
    required this.date, // Tanggal wajib
    this.selectedMachine, // Mesin opsional
    this.selectedPackage, // Paket opsional
    this.weight, // Berat opsional
    this.selectedTimeSlot, // Slot waktu opsional
    required this.showDeliveryCard, // Menampilkan kartu pengiriman wajib
    this.selectedLocation, // Lokasi opsional
    required this.address, // Alamat wajib
    this.estimatedCost, // Estimasi biaya opsional
    this.totalCost, // Total biaya opsional
  });
}
