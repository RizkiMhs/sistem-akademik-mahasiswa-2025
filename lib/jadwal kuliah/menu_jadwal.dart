import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/jadwal_kuliah_controller.dart';
import 'package:flutter_application_1/jadwal%20kuliah/detail_jadwal_harian.dart';
import 'package:flutter_application_1/models/jadwal_kuliah_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';

class JadwalKuliahPage extends StatelessWidget {
  const JadwalKuliahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final JadwalKuliahController controller = Get.put(JadwalKuliahController());

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Jadwal masuk kuliah Anda untuk semester ini, berdasarkan KRS yang telah disetujui.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.groupedJadwal.isEmpty) {
                return const Center(
                  child: Text(
                    "Tidak ada jadwal kuliah.\nPastikan KRS Anda sudah disetujui.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              final sortedDays = controller.groupedJadwal.keys.toList()
                ..sort((a, b) => _dayOrder(a).compareTo(_dayOrder(b)));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: sortedDays.length,
                itemBuilder: (context, index) {
                  final hari = sortedDays[index];
                  final jadwalList = controller.groupedJadwal[hari]!;
                  return _buildDayButton(
                    context: context,
                    day: hari,
                    scheduleList: jadwalList,
                    isGreen: index.isEven,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  int _dayOrder(String day) {
    switch (day.toLowerCase()) {
      case 'senin': return 1;
      case 'selasa': return 2;
      case 'rabu': return 3;
      case 'kamis': return 4;
      case 'jumat': return 5;
      default: return 6;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: greencolor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Jadwal Kuliah", style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 22, color: Colors.white)),
      centerTitle: true,
    );
  }

  Widget _buildDayButton({
    required BuildContext context,
    required String day,
    required List<JadwalKuliah> scheduleList,
    required bool isGreen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isGreen ? greencolor : orangecolor,
          minimumSize: const Size(double.infinity, 53),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
        ),
        onPressed: () {
          Get.to(() => DetailJadwalHarianPage(
                hari: day,
                jadwalList: scheduleList,
              ));
        },
        child: Text(
          day,
          style: const TextStyle(
            fontFamily: 'Poppinssemibold',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
