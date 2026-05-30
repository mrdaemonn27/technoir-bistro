import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'reservation_cart_screen.dart'; // Import halaman keranjang baru

class ReservationMenuScreen extends StatefulWidget {
  const ReservationMenuScreen({super.key});

  @override
  State<ReservationMenuScreen> createState() => _ReservationMenuScreenState();
}

class _ReservationMenuScreenState extends State<ReservationMenuScreen> {
  final Color _primaryOrange = const Color(0xFFFE8C00);
  final Color _lightGreen = const Color(0xFFA5E6B5);
  final Color _lightRed = const Color(0xFFFF6B6B);

  bool _isLoadingMenus = true;

  // Struktur untuk mengelompokkan menu berdasarkan Kategori (Dinamis)
  Map<String, List<dynamic>> _groupedMenus = {};

  // Keranjang khusus untuk halaman reservasi ini
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  // --- AMBIL DATA MENU DARI BACKEND LARAVEL ---
  Future<void> _fetchMenus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://10.0.2.2:8000/api/menus');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        List<dynamic> allMenus = data['data'];
        
        // Kelompokkan menu secara dinamis berdasarkan nama kategori
        Map<String, List<dynamic>> grouped = {};
        for (var menu in allMenus) {
          String categoryName = menu['category'] != null ? menu['category']['name'] : 'Others';
          if (!grouped.containsKey(categoryName)) {
            grouped[categoryName] = [];
          }
          grouped[categoryName]!.add(menu);
        }

        setState(() {
          _groupedMenus = grouped;
          _isLoadingMenus = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingMenus = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat menu')));
    }
  }

  // --- FUNGSI TAMBAH/KURANG ITEM KERANJANG ---
  void _updateQuantity(dynamic menu, int delta) {
    setState(() {
      int existingIndex = _cartItems.indexWhere((item) => item['id'] == menu['id']);
      
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['quantity'] += delta;
        if (_cartItems[existingIndex]['quantity'] <= 0) {
          _cartItems.removeAt(existingIndex);
        }
      } else if (delta > 0) {
        _cartItems.add({
          'id': menu['id'],
          'name': menu['name'],
          'price': menu['price'],
          'image': menu['image'],
          'quantity': 1,
        });
      }
    });
  }

  int _getQuantity(int menuId) {
    int existingIndex = _cartItems.indexWhere((item) => item['id'] == menuId);
    if (existingIndex >= 0) {
      return _cartItems[existingIndex]['quantity'];
    }
    return 0;
  }

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) {
      double price = double.parse(item['price'].toString());
      int qty = item['quantity'];
      return sum + (price * qty);
    });
  }

  // --- NAVIGASI KE HALAMAN CART RESERVASI ---
  void _goToReservationCart() async {
    // Kita menavigasi ke halaman cart yang baru,
    // dan menunggu hasilnya (jika user kembali, kita perbarui keranjang)
    final updatedCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationCartScreen(initialCartItems: _cartItems),
      ),
    );

    // Memperbarui state keranjang dari layar cart jika user tidak jadi submit
    if (updatedCart != null) {
      setState(() {
        _cartItems = List<Map<String, dynamic>>.from(updatedCart);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoadingMenus 
                ? Center(child: CircularProgressIndicator(color: _primaryOrange))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _groupedMenus.keys.map((categoryName) {
                        return _buildCategorySection(categoryName, _groupedMenus[categoryName]!);
                      }).toList(),
                    ),
                  ),
          ),
          if (_cartItems.isNotEmpty) _buildBottomSummary(),
        ],
      ),
    );
  }

  // --- HEADER SESUAI DESAIN ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('T', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20))),
                  Icon(Icons.wine_bar, size: 28, color: Color(0xFF5D1D20)),
                  Text('B', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20))),
                ],
              ),
              // IKON KERANJANG MENGARAH KE RESERVATION CART SCREEN
              GestureDetector(
                onTap: _goToReservationCart,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.shopping_cart, color: _primaryOrange, size: 20),
                      if (_cartItems.isNotEmpty)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              '${_cartItems.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white70, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text('Search...', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- KELOMPOK KATEGORI & GRID CARD MENU ---
  Widget _buildCategorySection(String title, List<dynamic> categoryMenus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 16),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categoryMenus.length,
          itemBuilder: (context, index) {
            final menu = categoryMenus[index];
            return _buildMenuCard(menu);
          },
        ),
      ],
    );
  }

  // --- DESAIN CARD MENU ---
  Widget _buildMenuCard(dynamic menu) {
    int qty = _getQuantity(menu['id']);

    // Logika Pintar Cek Gambar
    String? imageUrl = menu['image'];
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'http://10.0.2.2:8000/storage/$imageUrl';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Menu
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => _placeholderImg())
                : _placeholderImg(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(menu['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Rp. ${menu['price']}', style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: _primaryOrange, shape: BoxShape.circle),
                      child: const Icon(Icons.star, color: Colors.white, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // TOMBOL ADD (+) / QUANTITY (- 1 +)
                if (qty == 0)
                  GestureDetector(
                    onTap: () => _updateQuantity(menu, 1),
                    child: Container(
                      width: double.infinity,
                      height: 32,
                      decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _updateQuantity(menu, -1),
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(color: _lightRed, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.remove, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _updateQuantity(menu, 1),
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _placeholderImg() {
    return Container(height: 110, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey));
  }

  // --- BAGIAN RINGKASAN PESANAN DI BAWAH ---
  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('PESANAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          
          // Daftar pesanan yang dipilih (Maksimal 3 agar tidak terlalu panjang, jika lebih scrollable)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Column(
                children: _cartItems.map((item) {
                  double itemPrice = double.parse(item['price'].toString());
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(width: 25, child: Text('${item['quantity']}', style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                        Expanded(child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text('Rp. ${itemPrice * item['quantity']}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Total:  ', style: TextStyle(fontSize: 14, color: Colors.black87)),
              Text('Rp. $_subtotal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              onPressed: _goToReservationCart,
              child: const Text('BUAT RESERVASI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}