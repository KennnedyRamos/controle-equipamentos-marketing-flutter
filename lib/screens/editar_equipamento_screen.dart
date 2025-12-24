import 'dart:io';

import 'package:estoque_vendas/widgets/animated_3d_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/equipamento_model.dart';
import '../services/firestore_service.dart';
import '../services/image_service.dart';
import 'visualizar_imagem_screen.dart';

class EditarEquipamentoScreen extends StatefulWidget {
  final EquipamentoModel equipamento;

  const EditarEquipamentoScreen({
    super.key,
    required this.equipamento,
  });

  @override
  State<EditarEquipamentoScreen> createState() =>
      _EditarEquipamentoScreenState();
}

class _EditarEquipamentoScreenState extends State<EditarEquipamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();

  late final TextEditingController modelo;
  late final TextEditingController marca;
  late final TextEditingController rg;
  late final TextEditingController etiqueta;
  late final TextEditingController quantidade;

  /// ⚡ VOLTAGEM (SOMENTE REFRIGERADOR)
  String? _voltagemSelecionada;

  /// 🖼️ IMAGEM
  XFile? _novaImagem;
  String? _imagemAtualPath;

  bool get isRefrigerador => widget.equipamento.tipo == "REFRIGERADOR";

  @override
  void initState() {
    super.initState();

    modelo = TextEditingController(text: widget.equipamento.modelo);
    marca = TextEditingController(text: widget.equipamento.marca);
    rg = TextEditingController(text: widget.equipamento.rg ?? '');
    etiqueta = TextEditingController(text: widget.equipamento.etiqueta ?? '');
    quantidade = TextEditingController(
      text: widget.equipamento.quantidade?.toString() ?? '',
    );

    _voltagemSelecionada = widget.equipamento.voltagem;
    _imagemAtualPath = widget.equipamento.imagePath;
  }

  @override
  void dispose() {
    modelo.dispose();
    marca.dispose();
    rg.dispose();
    etiqueta.dispose();
    quantidade.dispose();
    super.dispose();
  }

  /// 💾 SALVAR ALTERAÇÕES
  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    String? imagePath = _imagemAtualPath;

    /// 📷 Se trocou a imagem, salva nova
    if (_novaImagem != null) {
      imagePath = await ImageService.salvarImagemLocal(
        _novaImagem!,
        widget.equipamento.id,
      );
    }

    final atualizado = EquipamentoModel(
      id: widget.equipamento.id,
      tipo: widget.equipamento.tipo,
      modelo: modelo.text.trim(),
      marca: marca.text.trim(),
      voltagem: isRefrigerador ? _voltagemSelecionada : null,
      rg: isRefrigerador ? rg.text.trim() : null,
      etiqueta: isRefrigerador ? etiqueta.text.trim() : null,
      quantidade:
          isRefrigerador ? 1 : int.tryParse(quantidade.text.trim()) ?? 0,
      imagePath: imagePath,
      createdAt: widget.equipamento.createdAt,
    );

    await _service.atualizarEquipamento(atualizado);

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
    if (int.tryParse(v) == null) return 'Informe um número válido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _novaImagem?.path ?? _imagemAtualPath;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.equipamento.tipo}'),
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
                  onTap: imagePath != null && File(imagePath).existsSync()
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
                    child: imagePath != null && File(imagePath).existsSync()
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
                              child: Icon(Icons.image_not_supported, size: 48),
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

            TextFormField(
              controller: modelo,
              validator: _obrigatorio,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: marca,
              validator: _obrigatorio,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            const SizedBox(height: 12),

            /// 🔌 CAMPOS EXCLUSIVOS PARA REFRIGERADOR
            if (isRefrigerador) ...[
              DropdownButtonFormField<String>(
                value: _voltagemSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Voltagem',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '127V', child: Text('127V')),
                  DropdownMenuItem(value: '220V', child: Text('220V')),
                ],
                onChanged: (value) {
                  setState(() => _voltagemSelecionada = value);
                },
                validator: (value) =>
                    value == null ? 'Selecione a voltagem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: rg,
                validator: _obrigatorio,
                decoration: const InputDecoration(labelText: 'RG'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: etiqueta,
                validator: _obrigatorio,
                decoration: const InputDecoration(labelText: 'Etiqueta'),
              ),
            ] else ...[
              TextFormField(
                controller: quantidade,
                validator: _numero,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],

            const SizedBox(height: 24),

            Animated3DButton(
              text: 'Salvar alterações',
              width: double.infinity,
              onPressed: salvar,
            ),
          ],
        ),
      ),
    );
  }
}
