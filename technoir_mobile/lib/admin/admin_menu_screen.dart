import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // <-- TAMBAHKAN INI (Untuk File)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // <-- TAMBAHKAN INI (Untuk pilih gambar)

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final Color _darkAdmin = const Color(0xFF1E232C);
  final Color _primaryOrange = const Color(0xFFFE8C00);

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
        Uri.parse('http://10.0.2.2:8000/api/menus'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data menu')));
    }
  }

  Future<void> _fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/categories'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
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
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Hapus Menu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        content: const Text('Apakah Anda yakin ingin menghapus menu ini? Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: Colors.black54)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/api/menus/$id'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu berhasil dihapus'), backgroundColor: Colors.green));
        _fetchMenus(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus menu'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ==========================================
  // 3. CREATE / UPDATE (Upload File & Simpan Data)
  // ==========================================
  void _showMenuForm({Map<String, dynamic>? existingMenu}) {
    final bool isEdit = existingMenu != null;
    
    final TextEditingController nameController = TextEditingController(text: isEdit ? existingMenu['name'] : '');
    final TextEditingController priceController = TextEditingController(text: isEdit ? existingMenu['price'].toString() : '');
    final TextEditingController descController = TextEditingController(text: isEdit ? existingMenu['description'] : '');
    
    File? imageFile;
    final ImagePicker picker = ImagePicker();

    int? selectedCategoryId;
    if (isEdit && existingMenu['category_id'] != null) {
      selectedCategoryId = int.tryParse(existingMenu['category_id'].toString());
    } else if (categories.isNotEmpty) {
      selectedCategoryId = categories.first['id'];
    }

    // URL gambar lama (jika ada) untuk ditampilkan sebelum diubah
    String? oldImageUrl = isEdit ? existingMenu['image'] : null;
    if (oldImageUrl != null && oldImageUrl.isNotEmpty && !oldImageUrl.startsWith('http')) {
      oldImageUrl = 'http://10.0.2.2:8000/storage/$oldImageUrl';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // Paksa background putih
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isEdit ? 'Edit Menu' : 'Tambah Menu Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _darkAdmin)),
                    const SizedBox(height: 20),

                    // --- UPLOAD GAMBAR ---
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                          if (pickedFile != null) {
                            setModalState(() => imageFile = File(pickedFile.path));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: imageFile != null
                                ? Image.file(imageFile!, fit: BoxFit.cover) // Jika pilih foto baru
                                : (oldImageUrl != null
                                    ? Image.network(oldImageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image, size: 50, color: Colors.grey))
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                                          const SizedBox(height: 8),
                                          Text('Pilih Gambar Menu', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                                        ],
                                      )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black87), // PERBAIKAN WARNA TEKS
                      decoration: InputDecoration(
                        labelText: 'Nama Menu', 
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black87), // PERBAIKAN WARNA TEKS
                      decoration: InputDecoration(
                        labelText: 'Harga (Rp)', 
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Kategori
                    if (categories.isNotEmpty)
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Kategori', 
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black87, fontSize: 16), // PERBAIKAN WARNA TEKS
                        value: selectedCategoryId,
                        items: categories.map((cat) {
                          return DropdownMenuItem<int>(value: cat['id'], child: Text(cat['name'], style: const TextStyle(color: Colors.black87)));
                        }).toList(),
                        onChanged: (val) => setModalState(() => selectedCategoryId = val),
                      ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black87), // PERBAIKAN WARNA TEKS
                      decoration: InputDecoration(
                        labelText: 'Deskripsi', 
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: isSubmitting ? null : () async {
                          if (nameController.text.isEmpty || priceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Harga wajib diisi!'), backgroundColor: Colors.red));
                            return;
                          }

                          setModalState(() => isSubmitting = true);
                          
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String? token = prefs.getString('token');
                          
                          // Gunakan POST untuk Update karena PHP/Laravel kesulitan membaca Multipart File lewat method PUT
                          final url = isEdit 
                              ? Uri.parse('http://10.0.2.2:8000/api/menus/${existingMenu['id']}')
                              : Uri.parse('http://10.0.2.2:8000/api/menus');
                              
                          try {
                            var request = http.MultipartRequest('POST', url);
                            
                            request.headers['Authorization'] = 'Bearer $token';
                            request.headers['Accept'] = 'application/json';

                            // Jika Edit, beri tahu Laravel bahwa method sebenarnya adalah PUT
                            if (isEdit) {
                              request.fields['_method'] = 'PUT';
                            }
                            
                            request.fields['name'] = nameController.text;
                            request.fields['price'] = priceController.text;
                            request.fields['description'] = descController.text;
                            
                            if (selectedCategoryId != null) {
                              request.fields['category_id'] = selectedCategoryId.toString();
                            }

                            // Tambahkan Foto Jika Memilih
                            if (imageFile != null) {
                              request.files.add(
                                await http.MultipartFile.fromPath('image', imageFile!.path)
                              );
                            }

                            final streamedResponse = await request.send();
                            final response = await http.Response.fromStream(streamedResponse);
                            final responseData = json.decode(response.body);

                            if (response.statusCode == 200 || response.statusCode == 201) {
                              if (!mounted) return;
                              Navigator.pop(context); // Tutup modal
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Menu diperbarui!' : 'Menu ditambahkan!'), backgroundColor: Colors.green));
                              _fetchMenus(); // Refresh layar
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'] ?? 'Gagal menyimpan menu.'), backgroundColor: Colors.red));
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                          } finally {
                            setModalState(() => isSubmitting = false);
                          }
                        },
                        child: isSubmitting 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAHKAN MENU', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
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
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: _darkAdmin,
        elevation: 0,
        title: const Text('Kelola Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: _primaryOrange))
          : menus.isEmpty
              ? const Center(child: Text('Belum ada data menu.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    
                    String? imageUrl = menu['image'];
                    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                      imageUrl = 'http://10.0.2.2:8000/storage/$imageUrl';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => _placeholderImg())
                              : _placeholderImg(),
                        ),
                        // PERBAIKAN WARNA TEKS (Hitam / Black87)
                        title: Text(menu['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Rp. ${menu['price']}', style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.w600)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showMenuForm(existingMenu: menu), // Mode Edit
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMenu(menu['id']), // Hapus
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryOrange,
        onPressed: () => _showMenuForm(), // Mode Tambah (null)
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _placeholderImg() {
    return Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.fastfood, color: Colors.grey));
  }
}