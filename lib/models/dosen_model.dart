import 'dart:convert';

List<Dosen> dosenFromJson(String str) => List<Dosen>.from(json.decode(str).map((x) => Dosen.fromJson(x)));

class Dosen {
  final int id;
  final String? nip;
  final String nama;
  final String? email;
  final String? jenisKelamin;
  final String? foto;
  final String? noHp;
  final String? tanggalLahir;
  final int? programStudiId;

  Dosen({
    required this.id,
    this.nip,
    required this.nama,
    this.email,
    this.jenisKelamin,
    this.foto,
    this.noHp,
    this.tanggalLahir,
    this.programStudiId,
  });

  /// Factory constructor untuk membuat objek Dosen dari data JSON.
  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      id: json['id'],
      nip: json['nip'],
      nama: json['nama'],
      email: json['email'],
      jenisKelamin: json['jenis_kelamin'],
      foto: json['foto'],
      noHp: json['no_hp'],
      tanggalLahir: json['tanggal_lahir'],
      programStudiId: json['program_studi_id'],
    );
  }
}
