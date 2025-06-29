import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/transkrip_controller.dart';
import 'package:flutter_application_1/models/transkrip_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';

class TranskipNilaiPage extends StatelessWidget {
  const TranskipNilaiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TranskripController controller = Get.put(TranskripController());

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: const Text("Transkrip Nilai",
            style: TextStyle(color: Colors.white)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
              child: Text(controller.errorMessage.value,
                  textAlign: TextAlign.center));
        }
        if (controller.transkripData.value == null) {
          return const Center(child: Text("Data transkrip tidak ditemukan."));
        }

        final data = controller.transkripData.value!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderInfo(data.mahasiswa, data.transkripInfo),
            const SizedBox(height: 24),
            ..._buildSemesterTables(data.transkripInfo.nilaiPerSemester),
          ],
        );
      }),
      // [FIXED] Hubungkan floatingActionButton ke fungsi baru
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isLoading.value ||
                    controller.transkripData.value == null
                ? null // Nonaktifkan tombol saat loading atau jika data belum ada
                : () => controller.cetakTranskrip(), // Panggil fungsi cetak
            icon: const Icon(Icons.print),
            label: const Text("Cetak Transkrip"),
            backgroundColor: orangecolor,
          )),
    );
  }

  Widget _buildHeaderInfo(MahasiswaInfo mahasiswa, TranskripInfo transkrip) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(mahasiswa.nama,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("${mahasiswa.nim} | ${mahasiswa.programStudi ?? 'N/A'}",
                style: TextStyle(color: Colors.grey.shade600)),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                    "Total SKS Lulus", "${transkrip.totalSksLulus} SKS"),
                _buildSummaryItem("IPK", transkrip.ipk,
                    color: Colors.green.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: color)),
      ],
    );
  }

  List<Widget> _buildSemesterTables(List<NilaiSemester> nilaiPerSemester) {
    return nilaiPerSemester.map((semesterData) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ExpansionTile(
          title: Text("Semester ${semesterData.semester}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          initiallyExpanded: true,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Kode')),
                  DataColumn(label: Text('Mata Kuliah')),
                  DataColumn(label: Text('SKS')),
                  DataColumn(label: Text('Grade')),
                ],
                rows: semesterData.matakuliah
                    .map((matkul) => DataRow(cells: [
                          DataCell(Text(matkul.kodeMatkul ?? '-')),
                          DataCell(SizedBox(
                              width: 150,
                              child: Text(matkul.namaMatkul,
                                  overflow: TextOverflow.ellipsis))),
                          DataCell(Text(matkul.sks.toString())),
                          DataCell(Text(matkul.grade ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
