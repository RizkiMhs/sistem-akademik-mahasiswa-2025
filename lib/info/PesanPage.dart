import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/info/chat_page.dart'; // [PENTING] Ganti dengan path ChatPage Anda
import 'package:flutter_application_1/infoakun/infoakun.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/views/homepage.dart';

class PesanPage extends StatefulWidget {
  const PesanPage({super.key});

  @override
  State<PesanPage> createState() => _PesanPageState();
}

class _PesanPageState extends State<PesanPage> {
  // Ambil instance AuthController yang sudah ada
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    // Ambil data dosen dari controller
    final dosen = authController.currentUser.value?.dosen;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(15)),
          child: AppBar(
            backgroundColor: greencolor,
            automaticallyImplyLeading: false,
            flexibleSpace: const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Pesan",
                    style: TextStyle(
                        fontFamily: 'PoppinsBold',
                        fontSize: 25,
                        color: Color(0xFFFFFFFF)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Text(
                      "Universitas Malikussaleh",
                      style: TextStyle(
                          fontFamily: 'PoppinsRegular',
                          fontSize: 14,
                          color: Color(0xFFFFFFFF)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Cek apakah mahasiswa punya dosen wali
            if (dosen != null)
              _buildConversationCard(
                context: context,
                dosenNama: dosen.nama,
                dosenId: dosen.id,
                dosenFotoUrl: dosen.foto, // Gunakan foto asli jika ada
              )
            else
              _buildNoConversationCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Widget untuk menampilkan item percakapan dengan Dosen Wali
  Widget _buildConversationCard({
    required BuildContext context,
    required String dosenNama,
    required int dosenId,
    String? dosenFotoUrl,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman chat dengan membawa data dosen
        Get.to(() => ChatPage(
              partnerId: dosenId,
              partnerName: dosenNama,
            ));
      },
      child: Container(
        width: double.infinity,
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white, // Ganti bgcolor dengan white untuk kontras
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              )
            ]),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: greencolor.withOpacity(0.1),
              // Tampilkan foto dosen jika ada, jika tidak, tampilkan inisial
              backgroundImage:
                  (dosenFotoUrl != null) ? NetworkImage(dosenFotoUrl) : null,
              child: (dosenFotoUrl == null)
                  ? Text(
                      dosenNama.isNotEmpty ? dosenNama[0].toUpperCase() : 'D',
                      style: TextStyle(fontSize: 24, color: greencolor),
                    )
                  : null,
            ),
            const SizedBox(width: 19),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dosenNama, // Nama Dosen Wali Dinamis
                    style: const TextStyle(
                        fontFamily: 'Poppinsmedium', fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Dosen Pembimbing Akademik", // Subtitle
                    style: TextStyle(
                        fontFamily: 'Poppinsmedium',
                        fontSize: 12,
                        color: Colors.grey),
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

  /// Widget yang ditampilkan jika tidak ada dosen pembimbing
  Widget _buildNoConversationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          "Dosen Pembimbing Akademik Anda belum diatur. Silakan hubungi admin prodi.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  /// Widget untuk Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFFFF9100),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(
              context, 'asset/image/Circled Envelope (1).png', const PesanPage(),
              isCentral: true),
          _buildNavBarItem(context, 'asset/image/Home (1).png', const Homepage()),
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
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => destinationPage));
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
