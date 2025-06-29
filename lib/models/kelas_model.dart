import 'package:flutter_application_1/models/dosen_model.dart';
import 'package:flutter_application_1/models/mata_kuliah_model.dart';

class Kelas {
  final int id;
  final String namaKelas;
  final MataKuliah? mataKuliah;
  final Dosen? dosen;

  Kelas({
    required this.id,
    required this.namaKelas,
    this.mataKuliah,
    this.dosen,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      id: json['id'],
      namaKelas: json['nama_kelas'],
      mataKuliah: json['mata_kuliah'] != null
          ? MataKuliah.fromJson(json['mata_kuliah'])
          : null,
      dosen: json['dosen'] != null 
          ? Dosen.fromJson(json['dosen']) 
          : null,
    );
  }
}
