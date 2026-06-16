import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_screen.dart'; // Untuk kembali ke tab riwayat
import 'reservation_success_screen.dart'; // Import halaman tiket sukses
import 'payment_screen.dart'; // Import halaman pembayaran Xendit
import 'notification_helper.dart'; // Import helper notifikasi

class ReservationCartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialCartItems;

  const ReservationCartScreen({super.key, required this.initialCartItems});

  @override
  State<ReservationCartScreen> createState() => _ReservationCartScreenState();
}

class _ReservationCartScreenState extends State<ReservationCartScreen> {
  final Color _primaryOrange = const Color(0xFFFE8C00);
  final Color _lightGreen = const Color(0xFFA5E6B5);
  final Color _lightRed = const Color(0xFFFF6B6B);
  final Color _darkText = const Color(0xFF373B4D);

  late List<Map<String, dynamic>> _cartItems;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi state keranjang dengan data yang dilempar dari halaman menu
    _cartItems = List.from(widget.initialCartItems);
    // Tambahkan properti 'note' jika belum ada
    for (var item in _cartItems) {
      if (!item.containsKey('note')) {
        item['note'] = '';
      }
    }

    // --- PERBAIKAN 1: Nyalakan Mesin Notifikasi Saat Halaman Dibuka ---
    NotificationHelper.initialize();
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartItems[index]['quantity'] += delta;
      if (_cartItems[index]['quantity'] <= 0) {
        _cartItems.removeAt(index);
      }
    });
  }

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) {
      double price = double.parse(item['price'].toString());
      int qty = item['quantity'];
      return sum + (price * qty);
    });
  }

  Future<void> _submitReservation() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Keranjang kosong. Silakan pilih menu terlebih dahulu.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Ambil data form dari SharedPreferences
    String? resDate = prefs.getString('res_date');
    String? resTime = prefs.getString('res_time');
    int? resGuests = prefs.getInt('res_guests');
    String? resNotes = prefs.getString('res_notes');

    final url = Uri.parse('http://192.168.18.12:8000/api/reservations');

    // Hitung Total Asli + Pajak 11%, jadikan Integer (Bulat)
    double tax = _subtotal * 0.11;
    double finalTotal = _subtotal + tax;
    int totalBayarXendit = finalTotal
        .toInt(); // Xendit HANYA menerima angka bulat

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'reservation_date': resDate != null
              ? resDate.split('T')[0]
              : DateTime.now().toIso8601String().split('T')[0],
          'reservation_time': resTime ?? '18:00',
          'guests': resGuests != null ? '$resGuests Orang' : '2 Orang',
          'items': _cartItems,
          'notes': resNotes,
          'total_price': totalBayarXendit,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // --- PERBAIKAN 2: Munculkan Notifikasi HP Saat Sukses ---
        await NotificationHelper.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Pesanan Diterima! ⏳',
          body:
              'Reservasi Anda sedang diproses. Silakan selesaikan pembayaran.',
        );

        // --- DATA UNTUK HALAMAN TIKET ---
        String username = prefs.getString('username') ?? 'Pelanggan';
        String phone = '0812 3456 7890';

        String formattedDate = resDate != null
            ? resDate.split('T')[0]
            : DateTime.now().toIso8601String().split('T')[0];
        String formattedTime = resTime ?? '18:00';
        String timeAndDate = '$formattedTime • $formattedDate';
        String guestsStr = resGuests != null ? '$resGuests Orang' : '2 Orang';
        String finalNotes = resNotes ?? '';

        String orderId =
            '9877 ${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 9)} ${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

        // Bersihkan data sementara reservasi
        await prefs.remove('res_date');
        await prefs.remove('res_time');
        await prefs.remove('res_guests');
        await prefs.remove('res_notes');

        if (!mounted) return;

        // LOGIKA PEMBAYARAN XENDIT
        String? invoiceUrl = data['invoice_url'];

        if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                invoiceUrl: invoiceUrl,
                name: username,
                phone: phone,
                dateTime: timeAndDate,
                guests: guestsStr,
                notes: finalNotes,
                orderId: orderId,
              ),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Sistem Xendit menolak permintaan. Cek API Key di Laravel.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal membuat reservasi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showNoteDialog(int index) {
    TextEditingController noteController = TextEditingController(
      text: _cartItems[index]['note'],
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: 'Spicy, no onion, etc.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
            onPressed: () {
              setState(() {
                _cartItems[index]['note'] = noteController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_cartItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.remove_shopping_cart,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cart is empty',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._cartItems
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildCartItemCard(entry.key, entry.value),
                        )
                        .toList(),

                  const SizedBox(height: 30),
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_cartItems.isNotEmpty) _buildPaymentDetails(),

                  const SizedBox(height: 40),

                  // Tombol Final Buat Reservasi
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _isSubmitting || _cartItems.isEmpty
                          ? null
                          : _submitReservation,
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'BUAT RESERVASI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context, _cartItems);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'T',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5D1D20),
                ),
              ),
              Icon(Icons.wine_bar, size: 28, color: Color(0xFF5D1D20)),
              Text(
                'B',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5D1D20),
                ),
              ),
            ],
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(int index, Map<String, dynamic> item) {
    String? imageUrl = item['image'];
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http')) {
      imageUrl = 'http://192.168.18.12:8000/storage/$imageUrl';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp. ${item['price']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _placeholderImg(),
                      )
                    : _placeholderImg(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showNoteDialog(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        item['note'] != null &&
                                item['note'].toString().isNotEmpty
                            ? 'Edit Note'
                            : 'Note',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _updateQuantity(index, -1),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: _lightRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${item['quantity']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _updateQuantity(index, 1),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (item['note'] != null && item['note'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.speaker_notes, size: 12, color: _primaryOrange),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Note: ${item['note']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
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

  Widget _placeholderImg() {
    return Container(
      width: 80,
      height: 60,
      color: Colors.grey[200],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }

  Widget _buildPaymentDetails() {
    double tax = _subtotal * 0.11;
    double total = _subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Order',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ..._cartItems.map((item) {
            double itemPrice = double.parse(item['price'].toString());
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                    child: Text(
                      '${item['quantity']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Rp. ${itemPrice * item['quantity']}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                'Rp. $_subtotal',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tax (11%):',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                'Rp. $tax',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Rp. $total',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
