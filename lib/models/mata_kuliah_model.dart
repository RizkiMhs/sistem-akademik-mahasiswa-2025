import 'dart:convert';

List<MataKuliah> mataKuliahFromJson(String str) => List<MataKuliah>.from(json.decode(str).map((x) => MataKuliah.fromJson(x)));

class MataKuliah {
    final int id;
    final String? kode;
    final String namaMatkul;
    final int sks;
    final int semester; // <-- FIELD BARU DITAMBAHKAN
    final int programStudiId;

    MataKuliah({
        required this.id,
        this.kode,
        required this.namaMatkul,
        required this.sks,
        required this.semester, // <-- DITAMBAHKAN DI CONSTRUCTOR
        required this.programStudiId,
    });

    factory MataKuliah.fromJson(Map<String, dynamic> json) {
        int? safeParseInt(dynamic value) {
            if (value == null) return null;
            if (value is int) return value;
            return int.tryParse(value.toString());
        }

        return MataKuliah(
            id: safeParseInt(json["id"]) ?? 0,
            kode: json["kode_matkul"],
            namaMatkul: json["nama_matkul"],
            sks: safeParseInt(json["sks"]) ?? 0,
            semester: safeParseInt(json["semester"]) ?? 1, // <-- PARSING DATA SEMESTER
            programStudiId: safeParseInt(json["program_studi_id"]) ?? 0,
        );
    }
}
