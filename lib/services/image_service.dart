import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// 📷 CÂMERA
  static Future<XFile?> pickFromCamera() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
  }

  /// 🖼️ GALERIA
  static Future<XFile?> pickFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
  }

  /// 💾 SALVAR IMAGEM LOCAL
  static Future<String> salvarImagemLocal(
    XFile image,
    String id,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/equipamentos');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = path.extension(image.path);
    final newPath = '${imagesDir.path}/$id$extension';

    final savedImage = await File(image.path).copy(newPath);
    return savedImage.path;
  }

  /// 🗑️ REMOVER IMAGEM LOCAL
  static Future<void> removerImagemLocal(String id) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/equipamentos');

    if (!await imagesDir.exists()) return;

    final files = imagesDir.listSync();

    for (final file in files) {
      if (file is File && path.basename(file.path).startsWith(id)) {
        await file.delete();
      }
    }
  }

  /// ✅ MÉTODO QUE SUA TELA ESPERA
  static Future<File?> selecionarImagem({required String id}) async {
    final XFile? image = await pickFromGallery();

    if (image == null) return null;

    // Remove imagem antiga (edição)
    await removerImagemLocal(id);

    final imagePath = await salvarImagemLocal(image, id);

    return File(imagePath);
  }
}
