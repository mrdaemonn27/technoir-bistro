import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'reservation_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String invoiceUrl;
  
  // Data ini dibawa untuk diteruskan ke halaman tiket sukses
  final String name;
  final String phone;
  final String dateTime;
  final String guests;
  final String notes;
  final String orderId;

  const PaymentScreen({
    super.key,
    required this.invoiceUrl,
    required this.name,
    required this.phone,
    required this.dateTime,
    required this.guests,
    required this.notes,
    required this.orderId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // DETEKSI JIKA URL ADALAH URL SUKSES YANG DISET DI LARAVEL
            if (request.url.startsWith('https://technoirbistro.com/success')) {
              // Pembayaran Berhasil! Langsung arahkan ke halaman Tiket
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationSuccessScreen(
                    name: widget.name,
                    phone: widget.phone,
                    dateTime: widget.dateTime,
                    guests: widget.guests,
                    notes: widget.notes,
                    orderId: widget.orderId,
                  ),
                ),
              );
              return NavigationDecision.prevent;
            }
            // Jika user membatalkan / gagal
            if (request.url.startsWith('https://technoirbistro.com/failure')) {
              Navigator.pop(context); // Kembali ke cart
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pembayaran Dibatalkan'), backgroundColor: Colors.red),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.invoiceUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran (Xendit)', style: TextStyle(color: Colors.black87, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context), // Kembali jika batal
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFE8C00)),
            ),
        ],
      ),
    );
  }
}