import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

import '../models/material_marketing_model.dart';

class ExportarMaterialMarketingExcelIO {
  static const _channel = MethodChannel('media_store_excel');

  static Future<void> exportar(
    List<MaterialMarketingModel> materiais,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Materiais Marketing'];

    /// 🟢 CABEÇALHO
    sheet.appendRow([
      TextCellValue('Descrição'),
      TextCellValue('Quantidade'),
      TextCellValue('Possui Imagem'),
      TextCellValue('Criado em'),
    ]);

    /// 📦 DADOS
    for (final m in materiais) {
      sheet.appendRow([
        TextCellValue(m.descricao),
        IntCellValue(m.quantidade),
        TextCellValue(
          (m.imagePath != null && m.imagePath!.isNotEmpty) ? 'SIM' : 'NÃO',
        ),
        TextCellValue(
          m.createdAt.toDate().toString(),
        ),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Erro ao gerar Excel');
    }

    final fileName =
        'materiais_marketing_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    await _channel.invokeMethod(
      'saveExcel',
      {
        'fileName': fileName,
        'bytes': Uint8List.fromList(bytes),
      },
    );
  }
}
