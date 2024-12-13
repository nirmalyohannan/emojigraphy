import 'dart:developer';
import 'package:image/image.dart' as img;

img.Image fillImage(img.Image srcImage,
    {required int startX, required int startY, required img.Image fillWith}) {
  //assert fillWith to be smaller than srcImage
  assert(fillWith.width <= srcImage.width);
  assert(fillWith.height <= srcImage.height);
  for (var y = 0; y < fillWith.height; y++) {
    for (var x = 0; x < fillWith.width; x++) {
      int srcX = x + startX;
      int srcY = y + startY;
      if (srcX >= srcImage.width || srcY >= srcImage.height) {
        log("Fill with image overFlows srcImage", name: "fillImage");
        log("Cancelling remaining operations", name: "fillImage");
        return srcImage;
      }
      srcImage.setPixel(srcX, srcY, fillWith.getPixel(x, y));
    }
  }
  return srcImage;
}
