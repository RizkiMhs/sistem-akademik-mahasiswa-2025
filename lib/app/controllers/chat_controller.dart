import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/chat_message_model.dart';

class ChatController extends GetxController {
  final int partnerId;
  ChatController({required this.partnerId});
  
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find();

  var messages = <ChatMessage>[].obs;
  var isLoading = true.obs;
  final messageTextController = TextEditingController();
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    // Mulai polling untuk pesan baru setiap 5 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchMessages(isPolling: true);
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel(); // Hentikan timer saat keluar halaman
    messageTextController.dispose();
    super.onClose();
  }

  Future<void> fetchMessages({bool isPolling = false}) async {
    if (!isPolling) isLoading.value = true;
    try {
      final token = _authController.token.value;
      final result = await _apiService.getChatMessages(token, partnerId);
      messages.value = result;
    } catch (e) {
      if (!isPolling) Get.snackbar('Error', e.toString());
    } finally {
      if (!isPolling) isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    if (messageTextController.text.isEmpty) return;
    
    final messageText = messageTextController.text;
    messageTextController.clear();

    try {
      final token = _authController.token.value;
      final sentMessage = await _apiService.sendChatMessage(
        token: token,
        receiverId: partnerId,
        message: messageText,
      );
      messages.add(sentMessage); // Tambahkan pesan ke daftar secara lokal
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pesan');
      messageTextController.text = messageText; // Kembalikan teks jika gagal
    }
  }
}