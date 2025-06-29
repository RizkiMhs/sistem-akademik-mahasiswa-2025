import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/models/mata_kuliah_model.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart'; // Import untuk groupBy
import 'dart:developer' as developer; // Import untuk debugging

class MataKuliahController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  var groupedMataKuliah = <int, List<MataKuliah>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAndGroupMataKuliah();
  }

  Future<void> fetchAndGroupMataKuliah() async {
    try {
      isLoading.value = true;
      var matkulList = await _apiService.fetchMataKuliah();

      // --- LANGKAH DEBUGGING ---
      // Cetak data yang berhasil di-parsing untuk melihat isinya
      developer.log("--- Data Mata Kuliah yang Berhasil di-Parse ---", name: "MataKuliahDebug");
      for (var matkul in matkulList) {
        developer.log("Nama: ${matkul.namaMatkul}, Semester: ${matkul.semester}", name: "MataKuliahDebug");
      }
      // --------------------------
      
      // --- BAGIAN YANG DIPERBARUI ---
      // Sekarang kita mengelompokkan berdasarkan field 'semester' yang sudah benar
      var grouped = groupBy(matkulList, (MataKuliah e) => e.semester);

      groupedMataKuliah.value = grouped;

    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data mata kuliah: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
