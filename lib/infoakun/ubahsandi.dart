import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';

class UbahSandi extends StatefulWidget {
  const UbahSandi({super.key});

  @override
  State<UbahSandi> createState() => _UbahSandiState();
}

class _UbahSandiState extends State<UbahSandi> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthController authController = Get.find();

  bool _oldPassToggle = true;
  bool _newPassToggle = true;
  bool _confirmPassToggle = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// --- BAGIAN YANG DIPERBARUI ---
  /// Fungsi yang dipanggil saat tombol "Simpan" ditekan
  void _submitChangePassword() {
    // Validasi semua input di form
    if (_formKey.currentState!.validate()) {
      // Panggil metode changePassword dari controller
      // Tidak perlu lagi mengirim callback
      authController.changePassword(
        currentPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );
      // Membersihkan form dan navigasi akan ditangani oleh dialog di controller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: _buildAppBar(),
      body: Obx(() => authController.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPasswordField(
                      controller: _oldPasswordController,
                      labelText: 'Password Lama',
                      obscureText: _oldPassToggle,
                      onToggle: () => setState(() => _oldPassToggle = !_oldPassToggle),
                    ),
                    const SizedBox(height: 18),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      labelText: 'Password Baru',
                      obscureText: _newPassToggle,
                      onToggle: () => setState(() => _newPassToggle = !_newPassToggle),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password baru tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      labelText: 'Konfirmasi Password Baru',
                      obscureText: _confirmPassToggle,
                      onToggle: () => setState(() => _confirmPassToggle = !_confirmPassToggle),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangecolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Poppinssemibold')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggle,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? 'Masukkan password',
        labelStyle: const TextStyle(fontFamily: 'Poppinsmedium'),
        hintStyle: const TextStyle(fontFamily: 'PoppinsRegular'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: bg3color,
        prefixIcon: const Icon(Icons.lock, color: Color(0xff00712D)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return '$labelText tidak boleh kosong';
        }
        return null;
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        elevation: 0,
        backgroundColor: greencolor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          "Ubah Password",
          style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }
}
