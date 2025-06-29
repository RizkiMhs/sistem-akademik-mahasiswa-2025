import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/matakuliah_controller.dart';
import 'package:flutter_application_1/models/mata_kuliah_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/views/daftar_matkul_semester.dart';
import 'package:get/get.dart';

class informasi extends StatelessWidget {
  const informasi({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final MataKuliahController matkulController =
        Get.put(MataKuliahController());

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoBox(),
            const SizedBox(height: 20),
            _buildSemesterList(context, matkulController),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        child: AppBar(
          backgroundColor: greencolor,
          automaticallyImplyLeading:
              false, // Menghilangkan tombol kembali default
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informasi Matakuliah",
                        style: TextStyle(
                            fontFamily: 'PoppinsBold',
                            fontSize: 22,
                            color: Colors.white),
                      ),
                      Text(
                        "Universitas Malikussaleh",
                        style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            fontSize: 13,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgcolor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "Informasi Matakuliah Ditawarkan berisi seluruh matakuliah yang ditawarkan pada semester aktif. Setiap matakuliah mempunyai aturan tersendiri bergantung pada program studi dan kurikulum. Untuk lebih jelasnya, anda dapat melihat detil kelas.",
        style: TextStyle(fontSize: 12, color: Colors.black87),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildSemesterList(
      BuildContext context, MataKuliahController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(children: [
            Expanded(child: Divider(color: orangecolor, thickness: 1)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Semua Matakuliah Yang Ditawarkan",
                  style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 12)),
            ),
            Expanded(child: Divider(color: orangecolor, thickness: 1)),
          ]),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.groupedMataKuliah.isEmpty) {
            return const Center(child: Text("Tidak ada data mata kuliah."));
          }

          final semesters = controller.groupedMataKuliah.keys.toList()..sort();

          // Menggunakan Column dan for-loop untuk membuat setiap tombol secara eksplisit
          return Column(
            children: [
              for (int i = 0; i < semesters.length; i++)
                _buildSemesterButton(
                  context,
                  semesters[i],
                  controller.groupedMataKuliah[semesters[i]]!,
                  i.isEven,
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSemesterButton(BuildContext context, int semester,
      List<MataKuliah> matkulList, bool isGreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isGreen ? greencolor : orangecolor,
          minimumSize: const Size(double.infinity, 53),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Get.to(() => DaftarMatkulSemesterPage(
              semester: semester, mataKuliahList: matkulList));
        },
        child: Text(
          "Semester $semester",
          style: const TextStyle(
              fontFamily: 'Poppinssemibold', fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
