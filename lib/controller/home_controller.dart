import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<String> imagesList = <String>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  void onClose() {}

  loadImagesFromAssets(BuildContext buildContext) async {
    try {
      isLoading(true);
      final manifestJson = await DefaultAssetBundle.of(buildContext)
          .loadString('AssetManifest.json');

      final imageList = json
          .decode(manifestJson)
          .keys
          .where((String key) => key.startsWith('assets/custom/images'))
          .toList();

      imagesList = imageList;

      return imageList;
    } finally {
      isLoading(false);
    }
  }
}
