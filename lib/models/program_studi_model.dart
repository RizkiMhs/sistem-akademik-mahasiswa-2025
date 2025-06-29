import 'dart:convert';

// Helper function to decode a list of ProgramStudi from a JSON string
List<ProgramStudi> programStudiFromJson(String str) => List<ProgramStudi>.from(json.decode(str).map((x) => ProgramStudi.fromJson(x)));

class ProgramStudi {
  final int id;
  final String namaProdi;

  ProgramStudi({
    required this.id,
    required this.namaProdi,
  });

  /// Factory constructor to create a ProgramStudi instance from a JSON map.
  /// It correctly maps 'nama_prodi' from the JSON to the 'namaProdi' field.
  factory ProgramStudi.fromJson(Map<String, dynamic> json) {
    return ProgramStudi(
      id: json['id'],
      namaProdi: json['nama_prodi'],
    );
  }
}
