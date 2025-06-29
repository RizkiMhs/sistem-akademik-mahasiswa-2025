import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/transkrip_model.dart';
import 'package:flutter_application_1/app/services/transkrip_pdf_generator.dart';

import 'package:get/get.dart';

class TranskripController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find();

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final Rx<Transkrip?> transkripData = Rx<Transkrip?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchTranskrip();
  }

  //
  // File: app/controllers/transkrip_controller.dart

  Future<void> fetchTranskrip() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final token = _authController.token.value; // Ini sudah benar
      if (token.isEmpty) throw Exception("Sesi tidak valid.");

      final response = await _apiService.getTranskrip(token);

      // [PERBAIKAN] Akses 'data' dari dalam respons JSON
      if (response != null && response['data'] != null) {
        transkripData.value = Transkrip.fromJson(response['data']);
      } else {
        throw Exception("Format respons API tidak valid atau data kosong.");
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading.value = false;
    }
  }

// --- FUNGSI BARU UNTUK MENCETAK PDF ---
  Future<void> cetakTranskrip() async {
    if (transkripData.value == null ||
        _authController.currentUser.value == null) {
      Get.snackbar("Gagal", "Data Transkrip atau Mahasiswa tidak ditemukan.");
      return;
    }
    // Panggil fungsi generator
    await TranskripPdfGenerator.generateAndPrintTranskrip(
        transkripData.value!, _authController.currentUser.value!);
  }
}
