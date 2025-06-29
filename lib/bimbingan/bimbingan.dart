import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Tambahkan package ini: flutter pub add intl
import 'package:flutter_application_1/app/controllers/mahasiswa_bimbingan_controller.dart';
import 'package:flutter_application_1/models/bimbingan_model.dart';
import 'package:flutter_application_1/utils/color.dart'; // Sesuaikan dengan path file warna Anda

// Halaman 1: Menampilkan Riwayat Bimbingan
class BimbinganHistoryPage extends StatelessWidget {
  const BimbinganHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller saat halaman pertama kali dibuka
    final MahasiswaBimbinganController controller = Get.put(MahasiswaBimbinganController());

    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: const Text("Riwayat Bimbingan", style: TextStyle(color: Colors.white)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.bimbinganList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.bimbinganList.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada riwayat bimbingan.\nKetuk tombol + untuk mengajukan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchBimbingan(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.bimbinganList.length,
            itemBuilder: (context, index) {
              final bimbingan = controller.bimbinganList[index];
              return _buildBimbinganCard(bimbingan);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const BimbinganFormPage()),
        backgroundColor: orangecolor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget untuk menampilkan setiap item bimbingan dalam bentuk Card
  Widget _buildBimbinganCard(Bimbingan bimbingan) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          bimbingan.topik,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Tgl: ${DateFormat('d MMMM yyyy', 'id_ID').format(bimbingan.tanggalBimbingan)}\nDosen: ${bimbingan.dosen?.nama ?? '-'}",
          ),
        ),
        trailing: _buildStatusChip(bimbingan.status),
      ),
    );
  }

  // Widget untuk menampilkan status dengan warna yang berbeda
  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'selesai':
        chipColor = Colors.green;
        statusText = 'Selesai';
        break;
      case 'dibatalkan':
        chipColor = Colors.red;
        statusText = 'Dibatalkan';
        break;
      default:
        chipColor = Colors.orange;
        statusText = 'Diajukan';
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}


// Halaman 2: Form untuk Mengajukan Bimbingan Baru
class BimbinganFormPage extends StatefulWidget {
  const BimbinganFormPage({super.key});

  @override
  State<BimbinganFormPage> createState() => _BimbinganFormPageState();
}

class _BimbinganFormPageState extends State<BimbinganFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _topikController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime? _selectedDate;

  // Temukan instance controller yang sudah dibuat oleh halaman sebelumnya
  final MahasiswaBimbinganController controller = Get.find();

  @override
  void dispose() {
    _topikController.dispose();
    _catatanController.dispose();
    super.dispose();
  }
  
  // Fungsi untuk menampilkan date picker
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Fungsi untuk mengirim form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        Get.snackbar('Error', 'Tanggal bimbingan wajib dipilih.');
        return;
      }
      // Kirim data ke controller
      controller.ajukanBimbingan(
        tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        topik: _topikController.text,
        catatan: _catatanController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        title: const Text("Ajukan Bimbingan", style: TextStyle(color: Colors.white)),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Tanggal
              _buildDatePicker(),
              const SizedBox(height: 20),
              // Input Topik
              TextFormField(
                controller: _topikController,
                decoration: const InputDecoration(
                  labelText: 'Topik Bimbingan',
                  hintText: 'Contoh: Revisi Bab 1 Skripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.topic_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Topik bimbingan tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Input Catatan
              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Tambahkan catatan jika ada...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 30),
              // Tombol Kirim
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangecolor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Kirim Pengajuan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget kustom untuk input tanggal agar lebih rapi
  Widget _buildDatePicker() {
    return TextFormField(
      readOnly: true,
      onTap: _pickDate,
      decoration: InputDecoration(
        labelText: 'Pilih Tanggal Bimbingan',
        hintText: _selectedDate == null
            ? 'Ketuk untuk memilih tanggal'
            : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate!),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      // Controller tidak diperlukan karena kita mengelola state tanggal secara terpisah
    );
  }
}
