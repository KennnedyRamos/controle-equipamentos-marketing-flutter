import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/material_marketing_model.dart';
import '../services/firestore_service.dart';
import '../services/image_service.dart';
import 'visualizar_imagem_screen.dart';

class EditarMaterialMarketingScreen extends StatefulWidget {
  final MaterialMarketingModel material;

  const EditarMaterialMarketingScreen({
    super.key,
    required this.material,
  });

  @override
  State<EditarMaterialMarketingScreen> createState() =>
      _EditarMaterialMarketingScreenState();
}

class _EditarMaterialMarketingScreenState
    extends State<EditarMaterialMarketingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();

  late final TextEditingController descricao;
  late final TextEditingController quantidade;

  /// 🖼️ IMAGEM
  XFile? _novaImagem;
  String? _imagemAtualPath;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    descricao = TextEditingController(text: widget.material.descricao);
    quantidade =
        TextEditingController(text: widget.material.quantidade.toString());

    _imagemAtualPath = widget.material.imagePath;
  }

  @override
  void dispose() {
    descricao.dispose();
    quantidade.dispose();
    super.dispose();
  }

  /// 💾 SALVAR ALTERAÇÕES
  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      String? imagePath = _imagemAtualPath;

      /// 📷 Se trocou imagem, salva nova
      if (_novaImagem != null) {
        imagePath = await ImageService.salvarImagemLocal(
          _novaImagem!,
          widget.material.id,
        );
      }

      final atualizado = MaterialMarketingModel(
        id: widget.material.id,
        descricao: descricao.text.trim(),
        quantidade: int.parse(quantidade.text.trim()),
        imagePath: imagePath,
        createdAt: widget.material.createdAt,
      );

      await _service.atualizarMaterialMarketing(atualizado);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material atualizado com sucesso'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
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
                  setState(() => _novaImagem = image);
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
                  setState(() => _novaImagem = image);
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
    if (int.tryParse(v) == null || int.parse(v) <= 0) {
      return 'Informe um número válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _novaImagem?.path ?? _imagemAtualPath;

    final hasImage = imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Material'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// 🖼️ IMAGEM (COM ZOOM)
            Column(
              children: [
                GestureDetector(
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
                    borderRadius: BorderRadius.circular(12),
                    child: hasImage
                        ? Image.file(
                            File(imagePath),
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
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Trocar imagem'),
                  onPressed: _selecionarImagem,
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 📝 DESCRIÇÃO
            TextFormField(
              controller: descricao,
              validator: _obrigatorio,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),

            const SizedBox(height: 12),

            /// 🔢 QUANTIDADE
            TextFormField(
              controller: quantidade,
              validator: _numero,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),

            const SizedBox(height: 24),

            /// 💾 SALVAR
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _salvando ? null : salvar,
                child: _salvando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
