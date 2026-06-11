import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final Color _primaryOrange = const Color(0xFFFE8C00);

  bool _isLoading = true;
  double _totalRevenue = 0;
  int _totalTransactions = 0;
  List _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/reports'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        setState(() {
          _totalRevenue = double.parse(data['total_revenue'].toString());
          _totalTransactions = data['total_transactions'] ?? 0;
          _recentTransactions = data['recent_transactions'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data laporan')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // --- HEADER MELENGKUNG ORANYE ---
          _buildOrangeHeader(),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryOrange))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- KARTU PENDAPATAN TOTAL (HERO CARD) ---
                        _buildHeroCard(),
                        const SizedBox(height: 24),

                        // --- KARTU RINGKASAN HARIAN ---
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniCard(
                                title: 'Total Transaksi',
                                icon: Icons.shopping_bag,
                                iconBgColor: const Color(0xFF42A5F5),
                                percentageText: '+6,7%',
                                percentageColor: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMiniCard(
                                title: 'Reservasi Selesai',
                                icon: Icons.table_restaurant,
                                iconBgColor: const Color(0xFF66BB6A),
                                percentageText: '+9,1%',
                                percentageColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- DAFTAR TRANSAKSI TERBARU ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Transaksi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Row(
                                      children: [
                                        Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryOrange)),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_ios, size: 12, color: _primaryOrange),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (_recentTransactions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(child: Text('Belum ada transaksi selesai.', style: TextStyle(color: Colors.grey))),
                                )
                              else
                                ..._recentTransactions.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  var trx = entry.value;
                                  return _buildTransactionItem(trx, idx == _recentTransactions.length - 1);
                                }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN HEADER ORANYE ---
  Widget _buildOrangeHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15, 
        left: 24, 
        right: 24, 
        bottom: 30
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
              child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN HERO CARD PENDAPATAN ---
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9A2A), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _primaryOrange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Total Pendapatan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(_totalRevenue),
            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_outward, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('+15,5%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('dari bulan lalu', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN KARTU KECIL ---
  Widget _buildMiniCard({required String title, required IconData icon, required Color iconBgColor, required String percentageText, required Color percentageColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: percentageColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_outward, color: percentageColor, size: 12),
                    const SizedBox(width: 2),
                    Text(percentageText, style: TextStyle(color: percentageColor, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('dari bulan lalu', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN ITEM TRANSAKSI ---
  Widget _buildTransactionItem(dynamic trx, bool isLast) {
    // Alternate icon for dummy visual
    bool isRestaurant = trx['id'] % 2 == 0;
    IconData iconData = isRestaurant ? Icons.restaurant : Icons.shopping_cart_outlined;
    Color iconColor = isRestaurant ? Colors.blue : _primaryOrange;
    Color iconBgColor = isRestaurant ? Colors.blue.withOpacity(0.1) : _primaryOrange.withOpacity(0.1);

    String date = trx['updated_at'] ?? '';
    String formattedDate = date.isNotEmpty && date.contains('T') ? date.split('T')[0] : date;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pemesanan Meja #${trx['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('$formattedDate - 20:00', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(double.parse(trx['total_price'].toString())),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Selesai', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey.shade200, height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}