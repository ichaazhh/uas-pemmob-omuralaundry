import 'dart:convert'; // Untuk mengkonversi data JSON
import 'package:flutter/material.dart'; // Paket utama Flutter untuk membangun UI
import 'package:flutter/services.dart'
    show rootBundle; // Untuk mengakses asset bundle
import 'package:cloud_firestore/cloud_firestore.dart'; // Paket untuk Firestore
import 'package:intl/intl.dart'; // Paket untuk format tanggal dan angka
import 'package:material_dialogs/material_dialogs.dart'; // Paket untuk menampilkan dialog material
import 'package:material_dialogs/widgets/buttons/icon_button.dart'; // Paket untuk menampilkan tombol ikon dalam dialog
import 'package:shared_preferences/shared_preferences.dart'; // Paket untuk penyimpanan preferensi bersama
import 'dart:async'; // Paket untuk menggunakan asinkron
import 'package:lottie/lottie.dart'; // Paket untuk animasi Lottie
import 'package:uas/app/home.dart'; // Impor layar beranda
import 'package:uas/entity/order_item.dart'; // Impor model order item

void main() {
  runApp(MyApp()); // Menjalankan aplikasi
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(); // Menginisialisasi MaterialApp
  }
}

class Bank {
  final String code; // Kode bank
  final String name; // Nama bank

  Bank({required this.code, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      code: json['code'], // Mengambil kode bank dari JSON
      name: json['name'], // Mengambil nama bank dari JSON
    );
  }
}

class BankDropdown extends StatefulWidget {
  final OrderItem order; // Item order yang diterima dari layar sebelumnya

  BankDropdown({required this.order});

  @override
  _BankDropdownState createState() => _BankDropdownState();
}

class _BankDropdownState extends State<BankDropdown> {
  List<Bank> _banks = []; // Daftar bank
  String? _selectedBankCode; // Kode bank yang dipilih
  String phoneNumber = ''; // Nomor telepon
  String virtualAccountNumber = ''; // Nomor rekening virtual
  final _formKey = GlobalKey<FormState>(); // Kunci form
  final _payerNameController =
      TextEditingController(); // Controller untuk nama pembayar
  late final _amountController =
      TextEditingController(); // Controller untuk jumlah pembayaran

  @override
  void initState() {
    super.initState();
    loadBanks(); // Memuat daftar bank
    fetchUsernameFromPreferences(); // Mengambil username dari preferensi
    _loadUserData(); // Memuat data pengguna
    _amountController.text = widget.order.totalCost
        .toStringAsFixed(0); // Mengatur nilai awal dari total biaya
  }

  Future<void> fetchUsernameFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    if (username.isNotEmpty) {
      fetchUsernameFromFirestore(username); // Mengambil username dari Firestore
    }
  }

  Future<void> fetchUsernameFromFirestore(String username) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userSnapshot.docs.first;
        setState(() {
          _payerNameController.text =
              userDoc['username']; // Mengatur nama pembayar
          phoneNumber = userDoc['phone_number']; // Mengatur nomor telepon
        });
      }
    } catch (e) {
      print(
          'Error fetching username: $e'); // Menampilkan error jika gagal mengambil username
    }
  }

  Future<void> loadBanks() async {
    String jsonData = await rootBundle.loadString('assets/indonesia-bank.json');
    List<dynamic> bankList = jsonDecode(jsonData);

    setState(() {
      _banks = bankList
          .map((json) => Bank.fromJson(json))
          .toList(); // Mengubah data JSON menjadi daftar bank
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString('phone_number') ??
          ''; // Mengambil nomor telepon dari preferensi
    });
  }

  void _generateVirtualAccountNumber() {
    if (_selectedBankCode != null && phoneNumber.isNotEmpty) {
      setState(() {
        virtualAccountNumber = _selectedBankCode! +
            phoneNumber; // Menggabungkan kode bank dan nomor telepon
      });
    }
  }

  void _submitPayment(BuildContext context) {
    if (_formKey.currentState!.validate() && _selectedBankCode != null) {
      print('Payer Name: ${_payerNameController.text}');
      print('Amount: ${_amountController.text}');
      print('Selected Bank: $_selectedBankCode');
      print('Virtual Account Number: $virtualAccountNumber');

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
                  username: _payerNameController.text, // Mengirim username
                  amountPaid:
                      _amountController.text, // Mengirim jumlah pembayaran
                  order: widget.order, // Mengirim order
                )),
      );
    } else {
      print('Wajib diisi'); // Menampilkan pesan jika form belum lengkap
    }
  }

  Widget _buildTextFormField(String label, TextEditingController controller,
      {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: "Masukkan $label",
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
              return 'Masukkan $label'; // Validasi jika field kosong
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Pilih Bank',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              filled: true,
              fillColor: Colors.white,
            ),
            isExpanded: true,
            value: _selectedBankCode,
            onChanged: (String? newValue) {
              setState(() {
                _selectedBankCode = newValue; // Mengubah kode bank yang dipilih
                _generateVirtualAccountNumber(); // Menghasilkan nomor rekening virtual
              });
            },
            items: _banks.map((Bank bank) {
              return DropdownMenuItem<String>(
                value: bank.code,
                child: Text(
                  bank.name,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Pilih Bank'; // Validasi jika bank belum dipilih
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomor Virtual Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade900),
          ),
          child: Text(
            virtualAccountNumber,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
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
        centerTitle: true, // Pusatkan judul AppBar
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
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
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildTextFormField(
                                "Nama Pemilik Rekening", _payerNameController),
                            SizedBox(height: 20),
                            _buildTextFormField(
                                "Jumlah dibayar", _amountController),
                            SizedBox(height: 20),
                            _buildDropdownField("Bank"),
                            SizedBox(height: 20),
                            _buildVirtualAccountField(), // Menampilkan nomor virtual account
                            SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                height: 50,
                                width: 250, // Sesuaikan lebar tombol
                                child: ElevatedButton(
                                  onPressed: () => _submitPayment(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade900,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: Text(
                                    'Bayar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentSuccessScreen extends StatefulWidget {
  final String amountPaid; // Jumlah yang dibayar
  final String username; // Nama pengguna
  final OrderItem order; // Detail pesanan

  PaymentSuccessScreen(
      {required this.amountPaid, required this.username, required this.order});

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String email = ''; // Email pengguna
  String transactionDate = ''; // Tanggal transaksi

  @override
  void initState() {
    super.initState();
    fetchEmailAndTransactionDate(); // Ambil email dan tanggal transaksi
  }

  Future<void> fetchEmailAndTransactionDate() async {
    await fetchEmailFromFirestore(); // Ambil email dari Firestore
    updateTransactionDate(); // Update tanggal transaksi
  }

  Future<void> fetchEmailFromFirestore() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userSnapshot.docs.first;
        setState(() {
          email = userDoc['email']; // Mengambil email pengguna
        });
      }
    } catch (e) {
      print('Error fetching email from Firestore: $e');
    }
  }

  void updateTransactionDate() {
    DateTime now = DateTime.now();
    transactionDate = DateFormat('dd MMMM yyyy, hh:mm a')
        .format(now); // Format tanggal transaksi
    setState(() {}); // Update state untuk menampilkan tanggal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle,
                  color: Colors.green, size: 50), // Icon tanda centang hijau
              SizedBox(height: 10),
              Text(
                'Terima Kasih!', // Pesan terima kasih
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Transaksi Kamu Berhasil', // Pesan transaksi berhasil
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              buildTransactionDetailRow('TANGGAL & JAM',
                  transactionDate), // Menampilkan detail tanggal transaksi
              buildTransactionDetailRow('JUMLAH',
                  widget.amountPaid), // Menampilkan detail jumlah yang dibayar
              buildTransactionDetailRow(
                  'DARI', widget.username), // Menampilkan detail nama pengguna
              buildTransactionDetailRow(
                  'EMAIL', email), // Menampilkan detail email pengguna
              buildTransactionDetailRow(
                  'STATUS', 'Terkirim'), // Menampilkan status terkirim
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Perbarui dokumen Firestore
                        await FirebaseFirestore.instance
                            .collection('histories')
                            .where('invoice',
                                isEqualTo: widget
                                    .order.invoice) // Akses invoice dari order
                            .get()
                            .then((querySnapshot) {
                          querySnapshot.docs.forEach((doc) async {
                            await FirebaseFirestore.instance
                                .collection('histories')
                                .doc(doc.id)
                                .update({'progress': 3, "status": "Diproses"});
                          });
                        });

                        // Tampilkan dialog sukses
                        Dialogs.materialDialog(
                          color: Colors.white,
                          msg:
                              'Terima kasih telah menggunakan layanan Omura Laundry', // Pesan sukses
                          title: 'Pembayaran Sukses!', // Judul sukses
                          lottieBuilder: Lottie.asset(
                            'assets/success.json',
                            fit: BoxFit.contain,
                          ),
                          context: context,
                          msgAlign: TextAlign
                              .center, // Tambahkan setting untuk mengatur teks rata tengah
                          actions: [
                            IconsButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()),
                                );
                              },
                              text: 'Close', // Tombol tutup
                              iconData: Icons.done, // Icon centang
                              color: Colors.blue,
                              textStyle: TextStyle(color: Colors.white),
                              iconColor: Colors.white,
                            ),
                          ],
                        );
                      } catch (e) {
                        print('Error updating document: $e');
                        // Tangani error, mungkin tampilkan dialog error
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTransactionDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(value), // Menampilkan nilai dari label
        ],
      ),
    );
  }
}
