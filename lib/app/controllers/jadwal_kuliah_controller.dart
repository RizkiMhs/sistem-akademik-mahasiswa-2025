import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/jadwal_kuliah_model.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart'; // Import untuk groupBy

class JadwalKuliahController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find();

  var isLoading = true.obs;
  // Menyimpan jadwal yang sudah dikelompokkan berdasarkan hari
  var groupedJadwal = <String, List<JadwalKuliah>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJadwalKuliahMahasiswa();
  }

  /// [FIXED] Fungsi ini sekarang memanggil endpoint yang benar
  void fetchJadwalKuliahMahasiswa() async {
    try {
      isLoading.value = true;
      final token = _authController.token.value;
      if (token.isEmpty) {
        throw Exception("Sesi tidak valid, silakan login ulang.");
      }

      // Memanggil fungsi yang benar di ApiService
      final List<JadwalKuliah> jadwalList = await _apiService.getJadwalKuliah(token);

      // Mengelompokkan jadwal berdasarkan hari
      groupedJadwal.value = groupBy(jadwalList, (JadwalKuliah jadwal) => jadwal.hari);

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
