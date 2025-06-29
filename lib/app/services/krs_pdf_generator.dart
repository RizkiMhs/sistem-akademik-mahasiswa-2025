import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_application_1/models/mahasiswa_model.dart';
import 'package:flutter_application_1/models/krs_model.dart';


class KrsPdfGenerator {
  /// Fungsi utama untuk membuat dan menampilkan preview PDF KRS.
  static Future<void> generateAndPrintKrs(Krs krs, Mahasiswa user) async {
    // Tampilkan dialog loading saat PDF sedang dibuat
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final doc = pw.Document();

      // Load font dan logo
      final font = await PdfGoogleFonts.poppinsRegular();
      final boldFont = await PdfGoogleFonts.poppinsBold();
      final logo = pw.MemoryImage(
        (await rootBundle.load('asset/image/ic_launcher.png')).buffer.asUint8List(),
      );

      // Tambahkan halaman ke dokumen
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader(logo, font, boldFont),
            pw.SizedBox(height: 20),
            _buildStudentInfo(user, krs, font, boldFont),
            pw.SizedBox(height: 20),
            _buildKrsTable(krs, font, boldFont),
            pw.SizedBox(height: 40),
            _buildSignatureSection(user, font, boldFont),
          ],
        ),
      );
      
      // Tutup dialog loading
      Get.back();

      // Tampilkan layar preview cetak
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );

    } catch (e) {
      Get.back(); // Tutup dialog loading jika terjadi error
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
              pw.Text('KARTU RENCANA STUDI (KRS)', style: pw.TextStyle(font: boldFont, fontSize: 14)),
              pw.Text('UNIVERSITAS MALIKUSSALEH', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              pw.Text(
                'Jl. Cot Teungku Nie, Reuleut, Kec. Muara Batu, Kabupaten Aceh Utara, Aceh',
                style: pw.TextStyle(font: font, fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 80), // Spacer agar judul tetap di tengah
      ],
    );
  }

  /// Membangun bagian informasi mahasiswa
  static pw.Widget _buildStudentInfo(Mahasiswa user, Krs krs, pw.Font font, pw.Font boldFont) {
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
        _buildInfoRow('Tahun Akademik', krs.tahunAkademik, font, boldFont),
        _buildInfoRow('Semester', krs.semester?.toString() ?? 'N/A', font, boldFont),
        pw.SizedBox(height: 10),
      ],
    );
  }
  
  /// Helper untuk membuat baris info (Label: Value)
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
          ),
          pw.Text(': ', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: boldFont, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  /// Membangun tabel daftar mata kuliah
  static pw.Widget _buildKrsTable(Krs krs, pw.Font font, pw.Font boldFont) {
    final headers = ['No', 'Kode MK', 'Nama Mata Kuliah', 'SKS', 'Jadwal', 'Dosen'];
    
    // Siapkan data untuk tabel
    final data = krs.detail.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final d = entry.value;
      final matkul = d.jadwalKuliah.kelas?.mataKuliah;
      final jadwal = d.jadwalKuliah;
      final dosen = d.jadwalKuliah.kelas?.dosen;
      return [
        index.toString(),
        matkul?.kode ?? '-',
        matkul?.namaMatkul ?? '-',
        matkul?.sks.toString() ?? '-',
        '${jadwal.hari}, ${jadwal.jamMulai.substring(0, 5)}',
        dosen?.nama ?? '-',
      ];
    }).toList();

    // Hitung total SKS
    final totalSks = krs.detail.fold(0, (sum, detail) => sum + (detail.jadwalKuliah.kelas?.mataKuliah?.sks ?? 0));
    
    // [FIXED] Dibungkus dalam pw.Column
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Tabel utama
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
          cellStyle: pw.TextStyle(font: font, fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.center,
            3: pw.Alignment.center,
          },
          border: pw.TableBorder.all(),
        ),
        // Tabel untuk Total SKS
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.76),    // Kolom kosong
          },
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Total SKS Diambil', style: pw.TextStyle(font: boldFont, fontSize: 10), textAlign: pw.TextAlign.right),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(totalSks.toString(), style: pw.TextStyle(font: boldFont, fontSize: 10), textAlign: pw.TextAlign.center),
                ),
                pw.Container(), // Kolom kosong untuk sisa space
              ]
            )
          ]
        )
      ]
    );
  }

  /// Membangun bagian tanda tangan
  static pw.Widget _buildSignatureSection(Mahasiswa user, pw.Font font, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(width: 150), // Spacer kiri
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('Lhokseumawe, ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 10)),
            pw.Text('Mahasiswa Yang Bersangkutan,', style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 60),
            pw.Text(
              user.nama,
              style: pw.TextStyle(font: boldFont, fontSize: 10, decoration: pw.TextDecoration.underline),
            ),
            pw.Text(
              'NIM: ${user.nim}',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}