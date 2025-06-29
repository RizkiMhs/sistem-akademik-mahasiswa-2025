import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/models/pengumuman_model.dart';
import 'package:get/get.dart';

class PengumumanController extends GetxController {
  final ApiService _apiService = ApiService();

  var pengumumanList = <Pengumuman>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPengumuman();
  }

  // --- BAGIAN YANG DIPERBAIKI ---
  // Ubah return type dari 'void' menjadi 'Future<void>'
  // Ini akan memberitahu RefreshIndicator kapan proses fetch selesai.
  Future<void> fetchPengumuman() async {
    try {
      isLoading.value = true;
      var fetchedPengumuman = await _apiService.fetchPengumuman();
      // Urutkan dari yang terbaru
      fetchedPengumuman.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      pengumumanList.assignAll(fetchedPengumuman);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat pengumuman: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
