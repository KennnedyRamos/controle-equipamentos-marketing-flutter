import '../models/equipamento_model.dart';
import 'exportar_excel_io.dart';

class ExportarExcelService {
  /// 📤 Exporta equipamentos para Excel (MediaStore)
  static Future<void> exportarEquipamentos(
    List<EquipamentoModel> equipamentos,
  ) async {
    if (equipamentos.isEmpty) {
      throw Exception('Lista de equipamentos vazia');
    }

    try {
      await ExportarExcelIO.exportar(equipamentos);
    } catch (e) {
      throw Exception('Erro ao exportar Excel: $e');
    }
  }
}
