import 'dart:convert';

List<Pengumuman> pengumumanFromJson(String str) => List<Pengumuman>.from(json.decode(str).map((x) => Pengumuman.fromJson(x)));

class Pengumuman {
    final int id;
    final String judul;
    final String isi;
    final String kategori;
    final DateTime createdAt;
  
    Pengumuman({
        required this.id,
        required this.judul,
        required this.isi,
        required this.kategori,
        required this.createdAt,
    });

    factory Pengumuman.fromJson(Map<String, dynamic> json) => Pengumuman(
        id: json["id"],
        judul: json["judul"],
        isi: json["isi"],
        kategori: json["kategori"] ?? "Umum",
        createdAt: DateTime.parse(json["created_at"]),
    );
}
