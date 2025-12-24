import 'dart:io';
import 'package:flutter/material.dart';

import '../services/image_service.dart';

class DeleteButton extends StatelessWidget {
  final String id; // id do equipamento
  final String? imagePath;
  final Future<void> Function(String) onDelete;

  const DeleteButton({
    super.key,
    required this.id,
    required this.onDelete,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);

    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        final confirmar = await showDialog<bool>(
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

        if (confirmar != true) return;

        try {
          /// 🗑️ Remove imagem local se existir
          if (imagePath != null && File(imagePath!).existsSync()) {
            await ImageService.removerImagemLocal(id);
          }

          /// 🗑️ Remove Firestore
          await onDelete(id);

          messenger.showSnackBar(
            const SnackBar(
              content: Text('Equipamento excluído com sucesso'),
            ),
          );
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir equipamento: $e'),
            ),
          );
        }
      },
    );
  }
}
