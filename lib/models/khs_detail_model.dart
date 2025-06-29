import 'package:flutter_application_1/models/mata_kuliah_model.dart';

class KhsDetail {
  final int id;
  final String? nilai;
  final String? grade;
  final MataKuliah? mataKuliah;

  KhsDetail({
    required this.id,
    this.nilai,
    this.grade,
    this.mataKuliah,
  });

  factory KhsDetail.fromJson(Map<String, dynamic> json) {
    return KhsDetail(
      id: json["id"] ?? 0,
      nilai: json["nilai"],
      grade: json["grade"],
      mataKuliah: json["mata_kuliah"] == null
          ? null
          : MataKuliah.fromJson(json["mata_kuliah"]),
    );
  }
}
