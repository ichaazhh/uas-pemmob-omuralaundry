import 'package:flutter/material.dart'; // Mengimpor pustaka Flutter untuk membangun UI
import 'package:cloud_firestore/cloud_firestore.dart'; // Mengimpor pustaka Firestore untuk interaksi dengan database
import 'package:uas/entity/order_item.dart'; // Mengimpor definisi kelas OrderItem dari package 'uas'
import 'package:uas/payment/payment_fix.dart'; // Mengimpor halaman PaymentScreenFix dari package 'uas'

class OrderHistoryPage extends StatefulWidget {
  // Deklarasi kelas OrderHistoryPage sebagai StatefulWidget
  @override
  _OrderHistoryPageState createState() =>
      _OrderHistoryPageState(); // Membuat state OrderHistoryPage
}

class _OrderHistoryPageState extends State<
        OrderHistoryPage> // State untuk OrderHistoryPage dengan mixin SingleTickerProviderStateMixin
    with
        SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller untuk TabBar
  List<OrderItem> allOrders =
      []; // List untuk menyimpan semua pesanan dari Firestore

  @override
  void initState() {
    // Method yang dipanggil ketika widget diinisialisasi
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this); // Inisialisasi TabController dengan 4 tab
    _fetchOrders(); // Memanggil method untuk mengambil data pesanan dari Firestore
  }

  @override
  void dispose() {
    // Dipanggil ketika state dihapus
    _tabController.dispose(); // Melepaskan TabController
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    // Method untuk mengambil data pesanan dari Firestore
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('histories')
          .get(); // Mengambil koleksi 'histories' dari Firestore
      final orders = querySnapshot.docs.map((doc) {
        // Mapping setiap dokumen menjadi objek OrderItem
        return OrderItem(
          // Membuat objek OrderItem dari dokumen Firestore
          service: doc['service'] ??
              '', // Mengambil atribut 'service' atau default kosong jika tidak ada
          orderType: doc['orderType'] ??
              '', // Mengambil atribut 'orderType' atau default kosong jika tidak ada
          status: doc['status'] ??
              '', // Mengambil atribut 'status' atau default kosong jika tidak ada
          date: doc['date'] ??
              '', // Mengambil atribut 'date' atau default kosong jika tidak ada
          progress: doc['progress'] ??
              0, // Mengambil atribut 'progress' atau default 0 jika tidak ada
          invoice: doc['invoice'] ??
              '', // Mengambil atribut 'invoice' atau default kosong jika tidak ada
          selectedMachine: doc['selectedMachine'] ??
              0, // Mengambil atribut 'selectedMachine' atau default 0 jika tidak ada
          selectedPackage: doc['selectedPackage'] ??
              0, // Mengambil atribut 'selectedPackage' atau default 0 jika tidak ada
          selectedTimeSlot: doc['selectedTimeSlot'] ??
              '', // Mengambil atribut 'selectedTimeSlot' atau default kosong jika tidak ada
          selectedLocation: doc['selectedLocation'] ??
              '', // Mengambil atribut 'selectedLocation' atau default kosong jika tidak ada
          showDeliveryCard: doc['showDeliveryCard'] ??
              false, // Mengambil atribut 'showDeliveryCard' atau default false jika tidak ada
          address: doc['address'] ??
              '', // Mengambil atribut 'address' atau default kosong jika tidak ada
          estimatedCost: doc['estimatedCost'] ??
              0, // Mengambil atribut 'estimatedCost' atau default 0 jika tidak ada
          totalCost: doc['totalCost'] ??
              0, // Mengambil atribut 'totalCost' atau default 0 jika tidak ada
        );
      }).toList();

      setState(() {
        allOrders =
            orders; // Memperbarui state dengan daftar pesanan yang diambil dari Firestore
      });
    } catch (e) {
      // Tangani error yang terjadi saat pengambilan data
      print("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Method untuk membangun UI halaman OrderHistoryPage
    return Scaffold(
      // Widget utama sebagai kerangka halaman
      body: Column(
        // Column untuk menempatkan elemen secara vertikal
        children: [
          TabBar(
            // TabBar untuk navigasi antar status pesanan
            controller:
                _tabController, // Menggunakan TabController yang telah diinisialisasi
            labelColor: Colors.blue.shade900, // Warna teks label yang aktif
            tabs: [
              Tab(text: 'Semua'), // Tab 'Semua'
              Tab(text: 'Diproses'), // Tab 'Diproses'
              Tab(text: 'Bayar'), // Tab 'Bayar'
              Tab(text: 'Selesai'), // Tab 'Selesai'
            ],
          ),
          Expanded(
            // Expanded untuk mengisi ruang tersisa dengan TabBarView
            child: TabBarView(
              // TabBarView untuk menampilkan konten berdasarkan tab yang aktif
              controller: _tabController, // Menggunakan TabController yang sama
              children: [
                _buildOrderList(
                    allOrders), // Menampilkan daftar pesanan 'Semua'
                _buildOrderList(_filterOrders(
                    'Diproses')), // Menampilkan daftar pesanan 'Diproses'
                _buildOrderList(_filterOrders(
                    'Belum Bayar')), // Menampilkan daftar pesanan 'Belum Bayar'
                _buildOrderList(_filterOrders(
                    'Selesai')), // Menampilkan daftar pesanan 'Selesai'
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<OrderItem> _filterOrders(String status) {
    // Method untuk memfilter pesanan berdasarkan status
    return allOrders
        .where((order) => order.status == status)
        .toList(); // Mengembalikan list pesanan dengan status tertentu
  }

  Widget _buildOrderList(List<OrderItem> orders) {
    // Method untuk membangun daftar pesanan
    return ListView.builder(
      // ListView untuk menampilkan daftar pesanan secara dinamis
      itemCount: orders.length, // Jumlah item dalam daftar pesanan
      itemBuilder: (context, index) {
        return _buildOrderCard(
            orders[index]); // Memanggil method untuk membangun card pesanan
      },
    );
  }

  Widget _buildOrderCard(order) {
    // Method untuk membangun card pesanan
    return Card(
      // Card sebagai wadah untuk menampilkan informasi pesanan
      margin: EdgeInsets.all(
          10.0), // Margin untuk memberi jarak antara card dengan elemen lainnya
      shape: RoundedRectangleBorder(
        // Bentuk card dengan sudut bulat
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0, // Efek bayangan pada card
      color: Colors.blue.shade900, // Warna latar belakang card
      child: Padding(
        // Padding di dalam card untuk memberi ruang di sekitar konten
        padding: EdgeInsets.all(15.0),
        child: Stack(
          // Stack untuk menempatkan elemen secara bertumpuk
          children: [
            Column(
              // Column untuk menata elemen secara vertikal
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Penataan elemen dari kiri ke kanan
              children: [
                Padding(
                  // Padding untuk memberi ruang di sekitar teks
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    // Teks untuk menampilkan jenis layanan dan jenis pesanan
                    "${order.service} - ${order.orderType}",
                    style: TextStyle(
                      // Gaya teks untuk teks judul
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                    'Status: ${order.status}', // Teks untuk menampilkan status pesanan
                    style: TextStyle(color: Colors.white)),
                Text(
                    'Invoice: ${order.invoice}', // Teks untuk menampilkan nomor invoice
                    style: TextStyle(color: Colors.white)),
                SizedBox(
                    height: 16), // SizedBox untuk memberi jarak antar elemen
                Row(
                  // Row untuk menempatkan elemen secara horizontal
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Penataan elemen dari kanan dan kiri
                  children: List.generate(4, (index) {
                    // Membangkitkan list berdasarkan jumlah langkah
                    Color
                        stepColor = // Warna langkah tergantung pada progres langkah
                        index < order.progress ? Colors.white : Colors.grey;
                    return Column(
                      // Column untuk menata elemen secara vertikal
                      children: [
                        Icon(
                          // Icon untuk menampilkan ikon langkah
                          _getIconForStep(index),
                          color: stepColor,
                        ),
                        Text(
                          // Teks untuk menampilkan deskripsi langkah
                          _getStepDescription(index),
                          style: TextStyle(color: stepColor, fontSize: 10.0),
                        ),
                        if (index !=
                            4) // Jika bukan langkah terakhir, tambahkan container sebagai garis pemisah
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            height: 4.0,
                            width: 40.0,
                            color: stepColor,
                          ),
                      ],
                    );
                  }),
                ),
                if (order.status == 'Belum Bayar')
                  SizedBox(
                      height:
                          60), // Widget jika status pesanan adalah 'Belum Bayar'
                if (order.status == 'Diproses')
                  SizedBox(
                      height:
                          60), // Widget jika status pesanan adalah 'Diproses'
              ],
            ),
            Positioned(
              // Positioned untuk menempatkan elemen pada posisi tertentu
              top: 10, // Jarak dari atas
              right: 10, // Jarak dari kanan
              child: Container(
                // Container untuk menampilkan tanggal pesanan
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  '${order.date}', // Teks tanggal pesanan
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (order.status ==
                'Belum Bayar') // Widget jika status pesanan adalah 'Belum Bayar'
              Positioned(
                // Positioned untuk menempatkan tombol pada posisi tertentu
                bottom: 10, // Jarak dari bawah
                right: 10, // Jarak dari kanan
                child: Padding(
                  // Padding untuk memberi ruang di sekitar tombol
                  padding: EdgeInsets.only(right: 4.0, left: 8.0, bottom: 8.0),
                  child: MaterialButton(
                    // Tombol untuk mengarahkan ke halaman pembayaran
                    minWidth: 100,
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    color: Colors.white, // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      // Bentuk tombol dengan sudut bulat
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreenFix(
                                order:
                                    order), // Mengirim objek Order ke halaman pembayaran
                          ));
                    },
                    child: Padding(
                      // Padding di dalam tombol untuk memberi ruang di sekitar teks
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Text(
                        // Teks pada tombol untuk 'Bayar Sekarang'
                        'Bayar Sekarang',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            if (order.status ==
                'Diproses') // Widget jika status pesanan adalah 'Diproses'
              Positioned(
                // Positioned untuk menempatkan tombol pada posisi tertentu
                bottom: 10, // Jarak dari bawah
                right: 10, // Jarak dari kanan
                child: Padding(
                  // Padding untuk memberi ruang di sekitar tombol
                  padding: EdgeInsets.only(right: 4.0, left: 8.0, bottom: 8.0),
                  child: MaterialButton(
                    // Tombol untuk menyelesaikan pesanan
                    minWidth: 100,
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    color: Colors.white, // Warna latar belakang tombol
                    shape: RoundedRectangleBorder(
                      // Bentuk tombol dengan sudut bulat
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: () async {
                      // Event handler untuk menyelesaikan pesanan
                      try {
                        // Perbarui dokumen Firestore dengan progress 4 dan status "Selesai"
                        await FirebaseFirestore.instance
                            .collection('histories')
                            .where('invoice', isEqualTo: order.invoice)
                            .get()
                            .then((querySnapshot) {
                          querySnapshot.docs.forEach((doc) async {
                            await FirebaseFirestore.instance
                                .collection('histories')
                                .doc(doc.id)
                                .update({'progress': 4, "status": "Selesai"});
                          });
                        });

                        Navigator.pushReplacement(
                            // Navigasi ke halaman OrderHistoryPage setelah perubahan
                            context,
                            MaterialPageRoute(
                                builder: (context) => OrderHistoryPage()));
                      } catch (e) {
                        print(
                            'Error updating document: $e'); // Tangani kesalahan jika ada
                        // Handle error, maybe show an error dialog
                      }
                    },
                    child: Padding(
                      // Padding di dalam tombol untuk memberi ruang di sekitar teks
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Text(
                        // Teks pada tombol untuk 'Selesaikan Pesanan'
                        'Selesaikan Pesanan',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStep(int step) {
    // Method untuk mendapatkan ikon langkah berdasarkan indeks
    switch (step) {
      // Switch untuk memilih ikon berdasarkan indeks langkah
      case 0:
        return Icons.check_circle; // Ikon untuk langkah 0 (Pesanan Masuk)
      case 1:
        return Icons.payment; // Ikon untuk langkah 1 (Pembayaran)
      case 2:
        return Icons
            .local_laundry_service; // Ikon untuk langkah 2 (Pesanan Diproses)
      default:
        return Icons
            .directions_car; // Ikon default untuk langkah selanjutnya (Ambil Pesanan)
    }
  }

  String _getStepDescription(int step) {
    // Method untuk mendapatkan deskripsi langkah berdasarkan indeks
    switch (step) {
      // Switch untuk memilih deskripsi berdasarkan indeks langkah
      case 0:
        return 'Pesanan Masuk'; // Deskripsi untuk langkah 0 (Pesanan Masuk)
      case 1:
        return 'Pembayaran'; // Deskripsi untuk langkah 1 (Pembayaran)
      case 2:
        return 'Pesanan Diproses'; // Deskripsi untuk langkah 2 (Pesanan Diproses)
      default:
        return 'Ambil Pesanan'; // Deskripsi default untuk langkah selanjutnya (Ambil Pesanan)
    }
  }
}
