import 'dart:convert'; // Diperlukan untuk jsonEncode/Decode
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/models/mahasiswa_model.dart'; // <-- IMPORT MODEL
import 'package:flutter_application_1/views/homepage.dart';
import 'package:flutter_application_1/views/login2.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart'; // <-- IMPORT DIALOG
import 'dart:io'; // Untuk File (jika diperlukan)

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var token = ''.obs;

  // Variabel reaktif untuk menyimpan data mahasiswa yang sedang login
  // Kita gunakan Rx<Mahasiswa?> agar bisa bernilai null saat belum login
  final Rx<Mahasiswa?> currentUser = Rx<Mahasiswa?>(null);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// --- BAGIAN YANG DIPERBARUI TOTAL ---
  /// Memeriksa status login dengan mengambil data terbaru dari server.
  Future<void> checkLoginStatus() async {
    String? storedToken = await _storage.read(key: 'auth_token');

    if (storedToken != null && storedToken.isNotEmpty) {
      try {
        // Panggil API untuk mendapatkan data profil terbaru
        final profileData = await _apiService.getProfile(storedToken);

        // API /me langsung mengembalikan objek user
        final mahasiswaData = Mahasiswa.fromJson(profileData);
        currentUser.value = mahasiswaData;

        // Simpan kembali data terbaru ke local storage
        await _storage.write(key: 'user_data', value: jsonEncode(mahasiswaData.toJson()));
        
        token.value = storedToken;
        isLoggedIn.value = true;
      } catch (e) {
        // Jika gagal (misal token tidak valid), lakukan logout
        print("Sesi tidak valid, melakukan logout: $e");
        await logout();
      }
    } else {
      isLoggedIn.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _apiService.login(email, password);

      // Cek apakah response berisi token dan objek mahasiswa
      if (response['token'] != null && response['mahasiswa'] != null) {
        
        // Simpan token
        await _storage.write(key: 'auth_token', value: response['token']);
        token.value = response['token'];

        // Buat objek Mahasiswa dari data JSON
        final mahasiswaData = Mahasiswa.fromJson(response['mahasiswa']);
        currentUser.value = mahasiswaData;

        // Simpan data mahasiswa ke storage sebagai JSON string
        await _storage.write(key: 'user_data', value: jsonEncode(mahasiswaData.toJson()));

        isLoggedIn.value = true;
        Get.offAll(() => const Homepage()); 
      } else {
        throw Exception("Token atau data mahasiswa tidak ditemukan pada response.");
      }
    } catch (e) {
      Get.snackbar(
        "Login Gagal",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _apiService.logout(token.value);
    } catch (e) {
      print("Error saat logout dari server: $e");
    } finally {
      // Hapus token dan data user dari storage
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
      
      // Reset state
      token.value = '';
      currentUser.value = null; // Set data user menjadi null
      isLoggedIn.value = false;
      isLoading.value = false;
      
      Get.offAll(() => LoginTwo());
    }
  }
  Future<void> register(Map<String, String> data) async {
    try {
      isLoading.value = true;
      await _apiService.register(data);

      // Tampilkan notifikasi sukses
      Get.snackbar(
        "Sukses",
        "Registrasi berhasil, silakan login.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Arahkan ke halaman login setelah berhasil
      Get.off(() => LoginTwo());

    } catch (e) {
      Get.snackbar(
        "Registrasi Gagal",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Menangani logika untuk mengubah password pengguna.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (token.value.isEmpty) {
      Get.snackbar("Error", "Sesi tidak valid, silakan login kembali.");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.changePassword(
        token: token.value,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      // Hentikan loading SEBELUM menampilkan dialog
      isLoading.value = false;

      // Gunakan Get.dialog dengan widget kustom Anda
      Get.dialog(
        SuccessDialog(
          title: "Berhasil!",
          message: response['message'] ?? "Password Anda telah berhasil diubah.",
          onConfirm: () {
            Get.back(); // Tutup dialog
            Get.back(); // Kembali dari halaman Ubah Sandi
          },
        ),
        barrierDismissible: false, // Mencegah dialog ditutup dengan tap di luar
      );

    } catch (e) {
      isLoading.value = false; 
      Get.snackbar(
        "Gagal",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- FUNGSI YANG HILANG SEBELUMNYA, SEKARANG DITAMBAHKAN ---
  Future<void> updateProfile({
    required Map<String, String> data,
    File? foto,
  }) async {
    if (token.value.isEmpty) {
      Get.snackbar("Error", "Sesi tidak valid, silakan login kembali.");
      return;
    }
    
    isLoading.value = true;
    try {
      final response = await _apiService.updateProfile(
        token: token.value,
        data: data,
        foto: foto,
      );

      // Perbarui data currentUser secara lokal dengan respons dari API
      if (response['mahasiswa'] != null) {
        final updatedMahasiswa = Mahasiswa.fromJson(response['mahasiswa']);
        currentUser.value = updatedMahasiswa;
        await _storage.write(key: 'user_data', value: jsonEncode(updatedMahasiswa.toJson()));
      }
      
      isLoading.value = false;

      // Tampilkan dialog sukses
      Get.dialog(
        SuccessDialog(
          title: "Sukses!",
          message: response['message'] ?? "Profil berhasil diperbarui.",
          onConfirm: () {
            Get.back(); // Tutup dialog
            Get.back(); // Kembali ke halaman Data Diri
          },
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Gagal Memperbarui Profil", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
