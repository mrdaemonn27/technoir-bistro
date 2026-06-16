import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final Color _darkAdmin = const Color(0xFF1E232C);
  final Color _primaryOrange = const Color(0xFFFE8C00);
  final Color _darkText = const Color(0xFF373B4D); // Warna teks biru gelap

  List menus = [];
  List categories = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
    _fetchCategories();
  }

  // ==========================================
  // 1. READ (Ambil Data Menu & Kategori)
  // ==========================================
  Future<void> _fetchMenus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://192.168.18.12:8000/api/menus'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          menus = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat data menu')));
    }
  }

  Future<void> _fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://192.168.18.12:8000/api/categories'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() => categories = data['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Gagal memuat kategori: $e');
    }
  }

  // ==========================================
  // 2. DELETE (Hapus Data Menu)
  // ==========================================
  Future<void> _deleteMenu(int id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Hapus Menu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus menu ini? Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(color: Colors.black54),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('http://192.168.18.12:8000/api/menus/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchMenus(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus menu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ==========================================
  // 3. CREATE / UPDATE (Upload File & Simpan Data)
  // ==========================================
  void _showMenuForm({Map<String, dynamic>? existingMenu}) {
    final bool isEdit = existingMenu != null;

    final TextEditingController nameController = TextEditingController(
      text: isEdit ? existingMenu['name'] : '',
    );
    final TextEditingController priceController = TextEditingController(
      text: isEdit ? existingMenu['price'].toString() : '',
    );
    final TextEditingController descController = TextEditingController(
      text: isEdit ? existingMenu['description'] : '',
    );

    File? imageFile;
    final ImagePicker picker = ImagePicker();

    int? selectedCategoryId;
    if (isEdit && existingMenu['category_id'] != null) {
      selectedCategoryId = int.tryParse(existingMenu['category_id'].toString());
    } else if (categories.isNotEmpty) {
      selectedCategoryId = categories.first['id'];
    }

    String? oldImageUrl = isEdit ? existingMenu['image'] : null;
    if (oldImageUrl != null &&
        oldImageUrl.isNotEmpty &&
        !oldImageUrl.startsWith('http')) {
      oldImageUrl = 'http://192.168.18.12:8000/storage/$oldImageUrl';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Edit Menu' : 'Tambah Menu Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _darkAdmin,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- UPLOAD GAMBAR ---
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final XFile? pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                          );
                          if (pickedFile != null) {
                            setModalState(
                              () => imageFile = File(pickedFile.path),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: imageFile != null
                                ? Image.file(imageFile!, fit: BoxFit.cover)
                                : (oldImageUrl != null
                                      ? Image.network(
                                          oldImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.image,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 40,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Pilih Gambar Menu',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Nama Menu',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Harga (Rp)',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (categories.isNotEmpty)
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        value: selectedCategoryId,
                        items: categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat['id'],
                            child: Text(
                              cat['name'],
                              style: const TextStyle(color: Colors.black87),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setModalState(() => selectedCategoryId = val),
                      ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (nameController.text.isEmpty ||
                                    priceController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Nama dan Harga wajib diisi!',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? token = prefs.getString('token');

                                final url = isEdit
                                    ? Uri.parse(
                                        'http://192.168.18.12:8000/api/menus/${existingMenu['id']}',
                                      )
                                    : Uri.parse(
                                        'http://192.168.18.12:8000/api/menus',
                                      );

                                try {
                                  var request = http.MultipartRequest(
                                    'POST',
                                    url,
                                  );

                                  request.headers['Authorization'] =
                                      'Bearer $token';
                                  request.headers['Accept'] =
                                      'application/json';

                                  if (isEdit) {
                                    request.fields['_method'] = 'PUT';
                                  }

                                  request.fields['name'] = nameController.text;
                                  request.fields['price'] =
                                      priceController.text;
                                  request.fields['description'] =
                                      descController.text;

                                  if (selectedCategoryId != null) {
                                    request.fields['category_id'] =
                                        selectedCategoryId.toString();
                                  }

                                  if (imageFile != null) {
                                    request.files.add(
                                      await http.MultipartFile.fromPath(
                                        'image',
                                        imageFile!.path,
                                      ),
                                    );
                                  }

                                  final streamedResponse = await request.send();
                                  final response = await http
                                      .Response.fromStream(streamedResponse);
                                  final responseData = json.decode(
                                    response.body,
                                  );

                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEdit
                                              ? 'Menu diperbarui!'
                                              : 'Menu ditambahkan!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _fetchMenus();
                                  } else {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          responseData['message'] ??
                                              'Gagal menyimpan menu.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setModalState(() => isSubmitting = false);
                                }
                              },
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAHKAN MENU',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // UI UTAMA
  // ==========================================
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
            padding: const EdgeInsets.only(left: 20, top: 24, bottom: 16),
            child: Text(
              'Kelola Menu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
          ),

          // --- GRID MENU ---
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: _primaryOrange),
                  )
                : menus.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data menu.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          0.72, // Proporsi agar card tinggi seperti di gambar
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index];
                      return _buildMenuCard(menu);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showMenuForm(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tombol Kembali
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

          // Ikon Restaurant Merah
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B3B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN CARD MENU ---
  Widget _buildMenuCard(dynamic menu) {
    String? imageUrl = menu['image'];
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http')) {
      imageUrl = 'http://192.168.18.12:8000/storage/$imageUrl';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Gambar
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _placeholderImg(),
                    )
                  : _placeholderImg(),
            ),
          ),

          // Bagian Teks & Tombol
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp. ${menu['price']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ), // Warna teks harga hitam/grey
                ),
                const SizedBox(height: 12),

                // Row Tombol Edit dan Hapus
                Row(
                  children: [
                    // Tombol Edit
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showMenuForm(existingMenu: menu),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Hapus (Minus)
                    GestureDetector(
                      onTap: () => _deleteMenu(menu['id']),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B), // Warna merah salmon
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImg() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
    );
  }
}
