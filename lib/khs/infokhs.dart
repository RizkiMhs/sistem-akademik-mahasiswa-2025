import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/khs_controller.dart';
import 'package:flutter_application_1/khs/detail_khs_page.dart';
import 'package:flutter_application_1/models/khs_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';

class InfoKhs extends StatelessWidget {
  const InfoKhs({super.key});

  @override
  Widget build(BuildContext context) {
    final KhsController controller = Get.put(KhsController());

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: const Text("Kartu Hasil Studi", style: TextStyle(color: Colors.white)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)));
        }
        if (controller.khsList.isEmpty) {
          return const Center(child: Text("Riwayat KHS tidak ditemukan."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.khsList.length,
          itemBuilder: (context, index) {
            final khs = controller.khsList[index];
            return _buildSemesterCard(context, khs, index.isEven);
          },
        );
      }),
    );
  }

  Widget _buildSemesterCard(BuildContext context, Khs khs, bool isGreen) {
    return Card(
      color: isGreen ? greencolor : orangecolor,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          "Semester ${khs.semester}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          khs.tahunAkademik,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Get.to(() => DetailKhsPage(khs: khs));
        },
      ),
    );
  }
}
