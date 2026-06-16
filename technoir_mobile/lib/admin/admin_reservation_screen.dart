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
  final Color _primaryOrange = const Color(0xFFFE8C00);
  final Color _darkText = const Color(
    0xFF373B4D,
  ); // Warna teks biru gelap (sesuai UI)

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
        Uri.parse('http://192.168.18.12:8000/api/reservations'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          if (responseData is Map && responseData.containsKey('data')) {
            _reservations = responseData['data'];
          } else {
            _reservations = responseData;
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
        SnackBar(
          content: Text('Gagal terhubung ke server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- FUNGSI UPDATE STATUS RESERVASI ---
  Future<void> _updateStatus(int id, String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.put(
        Uri.parse('http://192.168.18.12:8000/api/reservations/$id/status'),
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
          SnackBar(
            content: Text('Status berhasil diubah menjadi $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchReservations(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal memperbarui status. Pastikan API tersedia di Laravel.',
            ),
            backgroundColor: Colors.red,
          ),
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER MELENGKUNG ORANYE ---
          _buildOrangeHeader(),

          // --- TITLE ---
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
            child: Text(
              'Reservasi masuk',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
          ),

          // --- LIST RESERVASI ---
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: _primaryOrange),
                  )
                : _reservations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final res = _reservations[index];
                      return _buildReservationCard(res);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN HEADER ORANYE ---
  Widget _buildOrangeHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        left: 24,
        right: 24,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
        ],
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
          Text(
            'Belum ada reservasi masuk',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN KARTU RESERVASI ---
  Widget _buildReservationCard(dynamic res) {
    String status = res['status'] ?? 'Pending';
    Color statusColor = Colors.orange;
    String statusText = 'Pending';

    if (status.toLowerCase() == 'confirmed') {
      statusColor = const Color(0xFF4CAF50); // Hijau
      statusText = 'Dikonfirmasi';
    } else if (status.toLowerCase() == 'completed') {
      statusColor = const Color(0xFF4CAF50); // Hijau
      statusText = 'Selesai';
    } else if (status.toLowerCase() == 'cancelled') {
      statusColor = const Color(0xFFFF6B6B); // Merah
      statusText = 'Dibatalkan';
    }

    // Ambil nama user (jika berelasi)
    String customerName = 'Pelanggan';
    if (res['user'] != null && res['user']['username'] != null) {
      customerName = res['user']['username'];
    }

    // Format tanggal
    String rawDate = res['reservation_date'] ?? '';
    String formattedDate = rawDate.isNotEmpty && rawDate.contains('T')
        ? rawDate.split('T')[0]
        : rawDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Info User & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order ID: #${res['id']}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: Colors.grey.shade200,
              height: 1,
              thickness: 1.5,
            ),
          ),

          // Row 2: Detail Reservasi (2 Kolom)
          Row(
            children: [
              // Kolom Kiri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          '${res['guest_count'] ?? '-'} Tamu',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Kolom Kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          res['reservation_time'] ?? '-',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rp ${res['total_price'] ?? '0'}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Notes (Jika Ada)
          if (res['notes'] != null && res['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Notes: ${res['notes']}',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // Row 3: Tombol Aksi (Tolak & Konfirmasi)
          if (status.toLowerCase() == 'pending' ||
              status.toLowerCase() == 'confirmed') ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Divider(
                color: Colors.grey.shade200,
                height: 1,
                thickness: 1.5,
              ),
            ),
            Row(
              children: [
                if (status.toLowerCase() == 'pending') ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B6B),
                        side: const BorderSide(
                          color: Color(0xFFFF6B6B),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _updateStatus(res['id'], 'Cancelled'),
                      child: const Text(
                        'Tolak',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => _updateStatus(res['id'], 'Confirmed'),
                      child: const Text(
                        'Konfirmasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                if (status.toLowerCase() == 'confirmed') ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () => _updateStatus(res['id'], 'Completed'),
                      child: const Text(
                        'Tandai Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
