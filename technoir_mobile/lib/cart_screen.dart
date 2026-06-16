import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'user_screen.dart';
import 'payment_screen.dart';
import 'reservation_success_screen.dart';
import 'reservation_form_screen.dart'; // <-- PERBAIKAN: Import halaman Form Reservasi dikembalikan

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final int _selectedIndex = 1; // Index 1 untuk Reservation/Cart di desain baru

  // --- VARIABEL CART (TAB MENDATANG) ---
  List<Map<String, dynamic>> cartItems = [];
  bool _isLoadingCart = true;
  bool _isSubmitting = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedGuests = '2 People';
  final List<String> guestOptions = [
    '1 Person',
    '2 People',
    '3 People',
    '4 People',
    '5+ People',
  ];

  // --- VARIABEL HISTORY (TAB RIWAYAT) ---
  List<dynamic> _historyItems = [];
  bool _isLoadingHistory = true;

  // --- KONTROL TAB ---
  int _currentTab = 0; // 0 = Mendatang, 1 = Riwayat
  final Color _primaryOrange = const Color(0xFFFE8C00);

  @override
  void initState() {
    super.initState();
    _loadCartData();
    _fetchHistory();
  }

  // ===========================================================================
  // FUNGSI LOGIKA DATA DINAMIS
  // ===========================================================================

  Future<void> _loadCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartString = prefs.getString('cart');

    if (cartString != null) {
      setState(() {
        cartItems = List<Map<String, dynamic>>.from(json.decode(cartString));
      });
    }
    setState(() => _isLoadingCart = false);
  }

  Future<void> _updateQuantity(int index, int delta) async {
    setState(() {
      cartItems[index]['quantity'] += delta;
      if (cartItems[index]['quantity'] <= 0) {
        cartItems.removeAt(index);
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(cartItems));
  }

  Future<void> _fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://192.168.18.12:8000/api/reservations/history');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _historyItems = data['data'];
          _isLoadingHistory = false;
        });
      } else {
        setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _submitBooking() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Tanggal dan Waktu reservasi terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://192.168.18.12:8000/api/reservations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'reservation_date': selectedDate!.toIso8601String().split('T')[0],
          'reservation_time':
              '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
          'guests': selectedGuests,
          'items': cartItems,
          'total_price': subtotal + (subtotal * 0.11),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // --- PERBAIKAN: LOGIKA PEMBAYARAN XENDIT ---
        // Siapkan data untuk halaman tiket
        String username = prefs.getString('username') ?? 'Pelanggan';
        String phone = '0812 3456 7890';
        String formattedDate = selectedDate!.toIso8601String().split('T')[0];
        String formattedTime =
            '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
        String timeAndDate = '$formattedTime • $formattedDate';
        String guestsStr = selectedGuests;
        String finalNotes = '';
        String orderId =
            '9877 ${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 9)} ${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

        // Kosongkan keranjang
        await prefs.remove('cart');
        setState(() {
          cartItems.clear();
        });

        if (!mounted) return;

        String? invoiceUrl = data['invoice_url'];

        // Cek jika Xendit memberikan URL
        if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
          // Buka Halaman WebView Xendit
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
          // Jika tidak ada URL (Fallback), langsung ke halaman Sukses
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationSuccessScreen(
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
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal melakukan booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.orange),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) {
      double price = double.parse(item['price'].toString());
      int qty = item['quantity'] as int;
      return sum + (price * qty);
    });
  }

  // ===========================================================================
  // ANTARMUKA PENGGUNA (UI)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // HEADER MELENGKUNG ORANYE
          _buildOrangeHeader(),

          // TAB CONTROL (MENDATANG vs RIWAYAT)
          _buildCustomTabs(),

          // KONTEN UTAMA DINAMIS
          Expanded(
            child: _currentTab == 0 ? _buildUpcomingTab() : _buildHistoryTab(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- HEADER ORANYE ---
  Widget _buildOrangeHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          // Logo TB
          Row(
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
        ],
      ),
    );
  }

  // --- CUSTOM TABS ---
  Widget _buildCustomTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: _currentTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : [],
                  border: _currentTab == 0
                      ? Border.all(color: _primaryOrange.withOpacity(0.3))
                      : null,
                ),
                child: Center(
                  child: Text(
                    'MENDATANG',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _currentTab == 0
                          ? _primaryOrange
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: _currentTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : [],
                  border: _currentTab == 1
                      ? Border.all(color: _primaryOrange.withOpacity(0.3))
                      : null,
                ),
                child: Center(
                  child: Text(
                    'RIWAYAT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _currentTab == 1
                          ? _primaryOrange
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // KONTEN TAB 0: MENDATANG (EMPTY STATE & ISI KERANJANG)
  // ===========================================================================
  Widget _buildUpcomingTab() {
    if (_isLoadingCart) {
      return Center(child: CircularProgressIndicator(color: _primaryOrange));
    }

    if (cartItems.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.edit_calendar, size: 80, color: Colors.blue[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Reservasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Silakan pilih menu dan tentukan jadwal kedatangan Anda untuk membuat reservasi meja.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ),
          const Spacer(),
          // --- PERBAIKAN: Tombol Buat Reservasi Dikembalikan ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: _primaryOrange.withOpacity(0.5),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReservationFormScreen(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BUAT RESERVASI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Reservasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildReservationForm(),
          const SizedBox(height: 30),

          const Text(
            'Menu Dipesan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...cartItems
              .asMap()
              .entries
              .map((entry) => _buildCartItem(entry.key, entry.value))
              .toList(),
          const SizedBox(height: 20),

          _buildPaymentSummary(),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                shadowColor: _primaryOrange.withOpacity(0.5),
              ),
              onPressed: _isSubmitting ? null : _submitBooking,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'KONFIRMASI BOOKING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ===========================================================================
  // KONTEN TAB 1: RIWAYAT (DATA DINAMIS)
  // ===========================================================================
  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return Center(child: CircularProgressIndicator(color: _primaryOrange));
    }

    if (_historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat pesanan',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _historyItems.length,
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        Color statusColor = Colors.orange;
        String status = item['status'] ?? 'Pending';

        if (status.toLowerCase() == 'confirmed' ||
            status.toLowerCase() == 'completed') {
          statusColor = Colors.green;
        } else if (status.toLowerCase() == 'cancelled') {
          statusColor = Colors.red;
        }

        String rawDate = item['reservation_date'] ?? '';
        String formattedDate = rawDate.isNotEmpty && rawDate.contains('T')
            ? rawDate.split('T')[0]
            : rawDate;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: $formattedDate',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    item['reservation_time'] ?? '-',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    '${item['guest_count'] ?? '-'} Tamu',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // SUB-KOMPONEN FORM RESERVASI
  // ===========================================================================
  Widget _buildReservationForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: _buildBox(
                    Icons.calendar_month,
                    selectedDate == null
                        ? 'Pilih Tanggal'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 18, minute: 0),
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                  child: _buildBox(
                    Icons.access_time,
                    selectedTime == null
                        ? 'Pilih Waktu'
                        : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedGuests,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                items: guestOptions
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(value, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedGuests = value!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index, Map<String, dynamic> item) {
    String? imageUrl = item['image'];
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http')) {
      imageUrl = 'http://192.168.18.12:8000/storage/$imageUrl';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${item['price']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _updateQuantity(index, -1),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 18, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    double tax = subtotal * 0.11;
    double total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                'Rp $subtotal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax & Service (11%)',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                'Rp $tax',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Rp $total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM NAVIGATION
  // ===========================================================================
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      // Tetap di sini (Reservation)
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserScreen()),
      );
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.explore, 'Explore', 0),
              _buildNavItem(Icons.calendar_today_outlined, 'Reservation', 1),
              _buildNavItem(Icons.restaurant_menu, 'Menu', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? _primaryOrange : Colors.grey[400],
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _primaryOrange : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
