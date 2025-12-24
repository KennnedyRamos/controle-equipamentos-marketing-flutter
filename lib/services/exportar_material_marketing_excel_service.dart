import '../models/material_marketing_model.dart';
import 'exportar_material_marketing_excel_io.dart';

class ExportarMaterialMarketingExcelService {
  static Future<void> exportar(
    List<MaterialMarketingModel> materiais,
  ) async {
    if (materiais.isEmpty) {
      throw Exception('Lista de materiais vazia');
    }

    try {
      await ExportarMaterialMarketingExcelIO.exportar(materiais);
    } catch (e) {
      throw Exception('Erro ao exportar Excel: $e');
    }
  }
}
