import 'dart:convert';
import 'package:flutter_application_1/models/dosen_model.dart';
import 'package:flutter_application_1/models/program_studi_model.dart';

Mahasiswa mahasiswaFromJson(String str) => Mahasiswa.fromJson(json.decode(str));
String mahasiswaToJson(Mahasiswa data) => json.encode(data.toJson());

class Mahasiswa {
  final int id;
  final String nama;
  final String email;
  final String nim;
  final String? foto;
  final String? fotoUrl;
  final String? jenisKelamin;
  final String? noHp;
  final String? alamat;
  final String? tanggalLahir;
  final int? angkatan;
  final int? programStudiId;
  final int? dosenId;
  final ProgramStudi? programStudi;
  final Dosen? dosen;

  Mahasiswa({
    required this.id,
    required this.nama,
    required this.email,
    required this.nim,
    this.foto,
    this.fotoUrl,
    this.jenisKelamin,
    this.noHp,
    this.alamat,
    this.tanggalLahir,
    this.angkatan,
    this.programStudiId,
    this.dosenId,
    this.programStudi,
    this.dosen,
  });

  // --- BAGIAN YANG DIPERBARUI ---
  // Factory constructor dibuat lebih tangguh untuk menangani tipe data
  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    // Fungsi helper untuk parsing integer dengan aman
    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return Mahasiswa(
      id: safeParseInt(json["id"]) ?? 0, // ID wajib ada, fallback ke 0 jika null
      nama: json["nama"],
      email: json["email"],
      nim: json["nim"],
      foto: json["foto"],
      fotoUrl: json["foto_url"],
      jenisKelamin: json["jenis_kelamin"],
      noHp: json["no_hp"],
      alamat: json["alamat"],
      tanggalLahir: json["tanggal_lahir"],
      angkatan: safeParseInt(json["angkatan"]),
      programStudiId: safeParseInt(json["program_studi_id"]),
      dosenId: safeParseInt(json["dosen_id"]),
      programStudi: json["program_studi"] == null
          ? null
          : ProgramStudi.fromJson(json["program_studi"]),
      dosen:
          json["dosen"] == null ? null : Dosen.fromJson(json["dosen"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "email": email,
        "nim": nim,
        "foto": foto,
        "foto_url": fotoUrl,
        "jenis_kelamin": jenisKelamin,
        "no_hp": noHp,
        "alamat": alamat,
        "tanggal_lahir": tanggalLahir,
        "angkatan": angkatan,
        "program_studi_id": programStudiId,
        "dosen_id": dosenId,
      };
}
