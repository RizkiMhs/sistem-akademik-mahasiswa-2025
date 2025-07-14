import 'dart:convert';
import 'package:flutter_application_1/models/dosen_model.dart';
import 'package:flutter_application_1/models/program_studi_model.dart';
import 'package:flutter_application_1/models/pengumuman_model.dart';
import 'package:flutter_application_1/models/mata_kuliah_model.dart';
import 'package:flutter_application_1/models/jadwal_kuliah_model.dart';
import 'package:flutter_application_1/models/chat_message_model.dart';
import 'package:flutter_application_1/models/khs_model.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; // Untuk File

class ApiService {
  // Ganti dengan URL base API Laravel Anda
  final String _baseUrl =
      "http://192.168.100.11:8000/api"; // 10.0.2.2 adalah localhost untuk emulator Android

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Gagal untuk login.');
    }
  }

  /// Mengambil data profil lengkap dari pengguna yang sedang login
  Future<Map<String, dynamic>> getProfile(String token) async {
    // 1. Membuat request GET ke endpoint '/me' di Laravel Anda
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Accept': 'application/json',
        // 2. Mengirimkan token untuk otentikasi
        'Authorization': 'Bearer $token',
      },
    );

    // 3. Memeriksa hasil dari server
    if (response.statusCode == 200) {
      // 4. Jika sukses, kembalikan data profil
      return jsonDecode(response.body);
    } else {
      // 5. Jika gagal, lempar error
      throw Exception('Gagal memuat profil atau sesi telah berakhir.');
    }
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> register(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return responseData;
    } else {
      if (response.statusCode == 422 && responseData['errors'] != null) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first[0];
        throw Exception(firstError);
      }
      throw Exception(responseData['message'] ?? 'Gagal untuk registrasi.');
    }
  }

  // == BAGIAN YANG DIPERBAIKI ==

  /// Mengambil daftar semua program studi dari API.
  Future<List<ProgramStudi>> fetchProgramStudi() async {
    final response = await http.get(Uri.parse('$_baseUrl/prodi'));
    if (response.statusCode == 200) {
      // Decode sebagai Map, bukan langsung sebagai List
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Laravel Resource biasanya membungkus data dalam key 'data'
      // Jika struktur API Anda berbeda (misalnya tidak ada key 'data'),
      // Anda mungkin perlu menyesuaikan baris ini.
      // Untuk sekarang, kita asumsikan responsnya adalah {"data": [...]}
      if (responseData['data'] is List) {
        final List<dynamic> body = responseData['data'];
        return body.map((dynamic item) => ProgramStudi.fromJson(item)).toList();
      } else {
        // Jika tidak ada key 'data', asumsikan responsnya adalah list langsung
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => ProgramStudi.fromJson(item)).toList();
      }
    } else {
      throw Exception('Gagal memuat program studi');
    }
  }

  /// Mengambil daftar semua dosen dari API.
  Future<List<Dosen>> fetchDosen() async {
    final response = await http.get(Uri.parse('$_baseUrl/dosen'));
    if (response.statusCode == 200) {
      // Decode sebagai Map, bukan langsung sebagai List
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // Asumsi yang sama seperti program studi, data dibungkus dalam key 'data'
      if (responseData['data'] is List) {
        final List<dynamic> body = responseData['data'];
        return body.map((dynamic item) => Dosen.fromJson(item)).toList();
      } else {
        // Fallback jika tidak ada key 'data'
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Dosen.fromJson(item)).toList();
      }
    } else {
      throw Exception('Gagal memuat dosen');
    }
  }

  /// Mengirim permintaan untuk mengubah password pengguna.
  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/password/change'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        // Sertakan token otentikasi untuk keamanan
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    final responseData = jsonDecode(response.body);

    // Cek jika request berhasil (200 OK) atau gagal (misal: 422)
    if (response.statusCode == 200) {
      return responseData;
    } else {
      // Lempar pesan error dari server agar bisa ditampilkan di UI
      throw Exception(responseData['message'] ?? 'Terjadi kesalahan.');
    }
  }

  /// Mengirim permintaan untuk memperbarui profil pengguna, termasuk foto.
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required Map<String, String> data,
    File? foto, // Foto bisa null
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/profile/update'),
    );

    // Tambahkan headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Tambahkan data teks
    request.fields.addAll(data);

    // Tambahkan file foto jika ada
    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', foto.path),
      );
    }

    // Kirim request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memperbarui profil.');
    }
  }

  /// Mengambil daftar semua pengumuman dari API
  Future<List<Pengumuman>> fetchPengumuman() async {
    final response = await http.get(Uri.parse('$_baseUrl/pengumuman'));

    if (response.statusCode == 200) {
      final dynamic decodedJson = jsonDecode(response.body);
      if (decodedJson is Map<String, dynamic> &&
          decodedJson.containsKey('data')) {
        final List<dynamic> body = decodedJson['data'];
        return body.map((dynamic item) => Pengumuman.fromJson(item)).toList();
      } else if (decodedJson is List) {
        return decodedJson
            .map((dynamic item) => Pengumuman.fromJson(item))
            .toList();
      } else {
        throw Exception('Format respons API pengumuman tidak dikenali.');
      }
    } else {
      throw Exception('Gagal memuat pengumuman');
    }
  }

  /// Mengambil daftar semua mata kuliah dari API.
  Future<List<MataKuliah>> fetchMataKuliah() async {
    final response = await http.get(Uri.parse('$_baseUrl/matkul'));

    if (response.statusCode == 200) {
      final dynamic decodedJson = jsonDecode(response.body);
      // Asumsi Laravel Resource membungkus data dalam key 'data'
      if (decodedJson is Map<String, dynamic> &&
          decodedJson.containsKey('data')) {
        final List<dynamic> body = decodedJson['data'];
        return body.map((dynamic item) => MataKuliah.fromJson(item)).toList();
      } else if (decodedJson is List) {
        return decodedJson
            .map((dynamic item) => MataKuliah.fromJson(item))
            .toList();
      } else {
        throw Exception('Format respons API mata kuliah tidak dikenali.');
      }
    } else {
      throw Exception('Gagal memuat mata kuliah');
    }
  }

  /// Mengambil data penawaran KRS dari server.
  Future<Map<String, dynamic>> getPenawaranKrs(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/krs/penawaran'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data penawaran KRS.');
    }
  }

  /// Mengirim data KRS yang dipilih ke server untuk disimpan.
  Future<Map<String, dynamic>> simpanKrs(
      String token, List<int> jadwalIds) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/krs/simpan'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'jadwal_ids': jadwalIds,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      // 201 Created
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Gagal menyimpan KRS.');
    }
  }

  /// Mengambil data KRS terakhir yang diajukan oleh pengguna.
  Future<Map<String, dynamic>> getSubmittedKrs(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/krs/riwayat'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // API Resource Laravel biasanya membungkus objek tunggal dalam key 'data'
      return responseData['data'];
    } else {
      throw Exception(responseData['message'] ?? 'Gagal memuat riwayat KRS.');
    }
  }

  /// Mengambil jadwal kuliah mahasiswa dari KRS yang disetujui.
  Future<List<JadwalKuliah>> getJadwalKuliah(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/jadwal-kuliah/mahasiswa'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decodedJson = jsonDecode(response.body);
      // API Resource collection selalu dibungkus dalam key 'data'
      final List<dynamic> body = decodedJson['data'];
      return body.map((dynamic item) => JadwalKuliah.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat jadwal kuliah.');
    }
  }

  /// Mengambil riwayat KHS dari mahasiswa yang login
  Future<List<Khs>> getKhsHistory(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/khs'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decodedJson = jsonDecode(response.body);
      // Laravel Resource collection biasanya dibungkus dalam key 'data'
      final List<dynamic> body = decodedJson['data'];
      return body.map((dynamic item) => Khs.fromJson(item)).toList();
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Gagal memuat riwayat KHS.');
    }
  }

  /// Mengambil data transkrip lengkap dari mahasiswa yang login
  Future<Map<String, dynamic>> getTranskrip(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/transkrip'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Endpoint ini mengembalikan objek tunggal, bukan list, jadi langsung di-decode
      return jsonDecode(response.body);
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(
          responseData['message'] ?? 'Gagal memuat transkrip nilai.');
    }
  }

  // --- FUNGSI BARU UNTUK FITUR BIMBINGAN ---

  /// Mengambil riwayat bimbingan dari mahasiswa yang sedang login.
  Future<Map<String, dynamic>> getBimbinganMahasiswa(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/mahasiswa/bimbingan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final responseData = jsonDecode(response.body);
      throw Exception(
          responseData['message'] ?? 'Gagal memuat riwayat bimbingan.');
    }
  }

  /// Mengirim pengajuan bimbingan baru ke server.
  Future<Map<String, dynamic>> postBimbinganMahasiswa({
    required String token,
    required String tanggal,
    required String topik,
    String? catatan,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/mahasiswa/bimbingan'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tanggal_bimbingan': tanggal,
        'topik': topik,
        'catatan': catatan,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      // 201 Created
      return responseData;
    } else {
      // [FIXED] Tambahkan penanganan untuk error validasi (422)
      if (response.statusCode == 422 && responseData['errors'] != null) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        // Ambil pesan error pertama dari daftar error
        final firstError = errors.values.first[0];
        throw Exception(firstError);
      }
      // Jika bukan error validasi, gunakan pesan default
      throw Exception(responseData['message'] ?? 'Gagal mengajukan bimbingan.');
    }
  }

  // Mengambil riwayat chat dengan partner
  Future<List<ChatMessage>> getChatMessages(String token, int partnerId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/chat/$partnerId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body)['data'];
      return body.map((dynamic item) => ChatMessage.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat pesan chat.');
    }
  }

  // Mengirim pesan baru
  Future<ChatMessage> sendChatMessage({
    required String token,
    required int receiverId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiver_id': receiverId,
        'message': message,
      }),
    );
    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal mengirim pesan.');
    }
  }
}
