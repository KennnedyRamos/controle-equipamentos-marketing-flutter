import 'package:flutter/material.dart';
import 'dart:io';

import '../models/equipamento_model.dart';
import '../services/firestore_service.dart';
import '../services/exportar_excel_service.dart';
import '../services/image_service.dart';
import 'cadastrar_equipamento_screen.dart';
import 'editar_equipamento_screen.dart';
import 'visualizar_imagem_screen.dart';

class EquipamentosScreen extends StatelessWidget {
  const EquipamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Equipamentos')),
        actions: [
          /// 📥 EXPORTAR EXCEL (MediaStore - Android)
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar Excel',
            onPressed: () async {
              try {
                final equipamentos = await service.listarEquipamentosOnce();

                if (equipamentos.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Nenhum equipamento para exportar'),
                    ),
                  );
                  return;
                }

                await ExportarExcelService.exportarEquipamentos(
                  equipamentos,
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastrarEquipamentoScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<EquipamentoModel>>(
        stream: service.listarEquipamentos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipamentos = snapshot.data!;

          if (equipamentos.isEmpty) {
            return const Center(
              child: Text('Nenhum equipamento cadastrado'),
            );
          }

          return ListView.builder(
            itemCount: equipamentos.length,
            itemBuilder: (_, i) {
              final e = equipamentos[i];

              final hasImage =
                  e.imagePath != null && File(e.imagePath!).existsSync();

              return Dismissible(
                key: Key(e.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Excluir equipamento'),
                      content: const Text(
                        'Tem certeza que deseja excluir este equipamento?',
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
                  if (e.imagePath != null) {
                    await ImageService.removerImagemLocal(e.id);
                  }

                  await service.excluirEquipamento(e.id);

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Equipamento excluído'),
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
                                    imagePath: e.imagePath!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: hasImage
                            ? Image.file(
                                File(e.imagePath!),
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
                      e.tipo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: e.tipo == "REFRIGERADOR"
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${e.modelo} - ${e.marca} - ${e.voltagem}',
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'RG: ${e.rg}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 87, 85, 85),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '${e.modelo} - ${e.marca} | Quantidade: ${e.quantidade}',
                          ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditarEquipamentoScreen(
                              equipamento: e,
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
