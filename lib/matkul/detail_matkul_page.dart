import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/mata_kuliah_model.dart';

class DetailMatkulPage extends StatelessWidget {
  // Placeholder constructor, replace with actual parameters as needed
  final MataKuliah matkul;

  const DetailMatkulPage({super.key, required this.matkul});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Mata Kuliah"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nama Mata Kuliah: ${matkul.namaMatkul}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Kode Mata Kuliah: ${matkul.kode ?? 'N/A'}"),
            const SizedBox(height: 10),
            Text("SKS: ${matkul.sks}"),
            const SizedBox(height: 10),
            // Text("Deskripsi: ${matkul.deskripsi ?? 'Tidak ada deskripsi'}"),
          ],
        ),
      ),
    );
  }
}
