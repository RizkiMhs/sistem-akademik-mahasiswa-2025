import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/mata_kuliah_model.dart';
import 'package:flutter_application_1/utils/color.dart';

class DaftarMatkulSemesterPage extends StatelessWidget {
  final int semester;
  final List<MataKuliah> mataKuliahList;

  const DaftarMatkulSemesterPage({
    super.key,
    required this.semester,
    required this.mataKuliahList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Matakuliah Semester $semester", style: const TextStyle(color: Colors.white)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: mataKuliahList.length,
        itemBuilder: (context, index) {
          final matkul = mataKuliahList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: greencolor,
                child: Text(matkul.sks.toString(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(matkul.namaMatkul, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Kode: ${matkul.kode ?? 'N/A'}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Aksi saat item di-tap, misal ke halaman detail matkul
              },
            ),
          );
        },
      ),
    );
  }
}
