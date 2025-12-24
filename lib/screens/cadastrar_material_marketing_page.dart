import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/material_marketing_model.dart';
import '../services/firestore_service.dart';
import '../services/image_service.dart';

class CadastrarMaterialMarketingScreen extends StatefulWidget {
  const CadastrarMaterialMarketingScreen({super.key});

  @override
  State<CadastrarMaterialMarketingScreen> createState() =>
      _CadastrarMaterialMarketingScreenState();
}

class _CadastrarMaterialMarketingScreenState
    extends State<CadastrarMaterialMarketingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();

  final descricaoController = TextEditingController();
  final quantidadeController = TextEditingController();

  /// 🖼️ IMAGEM
  XFile? _imagemSelecionada;

  /// 💾 SALVAR
  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final id =
        FirebaseFirestore.instance.collection('materiais_marketing').doc().id;

    String? imagePath;

    if (_imagemSelecionada != null) {
      imagePath = await ImageService.salvarImagemLocal(
        _imagemSelecionada!,
        id,
      );
    }

    final material = MaterialMarketingModel(
      id: id,
      descricao: descricaoController.text.trim(),
      quantidade: int.parse(quantidadeController.text.trim()),
      imagePath: imagePath,
      createdAt: Timestamp.now(),
    );

    await _service.cadastrarMaterialMarketing(material);

    if (!mounted) return;
    Navigator.pop(context);
  }

  /// 📷 MODAL CÂMERA / GALERIA
  Future<void> _selecionarImagem() async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImageService.pickFromCamera();
                if (image != null && mounted) {
                  setState(() => _imagemSelecionada = image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImageService.pickFromGallery();
                if (image != null && mounted) {
                  setState(() => _imagemSelecionada = image);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _obrigatorio(String? v) =>
      v == null || v.trim().isEmpty ? 'Campo obrigatório' : null;

  String? _numero(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
    if (int.tryParse(v) == null) return 'Informe um número válido';
    return null;
  }

  @override
  void dispose() {
    descricaoController.dispose();
    quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Material')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// 🖼️ IMAGEM
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _imagemSelecionada != null
                        ? Image.file(
                            File(_imagemSelecionada!.path),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 48),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Adicionar foto'),
                    onPressed: _selecionarImagem,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: descricaoController,
                validator: _obrigatorio,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: quantidadeController,
                validator: _numero,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
