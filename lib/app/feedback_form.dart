import 'package:flutter/material.dart'; // Package untuk UI Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // Package untuk Firebase Firestore
import 'package:material_dialogs/material_dialogs.dart'; // Package untuk dialog kustom
import 'package:lottie/lottie.dart'; // Package untuk animasi Lottie
import 'package:material_dialogs/widgets/buttons/icon_button.dart'; // Package untuk tombol ikon di dalam dialog
import 'package:uas/app/home.dart'; // Import halaman HomeScreen

class FeedbackForm extends StatefulWidget {
  final String invoice; // Variabel untuk menyimpan nomor invoice

  FeedbackForm({required this.invoice}); // Constructor dengan parameter wajib

  @override
  _FeedbackFormState createState() =>
      _FeedbackFormState(); // Mengembalikan state dari form feedback
}

class _FeedbackFormState extends State<FeedbackForm> {
  double _productRating = 0; // Rating produk
  double _deliverySpeedRating = 0; // Rating kecepatan pengiriman
  double _courierServiceRating = 0; // Rating pelayanan kurir
  bool _showUsername = false; // Status untuk menampilkan username

  TextEditingController _productFeedbackController =
      TextEditingController(); // Controller untuk feedback produk
  TextEditingController _deliveryFeedbackController =
      TextEditingController(); // Controller untuk feedback kecepatan pengiriman
  TextEditingController _courierFeedbackController =
      TextEditingController(); // Controller untuk feedback pelayanan kurir

  void _submitFeedback() async {
    try {
      // Ambil dokumen dengan invoice yang sesuai
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('histories')
          .where('invoice', isEqualTo: widget.invoice)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

        // Update data feedback di Firestore
        await documentSnapshot.reference.update({
          'productRating': _productRating,
          'productFeedback': _productFeedbackController.text,
          'deliverySpeedRating': _deliverySpeedRating,
          'deliveryFeedback': _deliveryFeedbackController.text,
          'courierServiceRating': _courierServiceRating,
          'courierFeedback': _courierFeedbackController.text,
          'showUsername': _showUsername,
        });

        // Tampilkan dialog sukses
        Dialogs.materialDialog(
          color: Colors.white,
          msg:
              'Terima kasih telah memberikan penilaian terhadap layanan Omura Laundry',
          title: 'Feedback terkirim!',
          lottieBuilder: Lottie.asset(
            'assets/success.json',
            fit: BoxFit.contain,
          ),
          context: context,
          msgAlign: TextAlign.center, // Teks pesan diatur rata tengah
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
      } else {
        // Tampilkan dialog jika invoice tidak ditemukan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error, color: Colors.red), // Icon error
                  SizedBox(width: 8),
                  Text('Error'),
                ],
              ),
              content: Text('Invoice not found.'), // Pesan konten
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Tangani kesalahan
      print('Error submitting feedback: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red), // Icon error
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Text(
                'Failed to submit feedback. Please try again.'), // Pesan konten
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Widget untuk menampilkan rating bintang
  Widget _buildStarRating(double rating, ValueChanged<double> onRatingChanged) {
    List<String> ratingDescriptions = [
      'Sangat Buruk',
      'Buruk',
      'Biasa',
      'Baik',
      'Sangat Baik'
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ...List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.orange,
            ),
            onPressed: () {
              onRatingChanged(index + 1.0);
            },
          );
        }),
        if (rating > 0)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              ratingDescriptions[rating.toInt() - 1],
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  // Widget untuk bagian input feedback
  Widget _buildFeedbackSection(
      String title,
      double rating,
      ValueChanged<double> onRatingChanged,
      TextEditingController feedbackController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800), // Gaya teks judul
              ),
            ),
            _buildStarRating(
                rating, onRatingChanged), // Tampilkan rating bintang
          ],
        ),
        if (rating > 0) ...[
          SizedBox(height: 16), // Spasi
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Logika untuk menambah foto
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.blue.shade800), // Garis pinggir tombol
                  ),
                  icon: Icon(Icons.camera_alt,
                      color: Colors.blue.shade800), // Ikon kamera
                  label: Text('Tambah Foto',
                      style: TextStyle(
                          color: Colors.blue.shade800)), // Teks tambah foto
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Logika untuk menambah video
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.blue.shade800), // Garis pinggir tombol
                  ),
                  icon: Icon(Icons.videocam,
                      color: Colors.blue.shade800), // Ikon video
                  label: Text('Tambah Video',
                      style: TextStyle(
                          color: Colors.blue.shade800)), // Teks tambah video
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: feedbackController,
            maxLines: 4, // Jumlah baris maksimal
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue.shade800), // Garis pinggir teks input
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors
                        .blue.shade800), // Garis pinggir teks input saat aktif
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue
                        .shade800), // Garis pinggir teks input saat terfokus
              ),
              hintText:
                  'Tulis feedback atau keluhan Anda di sini...', // Hint teks
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bagikan penilaianmu dan bantu Pengguna lain membuat pilihan yang lebih baik!', // Pesan bantuan
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tampilkan username pada penilaian',
                  style: TextStyle(
                      color: Colors.grey)), // Teks opsi tampilkan username
              Switch(
                value: _showUsername,
                onChanged: (value) {
                  setState(() {
                    _showUsername = value; // Perbarui status tampilkan username
                  });
                },
                activeColor: Colors.blue.shade800, // Warna aktif switch
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.signal_cellular_alt), // Icon sinyal seluler
            SizedBox(width: 8),
            Icon(Icons.wifi), // Icon wifi
            SizedBox(width: 8),
            Icon(Icons.battery_full), // Icon baterai penuh
          ],
        ),
        centerTitle: true, // Judul AppBar diatur rata tengah
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildFeedbackSection('Kualitas Layanan', _productRating,
                      (rating) {
                    setState(() {
                      _productRating = rating; // Perbarui rating produk
                    });
                  }, _productFeedbackController),
                  Divider(), // Garis pemisah
                  _buildFeedbackSection(
                      'Kecepatan Pengiriman', _deliverySpeedRating, (rating) {
                    setState(() {
                      _deliverySpeedRating =
                          rating; // Perbarui rating kecepatan pengiriman
                    });
                  }, _deliveryFeedbackController),
                  Divider(), // Garis pemisah
                  _buildFeedbackSection(
                      'Pelayanan Kurir', _courierServiceRating, (rating) {
                    setState(() {
                      _courierServiceRating =
                          rating; // Perbarui rating pelayanan kurir
                    });
                  }, _courierFeedbackController),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback, // Fungsi tombol kirim feedback
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800, // Warna latar tombol
                ),
                child: Text(
                  'Kirim Feedback',
                  style: TextStyle(color: Colors.white), // Warna teks tombol
                ),
              ),
            ),
            SizedBox(height: 20), // Spasi vertikal
          ],
        ),
      ),
    );
  }
}
