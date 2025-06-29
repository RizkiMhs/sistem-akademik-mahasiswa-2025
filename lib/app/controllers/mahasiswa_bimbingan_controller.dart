import 'package:get/get.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/bimbingan_model.dart';

// Nama kelas controller diubah menjadi lebih spesifik
class MahasiswaBimbinganController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find();

  var bimbinganList = <Bimbingan>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBimbingan();
  }

  Future<void> fetchBimbingan() async {
    try {
      isLoading.value = true;
      final token = _authController.token.value;
      final response = await _apiService.getBimbinganMahasiswa(token); // Sesuaikan nama fungsi di service
      final List<dynamic> bimbinganJson = response['data'];
      bimbinganList.value = bimbinganJson.map((json) => Bimbingan.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat bimbingan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ajukanBimbingan({
    required String tanggal,
    required String topik,
    String? catatan,
  }) async {
    try {
      isLoading.value = true;
      final token = _authController.token.value;
      await _apiService.postBimbinganMahasiswa( // Sesuaikan nama fungsi di service
        token: token,
        tanggal: tanggal,
        topik: topik,
        catatan: catatan,
      );
      Get.back();
      Get.snackbar('Sukses', 'Pengajuan bimbingan berhasil dikirim.');
      fetchBimbingan();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengajukan bimbingan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}