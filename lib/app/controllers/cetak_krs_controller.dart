import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/krs_model.dart';
import 'package:flutter_application_1/app/services/krs_pdf_generator.dart';
import 'package:get/get.dart';

class CetakKrsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find();

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final Rx<Krs?> krsData = Rx<Krs?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchSubmittedKrs();
  }

  Future<void> fetchSubmittedKrs() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Reset pesan error
      final token = _authController.token.value;
      if (token.isEmpty) throw Exception("Sesi tidak valid.");

      final response = await _apiService.getSubmittedKrs(token);
      krsData.value = Krs.fromJson(response);

    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI BARU UNTUK MENCETAK PDF ---
  Future<void> cetakKrs() async {
    if (krsData.value == null || _authController.currentUser.value == null) {
      Get.snackbar("Gagal", "Data KRS atau Mahasiswa tidak ditemukan.");
      return;
    }
    // Panggil fungsi generator
    await KrsPdfGenerator.generateAndPrintKrs(
      krsData.value!, 
      _authController.currentUser.value!
    );
  }
}
