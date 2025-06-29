import 'dart:convert';
import 'package:flutter_application_1/models/krs_detail_model.dart';

// Helper function
Krs krsFromJson(String str) => Krs.fromJson(json.decode(str));

class Krs {
  final int id;
  final int? semester;
  final String tahunAkademik;
  final String statusKrs;
  final DateTime createdAt;
  final List<KrsDetail> detail;

  Krs({
    required this.id,
    this.semester,
    required this.tahunAkademik,
    required this.statusKrs,
    required this.createdAt,
    required this.detail,
  });

  factory Krs.fromJson(Map<String, dynamic> json) {
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return Krs(
      id: json["id"],
      semester: safeParseInt(json["semester"]),
      tahunAkademik: json["tahun_akademik"],
      statusKrs: json["status_krs"],
      createdAt: DateTime.parse(json["created_at"]),

      // --- BAGIAN YANG DIPERBARUI ---
      // Tambahkan pengecekan null sebelum menjalankan .map()
      // Jika json["detail"] null atau tidak ada, kembalikan list kosong [].
      detail: json["detail"] == null
          ? []
          : List<KrsDetail>.from(
              json["detail"].map((x) => KrsDetail.fromJson(x))),
    );
  }
}
