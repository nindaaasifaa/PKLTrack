import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FotoProfilGuruService {
  FotoProfilGuruService._();

  static final ValueNotifier<Uint8List?> fotoBytes = ValueNotifier(null);
  static final ValueNotifier<bool> sedangMemilih = ValueNotifier(false);
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<void> pilihDariGaleri() async {
    if (sedangMemilih.value) return;

    sedangMemilih.value = true;
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) fotoBytes.value = await image.readAsBytes();
    } finally {
      sedangMemilih.value = false;
    }
  }
}
