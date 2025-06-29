import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/jadwal_kuliah_model.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:flutter_application_1/widgets/success_dialog.dart';
import 'dart:developer' as developer; // Untuk debugging


class KrsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find();

  var isLoading = true.obs;
  // --- BARIS YANG HILANG SEBELUMNYA, SEKARANG DITAMBAHKAN ---
  // State loading khusus untuk tombol "Simpan"
  var isSubmitting = false.obs;
  var tahunAkademikAktif = ''.obs;
  var semesterMahasiswa = 0.obs;
  
  // Menyimpan data jadwal yang dikelompokkan berdasarkan semester
  var groupedJadwal = <int, List<JadwalKuliah>>{}.obs;

  // Menyimpan jadwal yang dipilih oleh mahasiswa
  var selectedJadwal = <int>{}.obs; // Menyimpan ID jadwal yang dipilih

  // Menghitung total SKS yang dipilih
  int get totalSks => selectedJadwal.fold(0, (sum, jadwalId) {
    // Cari jadwal di dalam groupedJadwal untuk mendapatkan SKS-nya
    final jadwal = groupedJadwal.values
        .expand((list) => list)
        .firstWhereOrNull((j) => j.id == jadwalId);
    return sum + (jadwal?.kelas?.mataKuliah?.sks ?? 0);
  });

  @override
  void onInit() {
    super.onInit();
    fetchPenawaranKrs();
  }

  Future<void> fetchPenawaranKrs() async {
    try {
      isLoading.value = true;
      final token = _authController.token.value;
      if (token.isEmpty) {
        throw Exception("Token tidak ditemukan.");
      }

      final response = await _apiService.getPenawaranKrs(token);
      
      tahunAkademikAktif.value = response['tahun_akademik_aktif'];
      semesterMahasiswa.value = response['semester_mahasiswa'];

      List<JadwalKuliah> jadwalList = (response['jadwal_ditawarkan'] as List)
          .map((item) => JadwalKuliah.fromJson(item))
          .toList();

      // Kelompokkan jadwal berdasarkan semester dari mata kuliahnya
      groupedJadwal.value = groupBy(jadwalList, (JadwalKuliah j) => j.kelas?.mataKuliah?.semester ?? 0);
      
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data KRS: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleJadwalSelection(int jadwalId) {
    if (selectedJadwal.contains(jadwalId)) {
      selectedJadwal.remove(jadwalId);
    } else {
      selectedJadwal.add(jadwalId);
    }
    // Update agar UI merefleksikan perubahan total SKS
    selectedJadwal.refresh();
  }

  /// Mengirim data KRS yang sudah dipilih ke server.
  void submitKrs() async {
    if (selectedJadwal.isEmpty) {
      Get.snackbar('Perhatian', 'Anda belum memilih mata kuliah sama sekali.');
      return;
    }

    isSubmitting.value = true;
    try {
      final token = _authController.token.value;
      // final response = await _apiService.simpanKrs(token, selectedJadwal.toList());
      // --- BAGIAN YANG DIPERBAIKI ---
      // Simpan hasil toList() ke dalam variabel agar bisa digunakan lagi
      final jadwalIds = selectedJadwal.toList();

      // --- LANGKAH DEBUGGING ---
      // Cetak data yang akan dikirim ke konsol untuk diperiksa
      developer.log("--- Mengirim Data KRS ke Server ---", name: "KRSDebug");
      developer.log("Token: Bearer $token", name: "KRSDebug");
      developer.log("Payload (jadwal_ids): $jadwalIds", name: "KRSDebug");
      // --------------------------

      // Gunakan variabel yang sudah dibuat
      final response = await _apiService.simpanKrs(token, jadwalIds);

      // Tampilkan dialog sukses jika berhasil
      Get.dialog(
        SuccessDialog(
          title: "Berhasil!",
          message: response['message'] ?? "KRS Anda telah berhasil diajukan.",
          // message: "KRS Anda telah berhasil diajukan.",
          onConfirm: () {
            Get.back(); // Tutup dialog
            Get.back(); // Kembali ke halaman menu KRS
          },
        ),
        barrierDismissible: false,
      );

    } catch (e) {
      Get.snackbar('Gagal Menyimpan KRS', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
  
}
