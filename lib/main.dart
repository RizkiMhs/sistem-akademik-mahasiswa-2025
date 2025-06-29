import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/views/homepage.dart';
import 'package:flutter_application_1/views/login2.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';

// --- Import yang Diperlukan untuk Lokalisasi ---
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Pastikan semua binding siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data pemformatan tanggal untuk locale Indonesia ('id_ID')
  // Ini akan memperbaiki error LocaleDataException
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inisialisasi AuthController secara permanen
  Get.put(AuthController(), permanent: true); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      
      // --- Daftarkan Locale Anda di Sini ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Tambahkan Indonesia sebagai locale yang didukung
      ],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Obx(() {
        final authController = Get.find<AuthController>();
        if (authController.isLoggedIn.value) {
          return const Homepage();
        } else {
          return LoginTwo();
        }
      }),
    );
  }
}
