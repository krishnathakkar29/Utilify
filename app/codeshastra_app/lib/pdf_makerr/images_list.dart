import 'package:image_picker/image_picker.dart';

    // Simple singleton class to hold the list of selected images globally
    class ImagesList {
      static final ImagesList _instance = ImagesList._internal();

      factory ImagesList() {
        return _instance;
      }

      ImagesList._internal();

      final List<XFile> _imagePaths = [];

      List<XFile> get imagePaths => _imagePaths;

      void addImage(XFile image) {
        _imagePaths.add(image);
      }

      void addAllImages(List<XFile> images) {
        _imagePaths.addAll(images);
      }

      void clearImagesList() {
        _imagePaths.clear();
      }

      void removeImage(XFile image) {
        _imagePaths.remove(image);
      }
    }
