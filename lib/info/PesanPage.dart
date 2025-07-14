import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/app/controllers/dosen_controller.dart';
import 'package:flutter_application_1/info/chat_page.dart';
import 'package:flutter_application_1/infoakun/infoakun.dart';
import 'package:flutter_application_1/models/dosen_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/views/homepage.dart';

class PesanPage extends StatelessWidget {
  const PesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi kedua controller
    final AuthController authController = Get.find();
    final DosenController dosenController = Get.put(DosenController());
    final dosenPA = authController.currentUser.value?.dosen;

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (dosenController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter daftar dosen untuk menghilangkan DPA (jika ada) dari daftar umum
        final otherDosenList = dosenController.dosenList
            .where((dosen) => dosen.id != dosenPA?.id)
            .toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // Tampilkan Dosen Pembimbing Akademik di bagian atas
            if (dosenPA != null)
              _buildSectionTitle("Dosen Pembimbing Akademik"),
            if (dosenPA != null)
              _buildConversationCard(
                dosen: dosenPA,
                isDPA: true,
              ),
            if (dosenPA != null)
              const Divider(height: 30, indent: 20, endIndent: 20),

            // Tampilkan daftar semua dosen lainnya
            _buildSectionTitle("Semua Dosen"),
            if (otherDosenList.isEmpty)
              _buildNoConversationCard("Tidak ada data dosen lain.")
            else
              ...otherDosenList
                  .map((dosen) => _buildConversationCard(dosen: dosen))
                  .toList(),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  /// Widget untuk menampilkan item percakapan
  Widget _buildConversationCard({required Dosen dosen, bool isDPA = false}) {
    return InkWell(
      onTap: () {
        Get.to(() => ChatPage(
              partnerId: dosen.id,
              partnerName: dosen.nama,
            ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: greencolor.withOpacity(0.1),
              // Anda perlu menambahkan foto_url ke Dosen model jika ingin menampilkan foto
              backgroundImage: (dosen.fotoUrl != null)
                  ? NetworkImage(dosen.fotoUrl!)
                  : const AssetImage('asset/image/profile.png')
                      as ImageProvider,

              // child: Text(
              //   dosen.nama.isNotEmpty ? dosen.nama[0].toUpperCase() : 'D',
              //   style: TextStyle(fontSize: 24, color: greencolor, fontWeight: FontWeight.bold),
              // ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dosen.nama,
                    style: const TextStyle(
                        fontFamily: 'Poppinsmedium',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDPA
                        ? "Dosen Pembimbing Akademik"
                        : (dosen.nip ?? "Dosen"),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _buildNoConversationCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        backgroundColor: greencolor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Pesan",
          style: TextStyle(
              fontFamily: 'PoppinsBold', fontSize: 25, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFFFF9100),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(context, 'asset/image/Circled Envelope (1).png',
              const PesanPage(),
              isCentral: true),
          _buildNavBarItem(
              context, 'asset/image/Home (1).png', const Homepage()),
          _buildNavBarItem(
              context, 'asset/image/Male User.png', const InfoAkun()),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(
      BuildContext context, String assetPath, Widget destinationPage,
      {bool isCentral = false}) {
    return GestureDetector(
      onTap: () {
        if (isCentral) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => destinationPage));
      },
      child: isCentral
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15), blurRadius: 6)
                ],
              ),
              child:
                  Center(child: Image.asset(assetPath, width: 28, height: 28)),
            )
          : Image.asset(assetPath, width: 32, height: 32),
    );
  }
}
