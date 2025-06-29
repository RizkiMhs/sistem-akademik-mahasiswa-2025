import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/jadwal_kuliah_model.dart';
import 'package:flutter_application_1/utils/color.dart';

class DetailJadwalHarianPage extends StatelessWidget {
  final String hari;
  final List<JadwalKuliah> jadwalList;

  const DetailJadwalHarianPage({
    super.key,
    required this.hari,
    required this.jadwalList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: greencolor,
        title: Text("Jadwal Hari $hari", style: const TextStyle(color: Colors.white, fontFamily: 'PoppinsBold')),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: jadwalList.length,
        itemBuilder: (context, index) {
          final jadwal = jadwalList[index];
          final matkul = jadwal.kelas?.mataKuliah;
          final dosen = jadwal.kelas?.dosen;
          final jam = "${jadwal.jamMulai?.substring(0, 5)} - ${jadwal.jamSelesai?.substring(0, 5)}";

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matkul?.namaMatkul ?? 'Mata Kuliah Tidak Ditemukan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF005A24),
                  ),
                ),
                const Divider(height: 16),
                _buildInfoRow(Icons.schedule, jam),
                _buildInfoRow(Icons.location_on_outlined, "Ruang: ${jadwal.ruangan}"),
                _buildInfoRow(Icons.person_outline, dosen?.nama ?? 'N/A'),
                _buildInfoRow(Icons.library_books_outlined, "${matkul?.sks ?? 0} SKS - ${matkul?.kode ?? 'N/A'}"),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 16),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
