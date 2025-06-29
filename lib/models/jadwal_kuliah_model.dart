import 'package:flutter_application_1/models/kelas_model.dart';

class JadwalKuliah {
  final int id;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String ruangan;
  final String tahunAkademik;
  final int kuota;
  final Kelas? kelas;

  JadwalKuliah({
    required this.id,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    required this.tahunAkademik,
    required this.kuota,
    this.kelas,
  });

  factory JadwalKuliah.fromJson(Map<String, dynamic> json) {
    int? safeParseInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        return int.tryParse(value.toString());
    }
    
    return JadwalKuliah(
      id: json['id'],
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      ruangan: json['ruangan'],
      tahunAkademik: json['tahun_akademik'],
      kuota: safeParseInt(json['kuota']) ?? 0,
      kelas: json['kelas'] != null ? Kelas.fromJson(json['kelas']) : null,
    );
  }
}
