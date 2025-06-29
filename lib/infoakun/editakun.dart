import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditAkun extends StatefulWidget {
  const EditAkun({super.key});

  @override
  State<EditAkun> createState() => _EditAkunState();
}

class _EditAkunState extends State<EditAkun> {
  final AuthController authController = Get.find();
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk setiap field yang bisa diedit
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatController;
  late TextEditingController _angkatanController;
  late TextEditingController _tanggalLahirController;

  String? _selectedKelamin;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Isi semua controller dengan data user saat ini
    final user = authController.currentUser.value;
    _namaController = TextEditingController(text: user?.nama ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _noHpController = TextEditingController(text: user?.noHp ?? '');
    _alamatController = TextEditingController(text: user?.alamat ?? '');
    _angkatanController = TextEditingController(text: user?.angkatan?.toString() ?? '');
    _tanggalLahirController = TextEditingController(text: user?.tanggalLahir ?? '');
    _selectedKelamin = user?.jenisKelamin;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _angkatanController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      Map<String, String> data = {
        'nama': _namaController.text,
        'email': _emailController.text,
        'no_hp': _noHpController.text,
        'alamat': _alamatController.text,
        'jenis_kelamin': _selectedKelamin!,
        'tanggal_lahir': _tanggalLahirController.text,
        'angkatan': _angkatanController.text,
      };
      authController.updateProfile(data: data, foto: _selectedImage);
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
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 30),
                    _buildTextField(controller: _namaController, label: "Nama Lengkap", icon: Icons.person),
                    _buildReadOnlyField(label: "NIM", value: authController.currentUser.value?.nim ?? ''),
                    _buildTextField(controller: _emailController, label: "Email", icon: Icons.email, keyboardType: TextInputType.emailAddress),
                    _buildJenisKelaminDropdown(),
                    _buildDateField(),
                    _buildTextField(controller: _noHpController, label: "No. HP", icon: Icons.phone, keyboardType: TextInputType.phone),
                    _buildTextField(controller: _alamatController, label: "Alamat", icon: Icons.home, maxLines: 3),
                    _buildTextField(controller: _angkatanController, label: "Tahun Angkatan", icon: Icons.calendar_today, keyboardType: TextInputType.number),
                    _buildReadOnlyField(label: "Program Studi", value: authController.currentUser.value?.programStudi?.namaProdi ?? 'Tidak diketahui'),
                    _buildReadOnlyField(label: "Dosen PA", value: authController.currentUser.value?.dosen?.nama ?? 'Tidak diketahui'),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            )),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildImagePicker() {
    final user = authController.currentUser.value;
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : (user?.fotoUrl != null && user!.fotoUrl!.isNotEmpty)
                    ? NetworkImage(user.fotoUrl!)
                    : const AssetImage('asset/image/profile.png') as ImageProvider,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: orangecolor,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: greencolor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: whitecolor,
        ),
        validator: (value) {
          if ((label == 'Nama Lengkap' || label == 'Email') && (value == null || value.isEmpty)) {
            return '$label tidak boleh kosong';
          }
          if (label == 'Email' && value != null && !GetUtils.isEmail(value)) {
            return 'Format email tidak valid';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildJenisKelaminDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedKelamin,
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          prefixIcon: Icon(Icons.wc, color: greencolor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: whitecolor,
        ),
        items: ['Laki-laki', 'Perempuan'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
        onChanged: (value) => setState(() => _selectedKelamin = value),
        validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: _tanggalLahirController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          prefixIcon: Icon(Icons.cake, color: greencolor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: whitecolor,
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(_tanggalLahirController.text) ?? DateTime(2000),
            firstDate: DateTime(1980),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
        validator: (value) => (value == null || value.isEmpty) ? 'Tanggal lahir tidak boleh kosong' : null,
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.school_outlined, color: Colors.grey[400]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _submitUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 2, 93, 168),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Simpan Perubahan', style: TextStyle(fontFamily: 'Poppinssemibold', fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: greencolor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: const Text("Edit Data Diri", style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 22, color: Colors.white)),
      centerTitle: true,
    );
  }
}
