import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/infoakun/editakun.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DataDiri extends StatelessWidget {
  const DataDiri({super.key});

  // Helper widget untuk membuat setiap baris informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppinsmedium',
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: whitecolor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppinssemibold',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil AuthController yang sudah ada
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: greencolor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Data Diri",
          style: TextStyle(
            fontFamily: 'PoppinsBold',
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        // Gunakan Obx untuk memastikan UI selalu update jika data user berubah
        child: Obx(() {
          // Tampilkan loading jika data belum siap
          if (authController.currentUser.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ambil data user dari controller
          final user = authController.currentUser.value!;
          
          // Format tanggal lahir jika tidak null
          String tanggalLahirFormatted = "Tidak diisi";
          if (user.tanggalLahir != null && user.tanggalLahir!.isNotEmpty) {
            try {
              final date = DateTime.parse(user.tanggalLahir!);
              tanggalLahirFormatted = DateFormat('d MMMM yyyy', 'id_ID').format(date);
            } catch (e) {
              tanggalLahirFormatted = user.tanggalLahir!; // fallback ke string asli jika format salah
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Nama Lengkap", user.nama),
              _buildInfoRow("NIM", user.nim),
              _buildInfoRow("Email", user.email),
              _buildInfoRow("Jenis Kelamin", user.jenisKelamin ?? 'Tidak diisi'),
              _buildInfoRow("Tanggal Lahir", tanggalLahirFormatted),
              _buildInfoRow("No. HP", user.noHp ?? 'Tidak diisi'),
              _buildInfoRow("Alamat", user.alamat ?? 'Tidak diisi'),
              _buildInfoRow("Angkatan", user.angkatan?.toString() ?? 'Tidak diisi'),
              // Tampilkan NAMA dari objek relasi, bukan lagi ID
              _buildInfoRow("Program Studi", user.programStudi?.namaProdi ?? 'Tidak diisi'),
              _buildInfoRow("Dosen PA", user.dosen?.nama ?? 'Tidak diisi'),
            ],
          );
        }),
      ),
      bottomNavigationBar: _buildEditButton(context),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangecolor,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          // Aksi untuk pindah ke halaman edit data
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EditAkun()));
        },
        child: const Text(
          "Edit Data",
          style: TextStyle(
            fontFamily: 'Poppinssemibold',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
