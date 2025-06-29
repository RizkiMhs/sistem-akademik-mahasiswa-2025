import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/app/controllers/pengumuman_controller.dart';
import 'package:flutter_application_1/info/PesanPage.dart';
import 'package:flutter_application_1/info/pesan.dart';
import 'package:flutter_application_1/infoakun/infoakun.dart';
import 'package:flutter_application_1/jadwal%20kuliah/menu_jadwal.dart';
import 'package:flutter_application_1/krs/krs.dart';
import 'package:flutter_application_1/khs/infokhs.dart';
import 'package:flutter_application_1/krs/krsmenu.dart';
import 'package:flutter_application_1/saran/saran.dart';
import 'package:flutter_application_1/tagihan/tagihan.dart';
import 'package:flutter_application_1/trNilai/transkipnilai.dart';
import 'package:flutter_application_1/trNilai/trnilai.dart';
import 'package:flutter_application_1/bimbingan/bimbingan.dart';

import 'package:flutter_application_1/bahan%20kuliah/bahankuliah.dart';
import 'package:flutter_application_1/models/pengumuman_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/views/detail_pengumuman.dart';
import 'package:flutter_application_1/views/informasi_matkul.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Model data untuk item menu
class MenuItem {
  final String assetPath;
  final String title;
  final Widget destinationPage;
  final Color color;

  MenuItem({
    required this.assetPath,
    required this.title,
    required this.destinationPage,
    required this.color,
  });
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller. find() untuk yang sudah ada, put() untuk yang baru.
    final AuthController authController = Get.find<AuthController>();
    final PengumumanController pengumumanController =
        Get.put(PengumumanController());

    final List<MenuItem> academicMenus = [
      MenuItem(
          assetPath: 'asset/image/Vector.png',
          title: 'Jadwal\nKuliah',
          destinationPage: const JadwalKuliahPage(),
          color: const Color(0xFF00712D)),
      MenuItem(
          assetPath: 'asset/image/School.png',
          title: 'Bimbingan\nAkademik',
          destinationPage: const BimbinganHistoryPage(),
          color: const Color(0xFFFF9100)),
      MenuItem(
          assetPath: 'asset/image/Exam.png',
          title: 'Transkrip\nNilai',
          destinationPage: const TranskipNilaiPage(),
          color: const Color(0xFF00712D)),
      MenuItem(
          assetPath: 'asset/image/Book Reading.png',
          title: 'Informasi\nMatakuliah',
          destinationPage: const informasi(),
          color: const Color(0xFFFF9100)),
      MenuItem(
          assetPath: 'asset/image/Ereader.png',
          title: 'Kartu\nRencana\nStudi',
          destinationPage: const KrsMenu(),
          color: const Color(0xFF00712D)),
      MenuItem(
          assetPath: 'asset/image/Knowledge Sharing.png',
          title: 'Kartu Hasil\nStudi',
          destinationPage: const InfoKhs(),
          color: const Color(0xFFFF9100)),
      // MenuItem(
      //     assetPath: 'asset/image/Info Popup.png',
      //     title: 'Kritik\nDan Saran',
      //     destinationPage: const Saran(),
      //     color: const Color(0xFF00712D)),
      // MenuItem(
      //     assetPath: 'asset/image/Order Completed.png',
      //     title: 'Tagihan\nUKT',
      //     destinationPage: const Tagihan(),
      //     color: const Color(0xFFFF9100)),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: pengumumanController.fetchPengumuman,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Obx(() {
                if (authController.currentUser.value == null) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator()));
                }
                return _buildProfileHeader(authController);
              }),
              _buildMenuSectionTitle('Menu Akademik'),
              _buildAcademicMenu(context, academicMenus),
              const SizedBox(
                  height: 25), // Jarak antara menu dan judul pengumuman
              _buildMenuSectionTitle('Pengumuman'),

              Obx(() {
                if (pengumumanController.isLoading.value &&
                    pengumumanController.pengumumanList.isEmpty) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator()));
                }
                if (pengumumanController.pengumumanList.isEmpty) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text("Belum ada pengumuman.")));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.zero, // Hapus padding default dari ListView
                  itemCount: pengumumanController.pengumumanList.length,
                  itemBuilder: (context, index) {
                    final pengumuman =
                        pengumumanController.pengumumanList[index];
                    return _buildAnnouncementCard(context, pengumuman);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 81,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF00712D),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text('Sistem Akademik',
              style: TextStyle(
                  fontFamily: 'Poppinsmedium',
                  fontSize: 16,
                  color: Colors.white)),
          Text('Universitas Malikussaleh',
              style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 12,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthController authController) {
    final user = authController.currentUser.value!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: const Color(0xFFFF9100),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.5,
            backgroundColor: Colors.white,
            backgroundImage: user.fotoUrl != null && user.fotoUrl!.isNotEmpty
                ? NetworkImage(user.fotoUrl!)
                : const AssetImage('asset/image/profile.png') as ImageProvider,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selamat Datang',
                  style: TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 12,
                      color: Colors.white)),
              Text(user.nama,
                  style: const TextStyle(
                      fontFamily: 'Poppinsmedium',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text(user.nim,
                  style: const TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 12,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
            fontFamily: 'Poppinsmedium',
            fontSize: 16,
            color: Color(0xFF00712D),
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAcademicMenu(BuildContext context, List<MenuItem> menus) {
    return SizedBox(
      height: 122,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: menus.length,
        padding: const EdgeInsets.only(left: 20, right: 5),
        itemBuilder: (context, index) {
          final menu = menus[index];
          return _buildMenuItem(
              context: context,
              assetPath: menu.assetPath,
              title: menu.title,
              destinationPage: menu.destinationPage,
              color: menu.color);
        },
      ),
    );
  }

  Widget _buildMenuItem(
      {required BuildContext context,
      required String assetPath,
      required String title,
      required Widget destinationPage,
      required Color color}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => destinationPage));
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 15),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, width: 50, height: 50),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Poppinsmedium',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Pengumuman pengumuman) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DetailPengumumanPage(pengumuman: pengumuman));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(
            20, 0, 20, 15), // Jarak antar kartu pengumuman
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBE6),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pengumuman.judul,
                    style: const TextStyle(
                        fontFamily: 'Poppinsmedium',
                        fontSize: 16,
                        color: Color(0xFF00712D),
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF00712D),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(pengumuman.kategori,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Diterbitkan: ${DateFormat('d MMM y', 'id_ID').format(pengumuman.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              pengumuman.isi,
              style: const TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontSize: 13,
                  color: Colors.black87),
              textAlign: TextAlign.justify,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
          _buildNavBarItem(
              context, 'asset/image/Circled Envelope.png', const PesanPage()),
          _buildNavBarItem(context, 'asset/image/Home.png', const Homepage(),
              isCentral: true),
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
