import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminReservationScreen extends StatefulWidget {
  const AdminReservationScreen({super.key});

  @override
  State<AdminReservationScreen> createState() => _AdminReservationScreenState();
}

class _AdminReservationScreenState extends State<AdminReservationScreen> {
  final Color _darkAdmin = const Color(0xFF1E293B); // Warna header Admin
  
  List _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  // --- AMBIL SEMUA DATA RESERVASI ---
  Future<void> _fetchReservations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/reservations'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      // Kadang struktur API membungkus data dengan ['data'] atau langsung array list
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          // Cek apakah data dibungkus dalam key 'data'
          if (responseData is Map && responseData.containsKey('data')) {
             _reservations = responseData['data'];
          } else {
             _reservations = responseData; // Jika response langsung berupa array []
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --- FUNGSI UPDATE STATUS RESERVASI ---
  Future<void> _updateStatus(int id, String newStatus) async {
    // Tampilkan loading dialog
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator())
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      // NOTE: Anda mungkin perlu menambahkan Rute PUT /api/reservations/{id}/status di Laravel nanti
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/reservations/$id/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status berhasil diubah menjadi $newStatus'), backgroundColor: Colors.green),
        );
        _fetchReservations(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui status. Pastikan API tersedia di Laravel.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: _darkAdmin,
        elevation: 0,
        title: const Text('Reservasi Masuk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final res = _reservations[index];
                    return _buildReservationCard(res);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada reservasi masuk', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildReservationCard(dynamic res) {
    String status = res['status'] ?? 'Pending';
    Color statusColor = Colors.orange;
    
    if (status.toLowerCase() == 'confirmed') statusColor = Colors.green;
    if (status.toLowerCase() == 'completed') statusColor = Colors.blue;
    if (status.toLowerCase() == 'cancelled') statusColor = Colors.red;

    // Ambil nama user (jika berelasi)
    String customerName = 'Pelanggan';
    if (res['user'] != null && res['user']['username'] != null) {
      customerName = res['user']['username'];
    }

    // Format tanggal
    String rawDate = res['reservation_date'] ?? '';
    String formattedDate = rawDate.isNotEmpty && rawDate.contains('T') ? rawDate.split('T')[0] : rawDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Nama & Status)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _darkAdmin.withOpacity(0.1),
                      child: Icon(Icons.person, color: _darkAdmin, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        Text('Order ID: #${res['id']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          
          // Body Card (Detail Reservasi)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(formattedDate, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 24),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(res['reservation_time'] ?? '-', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text('${res['guest_count'] ?? '-'} Tamu', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 24),
                    Icon(Icons.payments_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text('Rp ${res['total_price'] ?? '0'}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons (Berdasarkan Status)
          if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'confirmed')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  if (status.toLowerCase() == 'pending') ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _updateStatus(res['id'], 'Cancelled'),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _updateStatus(res['id'], 'Confirmed'),
                        child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                  if (status.toLowerCase() == 'confirmed') ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _updateStatus(res['id'], 'Completed'),
                        child: const Text('Tandai Selesai', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}