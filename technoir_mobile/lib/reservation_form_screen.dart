import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reservation_menu_screen.dart'; 

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final Color _primaryOrange = const Color(0xFFFE8C00);
  
  // --- VARIABEL TANGGAL DINAMIS ---
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> _dateList;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Controller Scroll untuk otomatis menggeser kalender
  final ScrollController _dateScrollController = ScrollController();
  
  // Waktu
  String _selectedTime = '18:30 - 19:00';
  final List<String> _timeOptions = [
    '17:00 - 17:30', '17:30 - 18:00', '18:00 - 18:30', 
    '18:30 - 19:00', '19:00 - 19:30', '19:30 - 20:00'
  ];

  // Jumlah Orang
  int _peopleCount = 2;
  bool _isAgreed = false;

  // Controller Text
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _weekdays = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];

  @override
  void initState() {
    super.initState();
    
    DateTime now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedDate = DateTime(now.year, now.month, now.day); // Normalisasi jam
    
    _generateDateList(); 
    _loadUserData(); 

    // Otomatis geser kalender ke tanggal hari ini saat dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentDate());
  }

  void _scrollToCurrentDate() {
    DateTime now = DateTime.now();
    if (_selectedMonth == now.month && _selectedYear == now.year) {
      // 55 (lebar) + 12 (margin) = 67
      double offset = (now.day - 1) * 67.0; 
      if (_dateScrollController.hasClients) {
        // Jump langsung ke posisi tanggal hari ini
        _dateScrollController.jumpTo(offset);
      }
    } else {
      if (_dateScrollController.hasClients) {
        _dateScrollController.jumpTo(0);
      }
    }
  }

  // --- FUNGSI MENGHASILKAN DAFTAR TANGGAL (1 sampai akhir bulan) ---
  void _generateDateList() {
    int daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

    _dateList = [];
    for (int i = 1; i <= daysInMonth; i++) {
      _dateList.add(DateTime(_selectedYear, _selectedMonth, i));
    }

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // Cegah _selectedDate memilih tanggal tidak valid atau masa lalu
    if (_selectedDate.month != _selectedMonth || _selectedDate.year != _selectedYear) {
      DateTime firstValid = DateTime(_selectedYear, _selectedMonth, 1);
      if (firstValid.isBefore(today)) {
        _selectedDate = today;
      } else {
        _selectedDate = firstValid;
      }
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
    });
  }

  Future<void> _saveAndGoToMenu() async {
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda harus menyetujui syarat & ketentuan restoran.'), backgroundColor: Colors.red));
      return;
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('res_date', _selectedDate.toIso8601String());
    await prefs.setString('res_time', _selectedTime);
    await prefs.setInt('res_guests', _peopleCount);
    await prefs.setString('res_notes', _notesController.text);

    if (!mounted) return;
    
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ReservationMenuScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSection(),
                  const SizedBox(height: 30),
                  _buildTimeSection(),
                  const SizedBox(height: 30),
                  _buildPeopleSection(),
                  const SizedBox(height: 30),
                  _buildNotesSection(),
                  const SizedBox(height: 30),
                  _buildUserInfoSection(),
                  const SizedBox(height: 30),
                  _buildTermsAndButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 25, left: 20, right: 20),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          )
        ],
      ),
    );
  }

  // --- KOMPONEN DROPDOWN BULAN & TAHUN ---
  Widget _buildDateSection() {
    DateTime now = DateTime.now();
    int startMonth = (_selectedYear == now.year) ? now.month : 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pick your date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            Row(
              children: [
                // Dropdown Bulan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMonth,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
                      items: List.generate(12 - startMonth + 1, (index) {
                        int m = startMonth + index;
                        return DropdownMenuItem(
                          value: m,
                          child: Text(_months[m - 1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedMonth = val;
                            _generateDateList();
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentDate());
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Dropdown Tahun (Dinamis 5 tahun)
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    dropdownColor: Colors.white, 
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
                    items: List.generate(5, (index) { 
                      int y = now.year + index;
                      return DropdownMenuItem(
                        value: y,
                        child: Text('$y', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedYear = val;
                          if (_selectedYear == now.year && _selectedMonth < now.month) {
                            _selectedMonth = now.month;
                          }
                          _generateDateList();
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentDate());
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        
        // List Tanggal Horizontal
        SizedBox(
          height: 80,
          child: Row(
            children: [
              const Icon(Icons.chevron_left, color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  controller: _dateScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _dateList.length,
                  itemBuilder: (context, index) {
                    DateTime date = _dateList[index];
                    DateTime today = DateTime(now.year, now.month, now.day);
                    
                    // Cek apakah ini hari yang sudah berlalu (Past Date)
                    bool isPast = date.isBefore(today);
                    bool isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
                    int weekDayIndex = date.weekday % 7; 
                    
                    return GestureDetector(
                      onTap: () {
                        if (!isPast) {
                          setState(() => _selectedDate = date);
                        } else {
                          // Tampilkan pesan error jika mengklik tanggal yang sudah berlalu
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tidak dapat mereservasi untuk tanggal yang sudah berlalu!'), duration: Duration(seconds: 1)),
                          );
                        }
                      },
                      child: Opacity(
                        // PERBAIKAN: Tanggal lewat jadi transparan / abu-abu redup
                        opacity: isPast ? 0.3 : 1.0, 
                        child: Container(
                          width: 55,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryOrange : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${date.day}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                              Text(_weekdays[weekDayIndex], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTimeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Pick your time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true,
              value: _selectedTime,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black87),
              dropdownColor: Colors.white,
              items: _timeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)))).toList(),
              onChanged: (val) => setState(() => _selectedTime = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('How many people?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() { if (_peopleCount > 1) _peopleCount--; }),
              child: const Icon(Icons.remove, size: 22, color: Colors.grey),
            ),
            const SizedBox(width: 20),
            Text('$_peopleCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => setState(() => _peopleCount++),
              child: const Icon(Icons.add, size: 22, color: Colors.black87),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(color: Colors.black87), 
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Add special request...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        _buildTextField('Full name', _nameController),
        const SizedBox(height: 12),
        _buildTextField('Phone number', _phoneController, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField('Email', _emailController),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTermsAndButton() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _isAgreed,
                activeColor: _primaryOrange,
                side: const BorderSide(color: Colors.grey),
                onChanged: (val) => setState(() => _isAgreed = val!),
              ),
            ),
            const SizedBox(width: 8),
            const Text('I agree with restaurant ', style: TextStyle(fontSize: 12, color: Colors.black87)),
            const Text('terms of service', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline, color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: _primaryOrange.withOpacity(0.4),
            ),
            onPressed: _saveAndGoToMenu,
            child: const Text('PILIH MENU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }
}