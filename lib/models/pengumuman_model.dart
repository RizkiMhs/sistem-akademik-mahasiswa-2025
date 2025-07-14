import 'dart:convert';

List<Pengumuman> pengumumanFromJson(String str) => List<Pengumuman>.from(json.decode(str).map((x) => Pengumuman.fromJson(x)));

class Pengumuman {
    final int id;
    final String judul;
    final String isi;
    final String kategori;
    final String? foto;
    final String? fotoUrl;
    final DateTime createdAt;
  
    Pengumuman({
        required this.id,
        required this.judul,
        required this.isi,
        required this.kategori,
        this.foto,
        this.fotoUrl,
        required this.createdAt,
    });

    factory Pengumuman.fromJson(Map<String, dynamic> json) => Pengumuman(
        id: json["id"],
        judul: json["judul"],
        isi: json["isi"],
        kategori: json["kategori"] ?? "Umum",
        foto: json["foto"],
        fotoUrl: json["foto_url"],
        createdAt: DateTime.parse(json["created_at"]),
    );
}
