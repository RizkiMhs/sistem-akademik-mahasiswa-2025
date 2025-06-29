import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_application_1/models/mahasiswa_model.dart'; // Model mahasiswa lengkap
import 'package:flutter_application_1/models/transkrip_model.dart';

class TranskripPdfGenerator {
  /// Fungsi utama untuk membuat dan menampilkan preview PDF Transkrip.
  static Future<void> generateAndPrintTranskrip(Transkrip transkrip, Mahasiswa user) async {
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
            _buildStudentInfo(user, transkrip, font, boldFont),
            pw.SizedBox(height: 15),
            ..._buildSemesterTables(transkrip.transkripInfo.nilaiPerSemester, font, boldFont),
            pw.SizedBox(height: 30),
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
              pw.Text('TRANSKRIP AKADEMIK', style: pw.TextStyle(font: boldFont, fontSize: 14)),
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

  /// Membangun bagian informasi mahasiswa dan ringkasan IPK
  static pw.Widget _buildStudentInfo(Mahasiswa user, Transkrip transkrip, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 2, borderStyle: pw.BorderStyle.solid),
        pw.SizedBox(height: 10),
        _buildInfoRow('Nama Mahasiswa', user.nama, font, boldFont),
        _buildInfoRow('NIM', user.nim, font, boldFont),
        _buildInfoRow('Program Studi', user.programStudi?.namaProdi ?? '-', font, boldFont),
        pw.SizedBox(height: 10),
        _buildInfoRow('Total SKS Lulus', '${transkrip.transkripInfo.totalSksLulus} SKS', font, boldFont),
        _buildInfoRow('Indeks Prestasi Kumulatif (IPK)', transkrip.transkripInfo.ipk, font, boldFont),
        pw.SizedBox(height: 10),
      ],
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10))),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 10))),
        ],
      ),
    );
  }

  /// Membangun daftar tabel untuk setiap semester
  static List<pw.Widget> _buildSemesterTables(List<NilaiSemester> nilaiPerSemester, pw.Font font, pw.Font boldFont) {
    // Urutkan semester dari yang terkecil ke terbesar
    nilaiPerSemester.sort((a, b) => a.semester.compareTo(b.semester));

    return nilaiPerSemester.map((semesterData) {
      final headers = ['No', 'Kode MK', 'Nama Mata Kuliah', 'SKS', 'Grade'];
      
      final data = semesterData.matakuliah.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final matkul = entry.value;
        return [
          index.toString(),
          matkul.kodeMatkul ?? '-',
          matkul.namaMatkul,
          matkul.sks.toString(),
          matkul.grade ?? '-',
        ];
      }).toList();

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 10),
          pw.Text("Semester ${semesterData.semester}", style: pw.TextStyle(font: boldFont, fontSize: 11)),
          pw.SizedBox(height: 5),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(font: boldFont, fontSize: 9, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
            cellStyle: pw.TextStyle(font: font, fontSize: 8),
            cellAlignments: {
              0: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
          ),
        ],
      );
    }).toList();
  }

  /// Membangun bagian tanda tangan
  static pw.Widget _buildSignatureSection(Mahasiswa user, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end, // Rata kanan
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('Lhokseumawe, ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text('Ketua Program Studi,', style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 60),
            pw.Text(
              'Nama Ketua Prodi, S.Kom., M.Kom.', // Placeholder
              style: pw.TextStyle(font: boldFont, fontSize: 10, decoration: pw.TextDecoration.underline),
            ),
            pw.Text(
              'NIP. 198001012005011001', // Placeholder
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}