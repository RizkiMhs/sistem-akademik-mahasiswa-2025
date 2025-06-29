import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/krs/krs.dart'; // <-- Pastikan Anda sudah mengganti nama file ini
import 'package:flutter_application_1/utils/color.dart';
// controller
import 'package:flutter_application_1/app/controllers/krs_controller.dart';
import 'package:flutter_application_1/krs/cetakkrs.dart';
import 'package:get/get.dart';

class KrsMenu extends StatelessWidget {
  const KrsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller untuk menampilkan data mahasiswa yang login
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Gunakan Obx untuk menampilkan data mahasiswa secara dinamis
            Obx(() {
              if (authController.currentUser.value == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildInfoCard(authController);
            }),
            const SizedBox(height: 30),
            _buildActionButton(
              label: 'Pilih Matakuliah',
              onTap: () {
                // Arahkan ke halaman pengisian KRS (checkbox)
                Get.to(() => const IsiKrsPage());
              },
            ),
            const SizedBox(height: 15),
            _buildActionButton(
              label: 'Lihat & Cetak KRS',
              onTap: () {
                // Arahkan ke halaman CetakKrsPage yang sudah kita buat
                Get.to(() => const CetakKrsPage());
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        elevation: 0,
        backgroundColor: greencolor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Kartu Rencana Studi",
          style: TextStyle(fontFamily: 'PoppinsBold', color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildInfoCard(AuthController controller) {
    final user = controller.currentUser.value!;
    // Di sini Anda bisa menambahkan logika untuk mengambil semester aktif dari KrsController jika perlu
    final KrsController krsController = Get.put(KrsController(), permanent: true);


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: orangecolor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() => Column(
          children: [
            _infoRow('Nama', user.nama),
            _divider(),
            _infoRow('NIM', user.nim),
            _divider(),
            _infoRow('Program Studi', user.programStudi?.namaProdi ?? 'N/A'),
            _divider(),
            _infoRow('Semester', krsController.tahunAkademikAktif.value.isNotEmpty ? krsController.tahunAkademikAktif.value : 'Loading...'),
            _divider(),
            _infoRow('Dosen Wali', user.dosen?.nama ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Poppinssemibold', fontSize: 14, color: Colors.white)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontFamily: 'Poppinssemibold', fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.white.withOpacity(0.3), height: 1);

  Widget _buildActionButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xff005A24),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Poppinsmedium', fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
