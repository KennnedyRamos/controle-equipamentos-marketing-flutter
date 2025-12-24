import 'package:cloud_firestore/cloud_firestore.dart';

class EquipamentoModel {
  final String id;
  final String tipo;
  final String modelo;
  final String marca;
  final String? voltagem;
  final String? rg;
  final String? etiqueta;
  final int? quantidade;
  final Timestamp createdAt;
  final String? imagePath;

  EquipamentoModel({
    required this.id,
    required this.tipo,
    required this.modelo,
    required this.marca,
    this.voltagem,
    this.rg,
    this.etiqueta,
    this.quantidade,
    required this.createdAt,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'modelo': modelo,
      'marca': marca,
      'voltagem': voltagem,
      'rg': rg,
      'etiqueta': etiqueta,
      'quantidade': quantidade,
      'createdAt': createdAt,
      'imagePath': imagePath,
    }..removeWhere((key, value) => value == null);
  }

  factory EquipamentoModel.fromMap(Map<String, dynamic> map) {
    return EquipamentoModel(
      id: map['id'],
      tipo: map['tipo'],
      modelo: map['modelo'],
      marca: map['marca'],
      voltagem: map['voltagem'],
      rg: map['rg'],
      etiqueta: map['etiqueta'],
      quantidade: map['quantidade'],
      createdAt: map['createdAt'],
      imagePath: map['imagePath'],
    );
  }
}
