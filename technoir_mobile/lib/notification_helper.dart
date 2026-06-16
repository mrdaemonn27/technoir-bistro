import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Menggunakan icon bawaan aplikasi (berada di folder mipmap Android)
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    // --- PERBAIKAN: Mengganti nama parameter menjadi "settings:" sesuai permintaan versi terbaru ---
    await _notificationsPlugin.initialize(settings: initSettings);

    // Meminta izin memunculkan notifikasi (Wajib untuk Android 13+)
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'technoir_channel', // ID Channel
      'Technoir Notifications', // Nama Channel
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Pemanggilan show dengan named parameters
    await _notificationsPlugin.show(
      id: id, 
      title: title, 
      body: body, 
      notificationDetails: platformDetails,
    );
  }
}