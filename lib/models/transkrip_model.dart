import 'dart:convert';

// Helper function untuk decode JSON
Transkrip transkripFromJson(String str) => Transkrip.fromJson(json.decode(str));

/// Model utama yang membungkus seluruh data transkrip
class Transkrip {
  final MahasiswaInfo mahasiswa;
  final TranskripInfo transkripInfo;

  Transkrip({required this.mahasiswa, required this.transkripInfo});

  factory Transkrip.fromJson(Map<String, dynamic> json) {
    return Transkrip(
      mahasiswa: MahasiswaInfo.fromJson(json["mahasiswa"]),
      transkripInfo: TranskripInfo.fromJson(json["transkrip"]),
    );
  }
}

/// Model untuk menyimpan info dasar mahasiswa
class MahasiswaInfo {
  final String nama;
  final String nim;
  final String? programStudi;

  MahasiswaInfo({required this.nama, required this.nim, this.programStudi});

  factory MahasiswaInfo.fromJson(Map<String, dynamic> json) {
    return MahasiswaInfo(
      nama: json["nama"],
      nim: json["nim"],
      programStudi: json["program_studi"],
    );
  }
}

/// Model untuk menyimpan informasi rangkuman transkrip
class TranskripInfo {
  final int totalSksLulus;
  final String ipk;
  final List<NilaiSemester> nilaiPerSemester;

  TranskripInfo({
    required this.totalSksLulus,
    required this.ipk,
    required this.nilaiPerSemester,
  });

  factory TranskripInfo.fromJson(Map<String, dynamic> json) {
    return TranskripInfo(
      totalSksLulus: json["total_sks_lulus"],
      ipk: json["ipk"],
      nilaiPerSemester: List<NilaiSemester>.from(
          json["nilai_per_semester"].map((x) => NilaiSemester.fromJson(x))),
    );
  }
}

/// Model untuk menyimpan daftar nilai dalam satu semester
class NilaiSemester {
  final int semester;
  final List<MataKuliahNilai> matakuliah;

  NilaiSemester({required this.semester, required this.matakuliah});

  factory NilaiSemester.fromJson(Map<String, dynamic> json) {
    return NilaiSemester(
      semester: json["semester"],
      matakuliah: List<MataKuliahNilai>.from(
          json["matakuliah"].map((x) => MataKuliahNilai.fromJson(x))),
    );
  }
}

/// Model untuk menyimpan detail satu mata kuliah yang sudah dinilai
class MataKuliahNilai {
  final String? kodeMatkul;
  final String namaMatkul;
  final int sks;
  final String? grade;

  MataKuliahNilai({
    this.kodeMatkul,
    required this.namaMatkul,
    required this.sks,
    this.grade,
  });

  factory MataKuliahNilai.fromJson(Map<String, dynamic> json) {
    return MataKuliahNilai(
      kodeMatkul: json["kode_matkul"],
      namaMatkul: json["nama_matkul"],
      sks: json["sks"],
      grade: json["grade"],
    );
  }
}
