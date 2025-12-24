import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

import '../models/equipamento_model.dart';

class ExportarExcelIO {
  static const _channel = MethodChannel('media_store_excel');

  static Future<void> exportar(List<EquipamentoModel> equipamentos) async {
    final excel = Excel.createExcel();
    final sheet = excel['Equipamentos'];

    /// 🟢 CABEÇALHO
    sheet.appendRow([
      TextCellValue('Tipo'),
      TextCellValue('Modelo'),
      TextCellValue('Marca'),
      TextCellValue('Voltagem'),
      TextCellValue('RG'),
      TextCellValue('Etiqueta'),
      IntCellValue(0), // placeholder (quantidade)
    ]);

    /// 📦 DADOS
    for (final e in equipamentos) {
      sheet.appendRow([
        TextCellValue(e.tipo),
        TextCellValue(e.modelo),
        TextCellValue(e.marca),
        TextCellValue(e.voltagem ?? ''),
        TextCellValue(e.rg ?? ''),
        TextCellValue(e.etiqueta ?? ''),
        IntCellValue(e.quantidade ?? 0),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Erro ao gerar Excel');
    }

    final fileName =
        'equipamentos_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    await _channel.invokeMethod(
      'saveExcel',
      {
        'fileName': fileName,
        'bytes': Uint8List.fromList(bytes),
      },
    );
  }
}
