import 'dart:convert';

import 'package:emoji_party/model/media.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  /// List of images from assets
  List<String> imagesList = <String>[].obs;
  List<String> imageName = <String>[].obs;
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

      for (String text in imageList) {
        imageName.add(text.split("/")[3].split(".")[0]);
      }

      imageName.toSet();

      MediaGenerator().imageList = imageList;

      return imageList;
    } finally {
      isLoading(false);
    }
  }
}
