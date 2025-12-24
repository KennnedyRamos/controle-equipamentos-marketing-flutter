import 'dart:io';

import 'package:estoque_vendas/services/exportar_material_marketing_excel_service.dart';
import 'package:flutter/material.dart';

import '../models/material_marketing_model.dart';
import '../services/firestore_service.dart';
import '../services/image_service.dart';
import 'cadastrar_material_marketing_page.dart';
import 'editar_material_marketing_screen.dart';
import 'visualizar_imagem_screen.dart';

class MateriaisMarketingScreen extends StatelessWidget {
  const MateriaisMarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
          title: const Center(
            child: Text('Materiais de Marketing'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Exportar Excel',
              onPressed: () async {
                try {
                  final materiais =
                      await service.listarMateriaisMarketingOnce();

                  if (materiais.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Nenhum material para exportar'),
                      ),
                    );
                    return;
                  }

                  await ExportarMaterialMarketingExcelService.exportar(
                    materiais,
                  );

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Excel salvo em Downloads'),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Erro ao exportar Excel: $e'),
                    ),
                  );
                }
              },
            ),
          ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastrarMaterialMarketingScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<MaterialMarketingModel>>(
        stream: service.listarMateriaisMarketing(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum material cadastrado'),
            );
          }

          final materiais = snapshot.data!;

          return ListView.builder(
            itemCount: materiais.length,
            itemBuilder: (_, i) {
              final m = materiais[i];

              final imagePath = m.imagePath;
              final hasImage = imagePath != null &&
                  imagePath.isNotEmpty &&
                  File(imagePath).existsSync();

              return Dismissible(
                key: Key(m.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Excluir material'),
                      content: const Text(
                        'Tem certeza que deseja excluir este material?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  if (hasImage) {
                    await ImageService.removerImagemLocal(m.id);
                  }

                  await service.excluirMaterialMarketing(m.id);

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Material excluído'),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: hasImage
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VisualizarImagemScreen(
                                    imagePath: imagePath,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: hasImage
                            ? Image.file(
                                File(imagePath),
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 52,
                                height: 52,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, size: 28),
                              ),
                      ),
                    ),
                    title: Text(
                      m.descricao,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Quantidade: ${m.quantidade}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditarMaterialMarketingScreen(
                              material: m,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
