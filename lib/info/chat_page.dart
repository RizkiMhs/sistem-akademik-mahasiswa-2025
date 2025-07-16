import 'dart:async';
import 'dart:convert';
// import 'package.flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/baseurl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// Sesuaikan path import di bawah ini dengan struktur proyek Anda
import 'package:flutter_application_1/app/controllers/chat_controller.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/chat_message_model.dart';
import 'package:flutter_application_1/utils/color.dart'; // Pastikan Anda memiliki file ini untuk konfigurasi API


// CATATAN: Anda mungkin perlu membuat file ini atau menyesuaikan dengan konfigurasi API Anda.
// Contoh: lib/utils/api_config.dart
class ApiConfig {
  // GANTI dengan URL basis API Anda yang sebenarnya
  static const String baseUrl = BaseUrl.baseUrl; // Asumsi ApiService memiliki baseUrl
}

class ChatPage extends StatelessWidget {
  final int partnerId;
  final String partnerName;

  const ChatPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  // Fungsi untuk menampilkan dialog konfirmasi penghapusan
  Future<void> _confirmDeleteMessage(BuildContext context, ChatMessage message, ChatController chatController, AuthController authController) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pesan'),
        content: const Text('Apakah Anda yakin ingin menghapus pesan ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteMessage(message.id, chatController, authController);
    }
  }

  // Fungsi untuk mengirim permintaan hapus pesan ke API
  Future<void> _deleteMessage(int messageId, ChatController chatController, AuthController authController) async {
    // CATATAN: Asumsi AuthController memiliki properti 'token'.
    // Sesuaikan jika token Anda disimpan di tempat lain (misal: authController.currentUser.value.token)
    final token = authController.token.value;
    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Token tidak tersedia. Silakan login ulang.');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/chat/$messageId'), // Endpoint hapus chat
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // CATATAN: Asumsi ChatController memiliki method 'fetchMessages' untuk refresh data.
        chatController.fetchMessages();
        Get.snackbar('Berhasil', 'Pesan berhasil dihapus.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        final json = jsonDecode(response.body);
        Get.snackbar('Gagal', json['error'] ?? 'Gagal menghapus pesan',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat menghapus pesan.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController(partnerId: partnerId));
    final AuthController authController = Get.find();
    final int myId = authController.currentUser.value!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(partnerName, style: const TextStyle(color: Color(0xFFFFFFFF))),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text("Belum ada pesan. Mulai percakapan!"),
                );
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = controller.messages.length - 1 - index;
                  final message = controller.messages[reversedIndex];
                  final bool isMe = message.senderId == myId;

                  // Mengirim parameter tambahan ke _buildMessageBubble
                  return _buildMessageBubble(message, isMe, context, controller, authController);
                },
              );
            }),
          ),
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  // Widget gelembung pesan dengan GestureDetector untuk aksi long-press
  Widget _buildMessageBubble(ChatMessage message, bool isMe, BuildContext context, ChatController chatController, AuthController authController) {
    return GestureDetector(
      onLongPress: () {
        if (isMe) {
          _confirmDeleteMessage(context, message, chatController, authController);
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? greencolor : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.75,
          ),
          child: Text(
            message.message,
            style: TextStyle(color: isMe ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  // Widget input pesan (SUDAH DIPERBAIKI)
  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageTextController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Ketik pesan...',
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) {
                  if (controller.messageTextController.text.trim().isNotEmpty) {
                    controller.sendMessage();
                  }
                },
              ),
            ),
            Obx(() => IconButton(
                  icon: controller.isLoading.value // Menggunakan 'isLoading'
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.send, color: greencolor),
                  onPressed: controller.isLoading.value // Menggunakan 'isLoading'
                      ? null
                      : () {
                          if (controller.messageTextController.text.trim().isNotEmpty) {
                            controller.sendMessage();
                          }
                        },
                )),
          ],
        ),
      ),
    );
  }
}