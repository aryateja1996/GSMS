import 'package:get/get.dart';

class MainShellController extends GetxController {
  final RxInt tabIndex = 0.obs;

  void selectTab(int index) => tabIndex.value = index;
}
