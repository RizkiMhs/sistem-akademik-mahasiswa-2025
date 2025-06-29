import 'package:flutter_application_1/api/api_service.dart';
import 'package:flutter_application_1/app/controllers/auth_controller.dart';
import 'package:flutter_application_1/models/khs_model.dart';
import 'package:get/get.dart';

class KhsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find();

  var khsList = <Khs>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKhsHistory();
  }

  Future<void> fetchKhsHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final token = _authController.token.value;
      if (token.isEmpty) throw Exception("Sesi tidak valid.");

      var fetchedKhs = await _apiService.getKhsHistory(token);
      khsList.assignAll(fetchedKhs);

    } catch (e) {
      errorMessage.value = e.toString().replaceAll("Exception: ", "");
    } finally {
      isLoading.value = false;
    }
  }
}
