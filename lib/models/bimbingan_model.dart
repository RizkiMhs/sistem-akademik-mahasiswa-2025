import 'dart:convert';

Bimbingan bimbinganFromJson(String str) => Bimbingan.fromJson(json.decode(str));

class Bimbingan {
    final int id;
    final int mahasiswaId;
    final int dosenId;
    final DateTime tanggalBimbingan;
    final String topik;
    final String? catatan;
    final String status;
    final Dosen? dosen;

    Bimbingan({
        required this.id,
        required this.mahasiswaId,
        required this.dosenId,
        required this.tanggalBimbingan,
        required this.topik,
        this.catatan,
        required this.status,
        this.dosen,
    });

    factory Bimbingan.fromJson(Map<String, dynamic> json) => Bimbingan(
        id: json["id"],
        mahasiswaId: json["mahasiswa_id"],
        dosenId: json["dosen_id"],
        tanggalBimbingan: DateTime.parse(json["tanggal_bimbingan"]),
        topik: json["topik"],
        catatan: json["catatan"],
        status: json["status"],
        dosen: json["dosen"] == null ? null : Dosen.fromJson(json["dosen"]),
    );
}

class Dosen {
    final int id;
    final String nama;

    Dosen({required this.id, required this.nama});

    factory Dosen.fromJson(Map<String, dynamic> json) => Dosen(
        id: json["id"],
        nama: json["nama"],
    );
}
