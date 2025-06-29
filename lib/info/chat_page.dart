import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/controllers/chat_controller.dart'; // Sesuaikan path jika perlu
import 'package:flutter_application_1/app/controllers/auth_controller.dart'; // Sesuaikan path jika perlu
import 'package:flutter_application_1/models/chat_message_model.dart'; // Sesuaikan path jika perlu
import 'package:flutter_application_1/utils/color.dart'; // Sesuaikan path jika perlu

class ChatPage extends StatelessWidget {
  final int partnerId;
  final String partnerName;

  const ChatPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller dengan partnerId saat halaman dibuka
    final ChatController controller = Get.put(ChatController(partnerId: partnerId));
    final AuthController authController = Get.find();
    // Dapatkan ID pengguna yang sedang login untuk membedakan pesan
    final int myId = authController.currentUser.value!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(partnerName, style: const TextStyle(color: Color(0xFFFFFFFF))),
        backgroundColor: greencolor,
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF) // Warna ikon kembali
        ),
      ),
      body: Column(
        children: [
          // Bagian untuk menampilkan daftar pesan
          Expanded(
            child: Obx(() {
              // Tampilkan loading indicator saat pertama kali memuat
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              // Tampilkan pesan jika tidak ada percakapan
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text("Belum ada pesan. Mulai percakapan!"),
                );
              }
              // Tampilkan daftar pesan
              return ListView.builder(
                reverse: true, // Pesan terbaru akan muncul di bawah
                padding: const EdgeInsets.all(16.0),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = controller.messages.length - 1 - index;
                  final message = controller.messages[reversedIndex];
                  final bool isMe = message.senderId == myId;
                  return _buildMessageBubble(message, isMe);
                },
              );
            }),
          ),
          // Bagian untuk input pesan
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan gelembung pesan (chat bubble)
  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      // Atur posisi bubble ke kanan jika pesan dari saya, ke kiri jika dari orang lain
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
          maxWidth: Get.width * 0.75, // Lebar maksimum bubble
        ),
        child: Text(
          message.message,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  /// Widget untuk menampilkan kolom input teks dan tombol kirim
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
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
            Obx(() => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.send, color: greencolor),
              onPressed: controller.isLoading.value ? null : controller.sendMessage,
            )),
          ],
        ),
      ),
    );
  }
}
