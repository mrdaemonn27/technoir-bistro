import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 1. Background (0.0 - 0.125)
  late Animation<double> _bgGlowAnim;

  // 2. Drop & Glass Outline (0.125 - 0.3)
  late Animation<double> _dropYAnim;
  late Animation<double> _dropOpacityAnim;
  late Animation<double> _glassOutlineAnim;

  // 3. Liquid Fill & Particles (0.3 - 0.5)
  late Animation<double> _liquidFillAnim;
  late Animation<double> _particleOpacityAnim;
  late Animation<double> _particleScaleAnim;

  // 4. Reveal T & B (0.5 - 0.675)
  late Animation<double> _tRevealAnim;
  late Animation<double> _bScaleAnim;
  late Animation<double> _bOpacityAnim;

  // 5. TECHNOIR Text (0.675 - 0.825)
  final List<Animation<double>> _technoirOpaAnims = [];
  final List<Animation<double>> _technoirSlideAnims = [];

  // 6. BISTRO & Sweep (0.825 - 1.0)
  late Animation<double> _bistroScaleAnim;
  late Animation<double> _bistroOpacityAnim;
  late Animation<double> _lightSweepAnim;

  @override
  void initState() {
    super.initState();

    // Total Durasi 4 Detik Sesuai Konsep Anda
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // 0.0 - 0.5s (0.0 - 0.125)
    _bgGlowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.125, curve: Curves.easeOut)),
    );

    // 0.5 - 1.2s (0.125 - 0.3)
    _dropYAnim = Tween<double>(begin: -60.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.125, 0.25, curve: Curves.easeInCubic)),
    );
    _dropOpacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.125, 0.28)));
    
    _glassOutlineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.30, curve: Curves.easeIn)),
    );

    // 1.2 - 2.0s (0.3 - 0.5)
    _liquidFillAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.48, curve: Curves.easeInOutCubic)),
    );
    _particleScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.55, curve: Curves.easeOutCubic)),
    );
    _particleOpacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.55)));

    // 2.0 - 2.7s (0.5 - 0.675)
    _tRevealAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.675, curve: Curves.easeOutCubic)),
    );
    _bScaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.675, curve: Curves.easeOutBack)),
    );
    _bOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.65, curve: Curves.easeIn)),
    );

    // 2.7 - 3.3s (0.675 - 0.825) TECHNOIR huruf per huruf
    for (int i = 0; i < 8; i++) {
      double start = 0.675 + (i * 0.015);
      double end = start + 0.05;
      _technoirOpaAnims.add(Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut)),
      ));
      _technoirSlideAnims.add(Tween<double>(begin: 15.0, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      ));
    }

    // 3.3 - 4.0s (0.825 - 1.0)
    _bistroScaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.825, 0.95, curve: Curves.elasticOut)),
    );
    _bistroOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.825, 0.9, curve: Curves.easeIn)),
    );
    _lightSweepAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0, curve: Curves.easeInOutCubic)),
    );

    // Mulai Animasi
    _controller.forward();

    // Pindah layar setelah 4.8 detik (memberi waktu 0.8s untuk menikmati final reveal)
    Timer(const Duration(milliseconds: 4800), () {
      _checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    bool isAdmin = prefs.getBool('is_admin') ?? false;

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      if (isAdmin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 1. BACKGROUND GLOW
              Center(
                child: Opacity(
                  opacity: _bgGlowAnim.value,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.9,
                        colors: [Color(0xFFFFF0F5), Colors.white],
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- LOGO AREA (Dengan Efek Light Sweep di atasnya) ---
                    ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(_lightSweepAnim.value - 0.5, 0),
                          end: Alignment(_lightSweepAnim.value + 0.5, 0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Efek Partikel Maroon Menyebar
                          ..._buildParticles(),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Huruf T (Reveal dari Kiri ke Kanan)
                              ClipRect(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _tRevealAnim.value,
                                  child: const Text(
                                    'T',
                                    style: TextStyle(fontSize: 85, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20), height: 1.0),
                                  ),
                                ),
                              ),
                              
                              // Gelas & Cairan Orange
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0, left: 6.0, right: 6.0),
                                child: SizedBox(
                                  width: 65,
                                  height: 70,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      // Outline Gelas Maroon Fade In
                                      Opacity(
                                        opacity: _glassOutlineAnim.value,
                                        child: const Icon(Icons.wine_bar, size: 65, color: Color(0xFF5D1D20)),
                                      ),
                                      
                                      // Cairan Oranye Naik (Fill)
                                      ClipRect(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          heightFactor: _liquidFillAnim.value,
                                          child: const Icon(Icons.wine_bar, size: 65, color: Color(0xFFFE8C00)),
                                        ),
                                      ),

                                      // Tetesan Cairan Oranye dari Atas
                                      Transform.translate(
                                        offset: Offset(0, _dropYAnim.value),
                                        child: Opacity(
                                          opacity: _dropOpacityAnim.value,
                                          child: Container(
                                            width: 8, height: 16,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFE8C00),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Huruf B (Reveal Bouncing & Fading)
                              Transform.scale(
                                scale: _bScaleAnim.value,
                                child: Opacity(
                                  opacity: _bOpacityAnim.value,
                                  child: const Text(
                                    'B',
                                    style: TextStyle(fontSize: 85, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20), height: 1.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // --- TEKS TECHNOIR (Letter by Letter) ---
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildTechnoirText(),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // --- TEKS - BISTRO - (Bouncing) ---
                    Transform.scale(
                      scale: _bistroScaleAnim.value,
                      child: Opacity(
                        opacity: _bistroOpacityAnim.value,
                        child: const Text(
                          '- B I S T R O -',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            color: Color(0xFFFE8C00),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Fungsi Helper untuk menciptakan efek partikel kilatan maroon menyebar
  List<Widget> _buildParticles() {
    List<Widget> particles = [];
    // 8 arah sebaran
    List<double> angles = [
      -math.pi/4, -3*math.pi/4, math.pi/4, 3*math.pi/4, 
      0, math.pi, math.pi/2, -math.pi/2
    ];

    for (int i = 0; i < angles.length; i++) {
      double r = _particleScaleAnim.value * 60.0; // Jarak menyebar
      double dx = r * math.cos(angles[i]);
      double dy = r * math.sin(angles[i]);

      particles.add(
        Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: _particleOpacityAnim.value,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: (i % 2 == 0) ? const Color(0xFF5D1D20) : const Color(0xFFFE8C00), // Warna maroon & orange
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFE8C00).withOpacity(0.5), blurRadius: 4),
                ]
              ),
            ),
          ),
        ),
      );
    }
    return particles;
  }

  // Fungsi Helper untuk memecah teks TECHNOIR agar muncul satu per satu
  List<Widget> _buildTechnoirText() {
    String text = "TECHNOIR";
    List<Widget> letters = [];
    
    for (int i = 0; i < text.length; i++) {
      letters.add(
        Padding(
          padding: EdgeInsets.only(right: (i == text.length - 1) ? 0 : 8.0), // Spacer huruf
          child: Transform.translate(
            offset: Offset(0, _technoirSlideAnims.isNotEmpty ? _technoirSlideAnims[i].value : 0),
            child: Opacity(
              opacity: _technoirOpaAnims.isNotEmpty ? _technoirOpaAnims[i].value : 0,
              child: Text(
                text[i],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5D1D20),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return letters;
  }
}