import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'user_screen.dart'; // <-- TAMBAHKAN IMPORT INI

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final int _selectedIndex = 2; // Index 2 untuk Cart

  List<Map<String, dynamic>> cartItems = [];
  bool _isLoadingCart = true;
  bool _isSubmitting = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedGuests = '2 People';
  final List<String> guestOptions = ['1 Person', '2 People', '3 People', '4 People', '5+ People'];

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // 1. FUNGSI MENGAMBIL DATA KERANJANG DINAMIS DARI MEMORI HP
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

  // 2. FUNGSI MENYIMPAN PERUBAHAN JUMLAH (QTY) KE MEMORI HP
  Future<void> _updateQuantity(int index, int delta) async {
    setState(() {
      cartItems[index]['quantity'] += delta;
      if (cartItems[index]['quantity'] <= 0) {
        cartItems.removeAt(index); // Hapus jika jumlahnya 0
      }
    });
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(cartItems));
  }

  // 3. FUNGSI PEMILIH TANGGAL (DATE PICKER)
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Maksimal booking 30 hari ke depan
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF282A45)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // 4. FUNGSI PEMILIH WAKTU (TIME PICKER)
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF282A45)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  // 5. FUNGSI KIRIM DATA KE LARAVEL (CHECKOUT)
  Future<void> _submitBooking() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Tanggal dan Waktu reservasi terlebih dahulu!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang Anda masih kosong!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Nanti Anda harus membuat endpoint POST /api/reservations di Laravel
    final url = Uri.parse('http://10.0.2.2:8000/api/reservations');

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
          'reservation_time': '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
          'guests': selectedGuests,
          'items': cartItems, // Mengirim data makanan yang dipesan
          'total_price': subtotal + (subtotal * 0.11),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Kosongkan keranjang setelah berhasil
        await prefs.remove('cart');
        setState(() => cartItems.clear());

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Berhasil! Menunggu konfirmasi admin.'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal melakukan booking'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Belum ada API Backend: $e'), backgroundColor: Colors.orange),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) {
      double price = double.parse(item['price'].toString());
      int qty = item['quantity'] as int;
      return sum + (price * qty);
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
    } else if (index == 3) {
      // <-- PERBAIKAN: Menambahkan rute ke UserScreen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Your Order',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: _isLoadingCart
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. BAGIAN RESERVASI MEJA
                  const Text('Table Reservation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  _buildReservationForm(),
                  const SizedBox(height: 30),

                  // 2. BAGIAN PRE-ORDER MENU
                  const Text('Pre-ordered Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  
                  if (cartItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          const Icon(Icons.remove_shopping_cart, size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => _onItemTapped(1), 
                            child: const Text('Lihat Menu', style: TextStyle(color: Color(0xFF2C74B3)))
                          )
                        ],
                      ),
                    )
                  else
                    ...cartItems.asMap().entries.map((entry) => _buildCartItem(entry.key, entry.value)).toList(),
                  
                  const SizedBox(height: 20),

                  // 3. BAGIAN RINGKASAN PEMBAYARAN
                  if (cartItems.isNotEmpty) _buildPaymentSummary(),
                  const SizedBox(height: 30),

                  // 4. TOMBOL BOOKING
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF282A45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        shadowColor: const Color(0xFF282A45).withOpacity(0.5),
                      ),
                      onPressed: _isSubmitting ? null : _submitBooking,
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'CONFIRM BOOKING',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- KOMPONEN FORM RESERVASI ---
  Widget _buildReservationForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pemilih Tanggal Dinamis
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(context),
                  child: _buildBox(
                    Icons.calendar_month, 
                    selectedDate == null ? 'Select Date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Pemilih Waktu Dinamis
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(context),
                  child: _buildBox(
                    Icons.access_time, 
                    selectedTime == null ? 'Select Time' : '${selectedTime!.hour.toString().padLeft(2,'0')}:${selectedTime!.minute.toString().padLeft(2,'0')}'
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dropdown Jumlah Tamu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedGuests,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                items: guestOptions.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(value, style: const TextStyle(fontSize: 14)),
                    ],
                  ));
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedGuests = value!);
                },
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
      decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // --- KOMPONEN ITEM KERANJANG ---
  Widget _buildCartItem(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item['image'] != null 
              ? Image.network(item['image'], width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.fastfood, size: 40))
              : Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('Rp ${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C74B3))),
              ],
            ),
          ),
          Row(
            children: [
              _buildQtyBtn(Icons.remove, () => _updateQuantity(index, -1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildQtyBtn(Icons.add, () => _updateQuantity(index, 1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  // --- KOMPONEN RINGKASAN PEMBAYARAN ---
  Widget _buildPaymentSummary() {
    double tax = subtotal * 0.11; // PPN 11%
    double total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', 'Rp $subtotal'),
          const SizedBox(height: 12),
          _summaryRow('Tax & Service (11%)', 'Rp $tax'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Rp $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF282A45))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  // --- KOMPONEN BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.restaurant_menu, 'Menu', 1),
              _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2),
              _buildNavItem(Icons.person_outline, 'User', 3),
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
          Icon(icon, color: isSelected ? const Color(0xFF2C74B3) : Colors.grey[500], size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2C74B3) : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}