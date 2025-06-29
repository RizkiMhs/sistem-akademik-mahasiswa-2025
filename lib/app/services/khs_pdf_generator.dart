import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_application_1/models/mahasiswa_model.dart';
import 'package:flutter_application_1/models/khs_model.dart';

class KhsPdfGenerator {
  /// Fungsi utama untuk membuat dan menampilkan preview PDF KHS.
  static Future<void> generateAndPrintKhs(Khs khs, Mahasiswa user) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final doc = pw.Document();

      // Load assets
      final font = await PdfGoogleFonts.poppinsRegular();
      final boldFont = await PdfGoogleFonts.poppinsBold();
      final logo = pw.MemoryImage(
        (await rootBundle.load('asset/image/logo_unimal.png')).buffer.asUint8List(),
      );

      // Tambahkan halaman ke dokumen
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader(logo, font, boldFont),
            pw.SizedBox(height: 20),
            _buildStudentInfo(user, khs, font, boldFont),
            pw.SizedBox(height: 20),
            _buildKhsTable(khs, font, boldFont),
            pw.SizedBox(height: 40),
            _buildSignatureSection(user, font, boldFont),
          ],
        ),
      );
      
      Get.back(); // Tutup dialog loading

      // Tampilkan layar preview cetak
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );

    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Gagal membuat PDF: ${e.toString()}");
    }
  }

  /// Membangun bagian header dokumen (Logo dan Judul)
  static pw.Widget _buildHeader(pw.MemoryImage logo, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: 60, height: 60),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('KARTU HASIL STUDI (KHS)', style: pw.TextStyle(font: boldFont, fontSize: 14)),
              pw.Text('UNIVERSITAS MALIKUSSALEH', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              pw.Text(
                'Jl. Cot Teungku Nie, Reuleut, Kec. Muara Batu, Kabupaten Aceh Utara, Aceh',
                style: pw.TextStyle(font: font, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 80),
      ],
    );
  }

  /// Membangun bagian informasi mahasiswa
  static pw.Widget _buildStudentInfo(Mahasiswa user, Khs khs, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 2, borderStyle: pw.BorderStyle.solid),
        pw.SizedBox(height: 10),
        _buildInfoRow('Nama Mahasiswa', user.nama, font, boldFont),
        _buildInfoRow('NIM', user.nim, font, boldFont),
        _buildInfoRow('Program Studi', user.programStudi?.namaProdi ?? '-', font, boldFont),
        _buildInfoRow('Dosen Pembimbing', user.dosen?.nama ?? '-', font, boldFont),
        pw.SizedBox(height: 5),
        _buildInfoRow('Tahun Akademik', khs.tahunAkademik, font, boldFont),
        _buildInfoRow('Semester', khs.semester.toString(), font, boldFont),
        pw.SizedBox(height: 10),
      ],
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 10))),
        ],
      ),
    );
  }

  /// Membangun tabel KHS dan ringkasannya
  static pw.Widget _buildKhsTable(Khs khs, pw.Font font, pw.Font boldFont) {
    final headers = ['No', 'Kode MK', 'Nama Mata Kuliah', 'SKS', 'Nilai', 'Grade'];
    
    final data = khs.details.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final d = entry.value;
      return [
        index.toString(),
        d.mataKuliah?.kode ?? '-',
        d.mataKuliah?.namaMatkul ?? '-',
        d.mataKuliah?.sks.toString() ?? '-',
        d.nilai ?? '-',
        d.grade ?? '-',
      ];
    }).toList();

    final totalSks = khs.details.fold(0, (sum, detail) => sum + (detail.mataKuliah?.sks ?? 0));
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
          cellStyle: pw.TextStyle(font: font, fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.center,
            3: pw.Alignment.center,
            4: pw.Alignment.center,
            5: pw.Alignment.center,
          },
          border: pw.TableBorder.all(),
        ),
        // Ringkasan IPS dan IPK
        pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 10, right: 5),
          child: pw.SizedBox(
            width: 250,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Total SKS Semester', totalSks.toString(), font, boldFont),
                _buildInfoRow('Indeks Prestasi Semester (IPS)', khs.ips ?? '0.00', font, boldFont),
                _buildInfoRow('Indeks Prestasi Kumulatif (IPK)', khs.ipk ?? '0.00', font, boldFont),
              ],
            ),
          )
        ),
      ]
    );
  }

  /// Membangun bagian tanda tangan
  static pw.Widget _buildSignatureSection(Mahasiswa user, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(width: 150),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('Lhokseumawe, ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text('Dosen Pembimbing Akademik,', style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 60),
            pw.Text(
              user.dosen?.nama ?? '___________________',
              style: pw.TextStyle(font: boldFont, fontSize: 10, decoration: pw.TextDecoration.underline),
            ),
            pw.Text(
              'NIP. ${user.dosen?.nip ?? '........................'}',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}