import 'package:flutter/material.dart';
import 'package:flutter_application_1/info/PesanPage.dart';
import 'package:flutter_application_1/info/pesan.dart';
import 'package:flutter_application_1/infoakun/datadiri.dart';
import 'package:flutter_application_1/infoakun/ubahsandi.dart';
import 'package:flutter_application_1/utils/color.dart'; // Pastikan file ini ada
import 'package:flutter_application_1/views/homepage.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';

// Mengubah menjadi StatelessWidget untuk efisiensi karena state dikelola oleh GetX
class InfoAkun extends StatelessWidget {
  const InfoAkun({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil instance AuthController di dalam build method
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 34),
            // Widget untuk header profil yang sekarang dinamis
            _buildProfileHeader(authController),
            const SizedBox(height: 20),
            _buildStatusMahasiswa(),
            const SizedBox(height: 10),
            // Menu item yang lebih rapi
            _buildMenuItem(
              context: context,
              icon: 'asset/image/User Folder.png',
              title: "Data Diri",
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const DataDiri()));
              },
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              context: context,
              icon:
                  'asset/image/User Folder.png', // Ganti dengan ikon yang sesuai jika ada
              title: "Ubah Password",
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UbahSandi()));
              },
            ),
            const SizedBox(height: 20),
            // Tombol keluar yang sudah diperbaiki
            _buildLogoutButton(context, authController),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Widget untuk AppBar yang dibuat terpisah agar rapi
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        child: AppBar(
          backgroundColor: greencolor,
          automaticallyImplyLeading: false,
          flexibleSpace: const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Informasi Akun",
                  style: TextStyle(
                      fontFamily: 'PoppinsBold',
                      fontSize: 25,
                      color: Colors.white),
                ),
                Text(
                  "Universitas Malikussaleh",
                  style: TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 14,
                      color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk menampilkan header profil yang dinamis
  Widget _buildProfileHeader(AuthController authController) {
    return Container(
      width: double.infinity,
      height: 113,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: orangecolor,
      ),
      // Obx akan otomatis me-rebuild widget ini jika data currentUser berubah
      child: Obx(() {
        final user = authController.currentUser.value;
        // Tampilkan loading jika data belum ada
        if (user == null) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        return Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage:
                  (user.fotoUrl != null && user.fotoUrl!.isNotEmpty)
                      ? NetworkImage(user.fotoUrl!)
                      : const AssetImage('asset/image/profile.png')
                          as ImageProvider,
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 12,
                      color: Colors.white),
                ),
                Text(
                  user.nama, // <-- Data dinamis dari controller
                  style: const TextStyle(
                      fontFamily: 'Poppinsmedium',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  user.nim, // <-- Data dinamis dari controller
                  style: const TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 12,
                      color: Colors.white),
                ),
              ],
            )
          ],
        );
      }),
    );
  }

  /// Widget untuk menampilkan status mahasiswa
  Widget _buildStatusMahasiswa() {
    return Container(
      width: double.infinity,
      height: 53,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: whitecolor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Status Mahasiswa",
            style: TextStyle(fontFamily: 'Poppinssemibold', fontSize: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: greencolor),
            ),
            child: const Center(
                child: Text(
                    "Aktif")), // <-- Status masih statis, bisa diubah nanti jika ada data dari API
          ),
        ],
      ),
    );
  }

  /// Widget generik untuk membuat item menu
  Widget _buildMenuItem(
      {required BuildContext context,
      required String icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 53,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(left: 10, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: whitecolor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(icon,
                    width: 24, height: 24), // Ukuran ikon disesuaikan
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontFamily: 'Poppinssemibold', fontSize: 16),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Widget untuk tombol keluar
  Widget _buildLogoutButton(
      BuildContext context, AuthController authController) {
    return GestureDetector(
      onTap: () {
        // Gunakan Get.defaultDialog untuk dialog yang lebih konsisten dengan GetX
        Get.defaultDialog(
          title: "Konfirmasi Keluar",
          middleText: "Apakah Anda yakin ingin keluar?",
          textConfirm: "Ya, Keluar",
          textCancel: "Batal",
          confirmTextColor: Colors.white,
          onConfirm: () {
            // Panggil metode logout dari controller, BUKAN FirebaseAuth
            authController.logout();
          },
        );
      },
      child: Container(
        width: double.infinity,
        height: 53,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: Center(
          child: Text(
            "Keluar",
            style: TextStyle(
                fontFamily: 'Poppinssemibold', fontSize: 18, color: whitecolor),
          ),
        ),
      ),
    );
  }

  /// Widget untuk Bottom Navigation Bar, dibuat terpisah agar rapi
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: orangecolor,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Image.asset('asset/image/Circled Envelope.png'),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PesanPage())),
          ),
          IconButton(
            icon: Image.asset('asset/image/Home (1).png'),
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Homepage())),
          ),
          // Tombol Akun yang aktif
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15), blurRadius: 6)
                ]),
            child: Center(
                child:
                    Image.asset('asset/image/User.png', width: 28, height: 28)),
          ),
        ],
      ),
    );
  }
}
