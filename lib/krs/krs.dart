import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/krs_controller.dart';
import 'package:flutter_application_1/models/jadwal_kuliah_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';

class IsiKrsPage extends StatelessWidget {
  const IsiKrsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final KrsController controller = Get.put(KrsController());

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Pengisian KRS", style: TextStyle(color: Colors.white)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildInfoPanel(controller),
            Expanded(
              child: _buildJadwalList(controller),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomSummary(controller),
    );
  }

  Widget _buildInfoPanel(KrsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: greencolor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "T.A: ${controller.tahunAkademikAktif.value}",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "Semester: ${controller.semesterMahasiswa.value}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalList(KrsController controller) {
    if (controller.groupedJadwal.isEmpty) {
      return const Center(
          child: Text("Tidak ada mata kuliah yang ditawarkan."));
    }

    final sortedSemesters = controller.groupedJadwal.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedSemesters.length,
      itemBuilder: (context, index) {
        final semester = sortedSemesters[index];
        if (semester == 0)
          return const SizedBox.shrink(); // Jangan tampilkan grup semester 0
        final jadwalList = controller.groupedJadwal[semester]!;
        return ExpansionTile(
          title: Text("Semester $semester",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          initiallyExpanded: true,
          children: jadwalList
              .map((jadwal) => _buildJadwalTile(jadwal, controller))
              .toList(),
        );
      },
    );
  }

  Widget _buildJadwalTile(JadwalKuliah jadwal, KrsController controller) {
    final matkul = jadwal.kelas?.mataKuliah;
    return Obx(() {
      final isSelected = controller.selectedJadwal.contains(jadwal.id);
      return CheckboxListTile(
        title: Text(matkul?.namaMatkul ?? 'Nama Matkul Tidak Ada'),
        subtitle: Text(
          '${matkul?.sks} SKS | ${jadwal.hari}, ${jadwal.jamMulai.substring(0, 5)} - ${jadwal.jamSelesai.substring(0, 5)} | Dosen: ${jadwal.kelas?.dosen?.nama ?? "N/A"}',
        ),
        value: isSelected,
        onChanged: (bool? value) {
          controller.toggleJadwalSelection(jadwal.id);
        },
        activeColor: orangecolor,
      );
    });
  }

  Widget _buildBottomSummary(KrsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total SKS Dipilih:",
                      style: TextStyle(color: Colors.grey)),
                  Text("${controller.totalSks} SKS",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              )),
          ElevatedButton(
            onPressed: controller.submitKrs,
            style: ElevatedButton.styleFrom(
              backgroundColor: orangecolor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child:
                const Text("Simpan KRS", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
