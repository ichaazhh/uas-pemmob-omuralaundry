import 'package:flutter/material.dart';
import 'package:uas/app/history.dart'; // Mengimpor halaman riwayat pesanan

class PaymentScreen extends StatelessWidget {
  final order; // Mendefinisikan variabel order

  PaymentScreen(
      {required this.order}); // Konstruktor yang menerima order sebagai parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(''),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.signal_cellular_alt), // Ikon sinyal
                SizedBox(width: 8),
                Icon(Icons.wifi), // Ikon WiFi
                SizedBox(width: 8),
                Icon(Icons.battery_full), // Ikon baterai penuh
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade800,
                Colors.blue.shade400
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Detail Pembayaran',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white),
                  buildDetailRow('Nomor Invoice:',
                      order.invoice), // Menampilkan nomor invoice
                  buildDetailRow(
                      'Tanggal:', order.date), // Menampilkan tanggal pesanan
                  Divider(color: Colors.white),
                  buildDetailRow(
                    'Mesin :',
                    order.selectedMachine != null
                        ? 'Mesin ${order.selectedMachine! + 1}'
                        : 'Belum dipilih', // Menampilkan mesin yang dipilih
                  ),
                  buildDetailRow(
                    'Paket :',
                    order.selectedPackage != null
                        ? '${order.selectedPackage! + 1}'
                        : 'Belum dipilih', // Menampilkan paket yang dipilih
                  ),
                  buildDetailRow(
                    'Waktu ',
                    order.selectedTimeSlot ??
                        'Belum dipilih', // Menampilkan slot waktu yang dipilih
                  ),
                  buildDetailRow(
                    'Tampilkan Kartu Pengiriman:',
                    '${order.showDeliveryCard}', // Menampilkan opsi kartu pengiriman
                  ),
                  buildDetailRow(
                    'Lokasi :',
                    order.selectedLocation ??
                        'Belum dipilih', // Menampilkan lokasi pengiriman
                  ),
                  buildDetailRow(
                    'Detail Alamat:',
                    order.address ??
                        'Tidak tersedia', // Menampilkan alamat pengiriman
                  ),
                  Divider(color: Colors.white),
                  buildDetailRow(
                    'Biaya Pengiriman:',
                    order.estimatedCost.toString() ??
                        'Tidak tersedia', // Menampilkan biaya pengiriman
                  ),
                  buildDetailRow(
                    'Total Biaya:',
                    order.totalCost.toString() ??
                        'Tidak tersedia', // Menampilkan total biaya
                  ),
                  const Divider(color: Colors.white),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Implementasi logika untuk melihat pesanan
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          backgroundColor: Colors
                              .blue.shade900, // Warna latar belakang tombol
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white, // Warna teks tombol
                          ),
                          child: const Text('Lihat Pesanan'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderHistoryPage(), // Navigasi ke halaman riwayat pesanan
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String judul, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Order {
  final String invoice;
  final String date;
  final int? selectedMachine;
  final int? selectedPackage;
  final String? selectedTimeSlot;
  final bool showDeliveryCard;
  final String? selectedLocation;
  final String address;
  final String? estimatedCost;

  Order({
    required this.invoice,
    required this.date,
    this.selectedMachine,
    this.selectedPackage,
    this.selectedTimeSlot,
    required this.showDeliveryCard,
    this.selectedLocation,
    required this.address,
    this.estimatedCost,
  });
}
