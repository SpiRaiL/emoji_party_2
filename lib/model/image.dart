import 'dart:developer' as developer;
import 'dart:math';

class ImageData {
  String? imageName;
  bool? animated;
  String? imageType;

  ImageData({this.imageName, this.animated, this.imageType});

  ImageData.fromJson(Map<String, dynamic> json) {
    imageName = json['image_name'];
    animated = json['animated'];
    imageType = json['image_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image_name'] = imageName;
    data['animated'] = animated;
    data['image_type'] = imageType;
    return data;
  }
}

class ImageGenerator {
  /// List of images from assets
  List<String> imageList = [];

  ImageGenerator() {
    getImageList();
  }

  void getImageList() async {
    /// get all the images from the assets folder

    imageList = [
      "assets/custom/images/bubble.png",
      "assets/custom/images/doughnut.png",
      "assets/custom/images/swirl.png",
    ];
  }

  ImageData getImage(String imageName) {
    return ImageData(imageName: imageName);
  }

  ImageData randomImage() {
    /// Get a random index from the list.
    int index = Random().nextInt(imageList.length);

    String imageName = imageList[index];

    developer.log("Generated: $imageName", name: "image");

    return ImageData(imageName: imageName);
  }

  String searchString = "";
  List<String> imagesMatchingSearchString() {
    print(searchString);

    /// Search functionality on the image list
    return imageList.where((image) => image.contains(searchString)).toList();
  }
}
