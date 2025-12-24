import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estoque_vendas/widgets/animated_3d_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/equipamento_model.dart';
import '../services/firestore_service.dart';
import '../services/image_service.dart';
import 'visualizar_imagem_screen.dart';

class CadastrarEquipamentoScreen extends StatefulWidget {
  const CadastrarEquipamentoScreen({super.key});

  @override
  State<CadastrarEquipamentoScreen> createState() =>
      _CadastrarEquipamentoScreenState();
}

class _CadastrarEquipamentoScreenState
    extends State<CadastrarEquipamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirestoreService();

  final modeloController = TextEditingController();
  final marcaController = TextEditingController();
  final rgController = TextEditingController();
  final etiquetaController = TextEditingController();
  final quantidadeController = TextEditingController();

  String? tipoSelecionado;

  /// 🔌 VOLTAGEM
  String? voltagemSelecionada;
  final List<String> voltagens = ['127V', '220V'];

  /// 🖼️ IMAGEM
  XFile? _imagemSelecionada;

  final tipos = [
    "REFRIGERADOR",
    "RACK",
    "JOGOS DE MESA",
    "CERVEJEIRA",
    "BALDE",
    "LUMINOSO",
    "OUTROS",
  ];

  /// 💾 SALVAR
  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final id = FirebaseFirestore.instance.collection('equipamentos').doc().id;

    String? imagePath;

    if (_imagemSelecionada != null) {
      imagePath = await ImageService.salvarImagemLocal(
        _imagemSelecionada!,
        id,
      );
    }

    final isRefrigerador = tipoSelecionado == "REFRIGERADOR";

    final equipamento = EquipamentoModel(
      id: id,
      tipo: tipoSelecionado!,
      modelo: modeloController.text.trim(),
      marca: marcaController.text.trim(),
      voltagem: isRefrigerador ? voltagemSelecionada : null,
      rg: isRefrigerador ? rgController.text.trim() : null,
      etiqueta: isRefrigerador ? etiquetaController.text.trim() : null,
      quantidade:
          isRefrigerador ? 1 : int.tryParse(quantidadeController.text) ?? 0,
      imagePath: imagePath,
      createdAt: Timestamp.now(),
    );

    await _service.cadastrarEquipamento(equipamento);

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

  Widget campo(
    String label,
    TextEditingController controller, {
    bool obrigatorio = false,
    TextInputType? tipo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        validator: (v) => obrigatorio && (v == null || v.trim().isEmpty)
            ? 'Obrigatório'
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRefrigerador = tipoSelecionado == "REFRIGERADOR";
    final outrosTipos = tipoSelecionado != null && !isRefrigerador;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Equipamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: tipos
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                validator: (v) => v == null ? 'Selecione um tipo' : null,
                onChanged: (v) {
                  setState(() {
                    tipoSelecionado = v;
                    voltagemSelecionada = null;
                    modeloController.clear();
                    marcaController.clear();
                    rgController.clear();
                    etiquetaController.clear();
                    quantidadeController.clear();
                  });
                },
              ),

              const SizedBox(height: 12),

              /// 🖼️ IMAGEM
              Column(
                children: [
                  GestureDetector(
                    onTap: _imagemSelecionada != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisualizarImagemScreen(
                                  imagePath: _imagemSelecionada!.path,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: ClipRRect(
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

              campo('Modelo', modeloController, obrigatorio: true),
              campo('Marca', marcaController, obrigatorio: true),

              if (isRefrigerador) ...[
                DropdownButtonFormField<String>(
                  value: voltagemSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Voltagem',
                    border: OutlineInputBorder(),
                  ),
                  items: voltagens
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        ),
                      )
                      .toList(),
                  validator: (v) => v == null ? 'Selecione a voltagem' : null,
                  onChanged: (v) {
                    setState(() {
                      voltagemSelecionada = v;
                    });
                  },
                ),
                const SizedBox(height: 12),
                campo('RG', rgController, obrigatorio: true),
                campo('Etiqueta', etiquetaController, obrigatorio: true),
              ],

              if (outrosTipos)
                campo(
                  'Quantidade',
                  quantidadeController,
                  obrigatorio: true,
                  tipo: TextInputType.number,
                ),

              const SizedBox(height: 24),

              Animated3DButton(
                text: 'Salvar',
                width: double.infinity,
                onPressed: salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
