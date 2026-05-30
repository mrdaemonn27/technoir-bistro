import 'package:flutter/material.dart';
import 'home_screen.dart';

class ReservationSuccessScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String dateTime;
  final String guests;
  final String notes;
  final String orderId;

  const ReservationSuccessScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.dateTime,
    required this.guests,
    required this.notes,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF68B29), // Background Oranye
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER TERIMAKASIH ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text('TERIMAKASIH', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            // --- KARTU TIKET ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bagian Atas Tiket
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
                              width: 80, height: 80, fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Technoir Bistro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text('Jalur Gaza, Pochinki, no.67', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    const Divider(height: 1, thickness: 1, color: Colors.black12),
                    
                    // Detail Pemesan
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildDetailRow('Nama:', name),
                          const SizedBox(height: 16),
                          _buildDetailRow('Nomor Telp:', phone),
                          const SizedBox(height: 16),
                          _buildDetailRow('Waktu:', dateTime),
                          const SizedBox(height: 16),
                          _buildDetailRow('Pengunjung:', guests),
                          
                          if (notes.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Text(notes, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                            )
                          ]
                        ],
                      ),
                    ),

                    // Garis Putus-putus dengan Potongan Bulat (Seperti Karcis Nyata)
                    SizedBox(
                      height: 30,
                      child: Stack(
                        children: [
                          Center(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: List.generate(
                                    (constraints.constrainWidth() / 10).floor(),
                                    (index) => const SizedBox(
                                      width: 5,
                                      height: 1.5,
                                      child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
                                    )
                                  ),
                                );
                              }
                            )
                          ),
                          Positioned(
                            left: -15,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 30,
                              decoration: const BoxDecoration(color: Color(0xFFF68B29), shape: BoxShape.circle),
                            )
                          ),
                          Positioned(
                            right: -15,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 30,
                              decoration: const BoxDecoration(color: Color(0xFFF68B29), shape: BoxShape.circle),
                            )
                          ),
                        ],
                      ),
                    ),

                    // Bagian Bawah (Barcode)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Image.network(
                            'https://barcode.tec-it.com/barcode.ashx?data=$orderId&code=Code128&translate-esc=true', 
                            height: 70, 
                            fit: BoxFit.fill, 
                            errorBuilder: (c,e,s) => const Icon(Icons.qr_code, size: 70)
                          ),
                          const SizedBox(height: 12),
                          Text('Order ID: $orderId', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // --- TOMBOL KEMBALI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                  },
                  child: const Text('Kembali', style: TextStyle(color: Color(0xFFF68B29), fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
      ],
    );
  }
}