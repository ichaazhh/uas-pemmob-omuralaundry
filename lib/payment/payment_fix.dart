import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uas/app/home.dart';
import 'package:uas/entity/order_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uas/payment/payment_bank.dart';

class Bank {
  final String code;
  final String name;

  Bank({required this.code, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      code: json['code'],
      name: json['name'],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double radius = 10.0;
    double cutoutRadius = 20.0;

    // Top left corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top right corner
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Top cutout
    path.lineTo(size.width, size.height / 2 - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    // Bottom right corner
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);

    // Bottom left corner
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Bottom cutout
    path.lineTo(0, size.height / 2 + cutoutRadius);
    path.arcToPoint(
      Offset(0, size.height / 2 - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class QrCodeScreen extends StatefulWidget {
  final OrderItem order;

  QrCodeScreen({required this.order});

  @override
  _QrCodeScreenState createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  late Timer _timer;
  int _remainingTime = 1800; // 30 minutes in seconds
  late String qrCodeUrl = "assets/loading.gif";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
        }
      });
    });
    fetchQrCode().then((url) {
      setState(() {
        qrCodeUrl = url;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secondsStr';
  }

  Future<String> fetchQrCode() async {
    final response = await http.get(Uri.parse(
        'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${widget.order.invoice}'));
    if (response.statusCode == 200) {
      return 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${widget.order.invoice}';
    } else {
      throw Exception('Failed to load QR code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Outer Padding
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade800,
                Colors.blue.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: ClipPath(
                    clipper: TicketClipper(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 80.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/logo-omura.png',
                            height: 50, // Adjust the height as needed
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Sora',
                              ),
                              children: [
                                TextSpan(text: 'Scan barcode ini\n'),
                                TextSpan(
                                  text: 'untuk pembayaran',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontFamily: 'Sora',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Image.network(
                            qrCodeUrl,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Berlaku hingga ${_formatTime(_remainingTime)}', // Display countdown timer from 30 minutes
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Sora',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Dialogs.bottomMaterialDialog(
                    msg: 'Apakah nominal pembayaran sudah benar??',
                    title: 'Konfirmasi Pembayaran',
                    context: context,
                    actions: [
                      IconsOutlineButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Close dialog when "Back" button is pressed
                        },
                        text: 'Back',
                        iconData: Icons.cancel_outlined,
                        textStyle: TextStyle(color: Colors.grey),
                        iconColor: Colors.grey,
                      ),
                      IconsButton(
                        onPressed: () async {
                          try {
                            // Update Firestore document
                            await FirebaseFirestore.instance
                                .collection('histories')
                                .where('invoice',
                                    isEqualTo: widget.order
                                        .invoice) // Access invoice from order
                                .get()
                                .then((querySnapshot) {
                              querySnapshot.docs.forEach((doc) async {
                                await FirebaseFirestore.instance
                                    .collection('histories')
                                    .doc(doc.id)
                                    .update(
                                        {'progress': 3, "status": "Diproses"});
                              });
                            });

                            // Show success dialog
                            Dialogs.materialDialog(
                              color: Colors.white,
                              msg:
                                  'Terima kasih telah menggunakan layanan Omura Laundry',
                              title: 'Pembayaran Sukses!',
                              lottieBuilder: Lottie.asset(
                                'assets/success.json',
                                fit: BoxFit.contain,
                              ),
                              context: context,
                              msgAlign: TextAlign
                                  .center, // Add setting to center-align text
                              actions: [
                                IconsButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
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
                            print('Error updating document: $e');
                            // Handle error, maybe show an error dialog
                          }
                        },
                        text: 'Continue',
                        iconData: Icons.arrow_forward,
                        color: Colors.blue,
                        textStyle: TextStyle(color: Colors.white),
                        iconColor: Colors.white,
                      ),
                    ],
                  );
                },
                icon: Icon(Icons.save_alt, color: Colors.white),
                label: Text('Simpan Tiket',
                    style: TextStyle(color: Colors.white, fontFamily: 'Sora')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Implement share functionality here
                },
                child: Text(
                  'Kirim ke Teman',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentScreenFix extends StatelessWidget {
  final OrderItem order;

  const PaymentScreenFix({Key? key, required this.order}) : super(key: key);

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
                Icon(Icons.signal_cellular_alt),
                SizedBox(width: 8),
                Icon(Icons.wifi),
                SizedBox(width: 8),
                Icon(Icons.battery_full),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200], // Background color for content
          ),
          child: Stack(
            children: [
              Container(
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Sora',
                            color: Colors.white, // White text color
                          ),
                        ),
                      ),
                    ),
                    Divider(color: Colors.white),
                    buildDetailRow('Nomor Invoice:', order.invoice),
                    buildDetailRow('Tanggal:', '2024-05-30'),
                    Divider(color: Colors.white),
                    buildDetailRow(
                      'Mesin:',
                      // ignore: unnecessary_null_comparison
                      order.selectedMachine != null
                          ? 'Machine ${order.selectedMachine! + 1}'
                          : 'Not selected',
                    ),
                    buildDetailRow(
                      'Paket:',
                      order.selectedPackage != null
                          ? '${order.selectedPackage! + 1}'
                          : 'Not selected',
                    ),
                    buildDetailRow(
                      'Waktu:',
                      order.selectedTimeSlot ?? 'Not selected',
                    ),
                    buildDetailRow(
                      'Tampilkan Kartu Pengiriman:',
                      '${order.showDeliveryCard}',
                    ),
                    buildDetailRow(
                      'Lokasi:',
                      order.selectedLocation ?? 'Not selected',
                    ),
                    buildDetailRow(
                      'Detail Alamat:',
                      order.address ?? 'Not available',
                    ),
                    Divider(color: Colors.white),
                    buildDetailRow('Biaya Pengiriman:',
                        order.estimatedCost.toStringAsFixed(0)),
                    buildDetailRow(
                        'Total Biaya:', order.totalCost.toStringAsFixed(0)),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QrCodeScreen(order: order),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          backgroundColor:
                              Colors.blue.shade900, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set border radius
                          ),
                        ),
                        child: Text(
                          'Bayar Via QRIS',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white), // White text color
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BankDropdown(
                                  order: order,
                                ),
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          backgroundColor:
                              Colors.blue.shade900, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Set border radius
                          ),
                        ),
                        child: Text(
                          'Bayar Via Transfer Bank',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white), // White text color
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

  Widget buildDetailRow(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Sora',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
