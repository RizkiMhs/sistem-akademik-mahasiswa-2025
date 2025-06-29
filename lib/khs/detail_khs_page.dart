import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/khs_model.dart';
import 'package:flutter_application_1/app/services/khs_pdf_generator.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';

class DetailKhsPage extends StatelessWidget {
  final Khs khs;
  const DetailKhsPage({super.key, required this.khs});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final user = authController.currentUser.value!;
    
    // Hitung total SKS
    final totalSks = khs.details.fold(0, (sum, detail) => sum + (detail.mataKuliah?.sks ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail KHS Semester ${khs.semester}", style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderInfo(user, khs, totalSks),
            const SizedBox(height: 20),
            _buildKhsTable(),
          ],
        ),
      ),
      // [FIXED] Hubungkan floatingActionButton ke fungsi baru
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Panggil fungsi generator PDF saat tombol ditekan
          KhsPdfGenerator.generateAndPrintKhs(khs, user);
        },
        icon: const Icon(Icons.print),
        label: const Text("Cetak KHS"),
        backgroundColor: orangecolor,
      ),
    );
  }
  
  Widget _buildHeaderInfo(user, Khs khs, int totalSks) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _infoRow("Nama Mahasiswa:", user.nama),
            _infoRow("NIM:", user.nim),
            _infoRow("Dosen Wali:", user.dosen?.nama ?? '-'),
            const Divider(height: 20, color: Colors.grey),
            _infoRow("Tahun Akademik:", khs.tahunAkademik),
            _infoRow("Total SKS:", "$totalSks SKS"),
            _infoRow("IPS (Indeks Prestasi Semester):", khs.ips ?? '0.00', valueColor: Colors.green.shade700),
            _infoRow("IPK (Indeks Prestasi Kumulatif):", khs.ipk ?? '0.00', valueColor: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKhsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => greencolor.withOpacity(0.1)),
        border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
        columns: const [
          DataColumn(label: Text('Kode MK', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Nama Mata Kuliah', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('SKS', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Nilai', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: khs.details.map((detail) {
          final matkul = detail.mataKuliah;
          return DataRow(cells: [
            DataCell(Text(matkul?.kode ?? '-')),
            DataCell(Text(matkul?.namaMatkul ?? '-')),
            DataCell(Text(matkul?.sks.toString() ?? '-')),
            DataCell(Text(detail.nilai ?? '-')),
            DataCell(Text(detail.grade ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
          ]);
        }).toList(),
      ),
    );
  }

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
