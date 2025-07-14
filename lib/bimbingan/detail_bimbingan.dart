import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/models/bimbingan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailBimbinganPage extends StatelessWidget {
  final Bimbingan bimbingan;

  const DetailBimbinganPage({super.key, required this.bimbingan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Bimbingan - ${bimbingan.topik}"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Topik: ${bimbingan.topik}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
                "Tanggal Bimbingan: ${DateFormat('d MMMM yyyy', 'id_ID').format(bimbingan.tanggalBimbingan)}"),
            const SizedBox(height: 10),
            Text(
                "Dosen Pembimbing: ${bimbingan.dosen?.nama ?? 'Tidak diketahui'}"),
            const SizedBox(height: 10),
            if (bimbingan.catatan != null)
              Text("Catatan Dosen: ${bimbingan.catatan}"),
            const SizedBox(height: 10),
            Text("Status Bimbingan: ${bimbingan.status}"),
          ],
        ),
      ),
    );
  }
}
