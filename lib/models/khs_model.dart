import 'dart:convert';
import 'package:flutter_application_1/models/khs_detail_model.dart';

// Helper function untuk decode list dari JSON
List<Khs> khsFromJson(String str) => List<Khs>.from(json.decode(str).map((x) => Khs.fromJson(x)));

class Khs {
  final int id;
  final int semester;
  final String tahunAkademik;
  final String? ips; // Indeks Prestasi Semester
  final String? ipk; // Indeks Prestasi Kumulatif
  final int sksSemester; // Total SKS di semester ini
  final List<KhsDetail> details;

  Khs({
    required this.id,
    required this.semester,
    required this.tahunAkademik,
    this.ips,
    this.ipk,
    required this.sksSemester,
    required this.details,
  });

  factory Khs.fromJson(Map<String, dynamic> json) {
    return Khs(
      id: json["id"],
      semester: json["semester"],
      tahunAkademik: json["tahun_akademik"],
      ips: json["ips"],
      ipk: json["ipk"],
      sksSemester: json["sks_semester"] ?? 0,
      details: json["details"] == null
          ? []
          : List<KhsDetail>.from(json["details"].map((x) => KhsDetail.fromJson(x))),
    );
  }
}
