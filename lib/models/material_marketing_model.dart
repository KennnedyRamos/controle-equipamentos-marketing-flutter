import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialMarketingModel {
  final String id;
  final String descricao;
  final int quantidade;
  final String? imagePath;
  final Timestamp createdAt;

  MaterialMarketingModel({
    required this.id,
    required this.descricao,
    required this.quantidade,
    this.imagePath,
    required this.createdAt,
  });

  factory MaterialMarketingModel.fromMap(Map<String, dynamic> map) {
    return MaterialMarketingModel(
      id: map['id'],
      descricao: map['descricao'] ?? '',
      quantidade: map['quantidade'] ?? 0,
      imagePath: map['imagePath'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'quantidade': quantidade,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }
}
