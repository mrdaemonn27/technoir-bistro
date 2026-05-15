import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Endpoint API untuk mengambil riwayat
    final url = Uri.parse('http://10.0.2.2:8000/api/reservations/history');

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
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal memuat riwayat'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order History',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF282A45)))
          : _historyItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) {
                    final item = _historyItems[index];
                    return _buildHistoryCard(item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada riwayat pesanan', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    // Menentukan warna berdasarkan status pesanan
    Color statusColor = Colors.orange;
    String status = item['status'] ?? 'Pending';
    
    if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'completed') {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == 'cancelled') {
      statusColor = Colors.red;
    }

    // --- PERBAIKAN: Memformat format tanggal yang kepanjangan ---
    String rawDate = item['reservation_date'] ?? '';
    String formattedDate = rawDate.isNotEmpty && rawDate.contains('T') 
        ? rawDate.split('T')[0] // Potong bagian "T00:00:00..."
        : rawDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- PERBAIKAN: Bungkus dengan Expanded agar tidak overflow ---
              Expanded(
                child: Text(
                  'Tanggal: $formattedDate',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
                  overflow: TextOverflow.ellipsis, // Jika mentok, ubah jadi titik-titik
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8), // Jarak antara tanggal dan status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
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
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(item['reservation_time'] ?? '-', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              
              const SizedBox(width: 16),
              
              Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text('${item['guest_count'] ?? '-'} Tamu', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}