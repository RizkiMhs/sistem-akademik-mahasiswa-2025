import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/models/dosen_model.dart';
import 'package:flutter_application_1/models/program_studi_model.dart';
import 'package:flutter_application_1/views/login2.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Controllers for text fields
  final TextEditingController cNama = TextEditingController();
  final TextEditingController cNIM = TextEditingController();
  final TextEditingController cEmail = TextEditingController();
  final TextEditingController cNoHp = TextEditingController();
  final TextEditingController cAlamat = TextEditingController();
  final TextEditingController cAngkatan = TextEditingController();
  final TextEditingController cPass = TextEditingController();
  final TextEditingController cConfirmPass = TextEditingController();
  final TextEditingController cTanggalLahir = TextEditingController();

  // State for dropdowns and data loading
  List<ProgramStudi> _programStudiList = [];
  List<Dosen> _dosenList = [];
  int? _selectedProdiId;
  int? _selectedDosenId;
  String? _selectedKelamin;
  bool _isDataLoading = true;

  final formKey = GlobalKey<FormState>();
  bool passToggle = true;
  bool confirmPassToggle = true;

  // Get instances of controllers and services
  final AuthController authController = Get.find<AuthController>();
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data saat halaman pertama kali dibuka
    _fetchInitialData();
  }

  /// Mengambil data Program Studi dan Dosen dari API
  Future<void> _fetchInitialData() async {
    try {
      // Panggil kedua API secara bersamaan untuk efisiensi
      final results = await Future.wait([
        apiService.fetchProgramStudi(),
        apiService.fetchDosen(),
      ]);
      setState(() {
        _programStudiList = results[0] as List<ProgramStudi>;
        _dosenList = results[1] as List<Dosen>;
        _isDataLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data registrasi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00712D),
      body: Obx(() => authController.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildForm(),
                ],
              ),
            )),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 60, bottom: 10),
      child: Column(
        children: [
          Image(image: AssetImage('asset/image/logo1.png'), width: 59, height: 77),
          Text('Sistem Akademik', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'PoppinsEkstraBold', fontSize: 15, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: const BoxDecoration(
          color: Color(0xffFFFBE6),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        // Tampilkan loading indicator jika data dropdown belum siap
        child: _isDataLoading
            ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
            : Column(
                children: [
                  const Text('Register', style: TextStyle(fontFamily: 'PoppinsEkstraBold', fontSize: 24, color: Color(0xFF00712D))),
                  const SizedBox(height: 15),
                  _buildInputField(label: 'Nama Lengkap', hint: 'Masukkan nama lengkap', controller: cNama, icon: Icons.person),
                  _buildInputField(label: 'NIM', hint: 'Masukkan NIM', controller: cNIM, icon: Icons.badge, keyboardType: TextInputType.number),
                  _buildInputField(label: 'Email', hint: 'Masukkan email', controller: cEmail, icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (value) {
                    if (value == null || !GetUtils.isEmail(value)) return 'Format email tidak valid';
                    return null;
                  }),
                  _buildProdiDropdown(), // Dropdown Program Studi
                  _buildDosenDropdown(), // Dropdown Dosen PA
                  _buildJenisKelaminDropdown(),
                  _buildDateField(context),
                  _buildInputField(label: 'No. HP', hint: 'Masukkan nomor HP', controller: cNoHp, icon: Icons.phone, keyboardType: TextInputType.phone),
                  _buildInputField(label: 'Alamat', hint: 'Masukkan alamat', controller: cAlamat, icon: Icons.home),
                  _buildInputField(label: 'Tahun Angkatan', hint: 'Contoh: 2023', controller: cAngkatan, icon: Icons.calendar_today, keyboardType: TextInputType.number),
                  _buildPasswordField(label: 'Password', hint: 'Minimal 8 karakter', controller: cPass, isConfirmation: false),
                  _buildPasswordField(label: 'Konfirmasi Password', hint: 'Ulangi password', controller: cConfirmPass, isConfirmation: true),
                  const SizedBox(height: 25),
                  _buildRegisterButton(),
                  _buildLoginNavigation(context),
                ],
              ),
      ),
    );
  }
  
  // Widget untuk dropdown Program Studi
  Widget _buildProdiDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<int>(
        value: _selectedProdiId,
        decoration: InputDecoration(
          labelText: 'Program Studi',
          prefixIcon: Icon(Icons.school, color: const Color(0xff00712D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: const Color(0x20005A24),
          filled: true,
        ),
        isExpanded: true,
        items: _programStudiList.map((prodi) {
          return DropdownMenuItem(
            value: prodi.id,
            child: Text(prodi.namaProdi, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedProdiId = value;
          });
        },
        validator: (value) => value == null ? 'Pilih program studi' : null,
      ),
    );
  }

  // Widget untuk dropdown Dosen
  Widget _buildDosenDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<int>(
        value: _selectedDosenId,
        decoration: InputDecoration(
          labelText: 'Dosen Pembimbing Akademik',
          prefixIcon: Icon(Icons.supervisor_account, color: const Color(0xff00712D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: const Color(0x20005A24),
          filled: true,
        ),
        isExpanded: true,
        items: _dosenList.map((dosen) {
          return DropdownMenuItem(
            value: dosen.id,
            child: Text(dosen.nama, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDosenId = value;
          });
        },
        validator: (value) => value == null ? 'Pilih dosen PA' : null,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xff00712D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: const Color(0x20005A24),
          filled: true,
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) return '$label tidak boleh kosong';
          return null;
        },
      ),
    );
  }

  Widget _buildJenisKelaminDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: _selectedKelamin,
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          prefixIcon: Icon(Icons.wc, color: const Color(0xff00712D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: const Color(0x20005A24),
          filled: true,
        ),
        items: ['Laki-laki', 'Perempuan'].map((label) => DropdownMenuItem(child: Text(label), value: label)).toList(),
        onChanged: (value) => setState(() => _selectedKelamin = value),
        validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: cTanggalLahir,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          hintText: 'Pilih tanggal lahir',
          prefixIcon: Icon(Icons.cake, color: const Color(0xff00712D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: const Color(0x20005A24),
          filled: true,
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1980),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              cTanggalLahir.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
        validator: (value) => (value == null || value.isEmpty) ? 'Pilih tanggal lahir' : null,
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isConfirmation,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        obscureText: isConfirmation ? confirmPassToggle : passToggle,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.lock, color: Color(0xff00712D)),
          suffixIcon: InkWell(
            onTap: () => setState(() {
              if (isConfirmation) {
                confirmPassToggle = !confirmPassToggle;
              } else {
                passToggle = !passToggle;
              }
            }),
            child: Icon((isConfirmation ? confirmPassToggle : passToggle) ? Icons.visibility_off : Icons.visibility, color: const Color(0xff00712D)),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: const Color(0x20005A24),
          filled: true,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '$label tidak boleh kosong';
          if (isConfirmation && value != cPass.text) return 'Password tidak cocok';
          if (!isConfirmation && value.length < 8) return 'Password minimal 8 karakter';
          return null;
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            Map<String, String> data = {
              'nama': cNama.text,
              'nim': cNIM.text,
              'email': cEmail.text,
              'password': cPass.text,
              'password_confirmation': cConfirmPass.text,
              'jenis_kelamin': _selectedKelamin!,
              'no_hp': cNoHp.text,
              'alamat': cAlamat.text,
              'tanggal_lahir': cTanggalLahir.text,
              'angkatan': cAngkatan.text,
              'program_studi_id': _selectedProdiId.toString(),
              'dosen_id': _selectedDosenId.toString(),
            };
            authController.register(data);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginNavigation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: GestureDetector(
        onTap: () => Get.off(() => const LoginTwo()),
        child: const Text("Sudah punya akun? Login di sini", style: TextStyle(color: Color(0xFF00712D), fontSize: 14)),
      ),
    );
  }
}
