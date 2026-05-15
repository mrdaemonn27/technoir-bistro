import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Variabel untuk menyimpan status toggle (on/off)
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;

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
          'Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Preferences
            _buildSectionHeader('Preferences'),
            _buildToggleItem(
              icon: Icons.notifications_none,
              title: 'Push Notifications',
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
            _buildToggleItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() => _darkModeEnabled = value);
                // TODO: Implementasi logika dark mode sungguhan nanti
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? 'Dark Mode Aktif' : 'Light Mode Aktif'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            _buildToggleItem(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              value: _locationEnabled,
              onChanged: (bool value) {
                setState(() => _locationEnabled = value);
              },
            ),
            const SizedBox(height: 24),

            // Bagian Account
            _buildSectionHeader('Account & Security'),
            _buildArrowItem(Icons.lock_outline, 'Change Password', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Ubah Password belum tersedia')),
              );
            }),
            _buildArrowItem(Icons.security, 'Privacy Policy', () {}),
            _buildArrowItem(Icons.description_outlined, 'Terms of Service', () {}),
            const SizedBox(height: 24),

            // Bagian Info
            _buildSectionHeader('About'),
            _buildArrowItem(Icons.info_outline, 'About Technoir Bistro', () {}),
            const SizedBox(height: 16),
            
            // Info Versi
            Center(
              child: Column(
                children: [
                  const Text('Technoir Bistro App', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper untuk judul bagian (Section Header)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C74B3), // Warna biru tema
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Helper untuk item dengan Toggle Switch (On/Off)
  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: SwitchListTile(
        activeColor: const Color(0xFF2C74B3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF282A45), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  // Helper untuk item dengan panah ke kanan (Arrow)
  Widget _buildArrowItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF282A45), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}