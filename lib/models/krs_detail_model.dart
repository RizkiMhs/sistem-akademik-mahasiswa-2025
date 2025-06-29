import 'package:flutter_application_1/models/jadwal_kuliah_model.dart';

class KrsDetail {
  final int id;
  final JadwalKuliah jadwalKuliah;

  KrsDetail({
    required this.id,
    required this.jadwalKuliah,
  });

  factory KrsDetail.fromJson(Map<String, dynamic> json) {
    return KrsDetail(
      id: json["id"],
      jadwalKuliah: JadwalKuliah.fromJson(json["jadwal_kuliah"]),
    );
  }
}
