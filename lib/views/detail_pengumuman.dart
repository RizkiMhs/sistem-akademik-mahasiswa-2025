import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/pengumuman_model.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:intl/intl.dart';

class DetailPengumumanPage extends StatelessWidget {
  final Pengumuman pengumuman;

  const DetailPengumumanPage({super.key, required this.pengumuman});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pengumuman.kategori, style: const TextStyle(color: Colors.white)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pengumuman.judul,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'PoppinsBold',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dipublikasikan pada: ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(pengumuman.createdAt)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 32),
            Text(
              pengumuman.isi,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                fontFamily: 'PoppinsRegular'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
