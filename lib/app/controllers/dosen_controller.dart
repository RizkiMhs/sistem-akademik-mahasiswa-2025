import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/models/dosen_model.dart';
import 'package:get/get.dart';

class DosenController extends GetxController {
  final ApiService _apiService = ApiService();

  // Variabel untuk menyimpan daftar semua dosen
  var dosenList = <Dosen>[].obs;
  // State untuk menampilkan loading indicator
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Panggil fungsi untuk mengambil data saat controller pertama kali dibuat
    fetchAllDosen();
  }

  /// Mengambil daftar semua dosen dari API
  Future<void> fetchAllDosen() async {
    try {
      isLoading.value = true;
      var fetchedDosen = await _apiService.fetchDosen();
      dosenList.assignAll(fetchedDosen);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar dosen: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
