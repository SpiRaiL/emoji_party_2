import 'dart:developer' as developer;
import 'dart:math';

class ImageData {
  String? imageName;
  String? image;
  bool? animated;
  String? imageType;

  ImageData({this.imageName, this.image, this.animated, this.imageType});

  ImageData.fromJson(Map<String, dynamic> json) {
    imageName = json['image_name'];
    image = json['image'];
    animated = json['animated'];
    imageType = json['image_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image_name'] = imageName;
    data['image'] = image;
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

    imageList = ["bubble", "doughnut", "swirl"];
  }

  ImageData getImage(String imageName) {
    return ImageData(
        imageName: imageName,
        image: "assets/custom/images/$imageName.png",
        imageType: "png");
  }

  ImageData randomImage() {
    /// Get a random index from the list.
    int index = Random().nextInt(imageList.length);

    String imageName = imageList[index];

    developer.log("Generated: $imageName - assets/custom/images/$imageName.png",
        name: "image");

    return ImageData(
        image: "assets/custom/images/$imageName.png",
        imageName: imageName,
        imageType: "png");
  }

  String searchString = "";
  List<String> imagesMatchingSearchString() {
    /// Search functionality on the image list
    return imageList.where((image) => image.contains(searchString)).toList();
  }
}
