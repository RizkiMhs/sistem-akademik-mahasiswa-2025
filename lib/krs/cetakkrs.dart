import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/app/controllers/cetak_krs_controller.dart';
import 'package:flutter_application_1/models/krs_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CetakKrsPage extends StatelessWidget {
  const CetakKrsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller saat halaman ini dibuka
    final CetakKrsController controller = Get.put(CetakKrsController());
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: const Text("Riwayat & Cetak KRS", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        // Tampilkan loading indicator saat data sedang diambil
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // Tampilkan pesan error jika ada masalah
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
            ),
          );
        }
        // Tampilkan pesan jika data KRS tidak ditemukan
        if (controller.krsData.value == null) {
          return const Center(child: Text("Data KRS tidak ditemukan."));
        }

        // Jika data berhasil diambil, tampilkan UI utama
        final krs = controller.krsData.value!;
        final user = authController.currentUser.value!;

        // Hitung total SKS dari detail KRS
        final totalSks = krs.detail.fold(0, (sum, detail) => sum + (detail.jadwalKuliah.kelas?.mataKuliah?.sks ?? 0));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderInfo(user, krs, totalSks),
              const SizedBox(height: 24),
              Text("Daftar Mata Kuliah Diambil", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildKrsTable(krs),
            ],
          ),
        );
      }),
      // [FIXED] Hubungkan floatingActionButton ke fungsi baru
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isLoading.value 
                ? null // Nonaktifkan tombol saat loading
                : () => controller.cetakKrs(), // Panggil fungsi cetak
            icon: const Icon(Icons.print),
            label: const Text("Cetak ke PDF"),
            backgroundColor: orangecolor,
          )),
    );
  }

  /// Widget untuk menampilkan kartu informasi utama di bagian atas.
  Widget _buildHeaderInfo(user, Krs krs, int totalSks) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _infoRow("Nama Mahasiswa:", user.nama),
            _infoRow("NIM:", user.nim),
            _infoRow("Dosen Wali:", user.dosen?.nama ?? '-'),
            const Divider(height: 20, color: Colors.grey),
            _infoRow("Tahun Akademik:", krs.tahunAkademik),
            _infoRow("Semester:", krs.semester?.toString() ?? 'N/A'),
            _infoRow("Total SKS Diambil:", "$totalSks SKS"),
            _infoRow(
              "Status KRS:", 
              krs.statusKrs, 
              valueColor: krs.statusKrs == 'Disetujui' ? Colors.green.shade700 : Colors.orange.shade800
            ),
          ],
        ),
      ),
    );
  }
  
  /// Widget untuk menampilkan tabel daftar mata kuliah.
  Widget _buildKrsTable(Krs krs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => greencolor.withOpacity(0.1)),
        border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
        columns: const [
          DataColumn(label: Text('Kode MK', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Nama Mata Kuliah', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('SKS', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Jadwal', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Dosen', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: krs.detail.map((d) {
          final matkul = d.jadwalKuliah.kelas?.mataKuliah;
          final jadwal = d.jadwalKuliah;
          final dosen = d.jadwalKuliah.kelas?.dosen;
          return DataRow(cells: [
            DataCell(Text(matkul?.kode ?? '-')),
            DataCell(Text(matkul?.namaMatkul ?? '-')),
            DataCell(Text(matkul?.sks.toString() ?? '-')),
            DataCell(Text('${jadwal.hari}, ${jadwal.jamMulai.substring(0,5)}')),
            DataCell(Text(dosen?.nama ?? '-')),
          ]);
        }).toList(),
      ),
    );
  }

  /// Widget helper untuk membuat satu baris informasi (Label dan Value).
  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor)),
        ],
      ),
    );
  }
}
