import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/equipamento_model.dart';
import '../models/material_marketing_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===============================
  // 🔹 EQUIPAMENTOS
  // ===============================

  Stream<List<EquipamentoModel>> listarEquipamentos() {
    return _db
        .collection('equipamentos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EquipamentoModel.fromMap(
                  doc.data()..['id'] = doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<List<EquipamentoModel>> listarEquipamentosOnce() async {
    final snapshot = await _db
        .collection('equipamentos')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map(
          (doc) => EquipamentoModel.fromMap(
            doc.data()..['id'] = doc.id,
          ),
        )
        .toList();
  }

  Future<void> cadastrarEquipamento(EquipamentoModel e) async {
    await _db.collection('equipamentos').doc(e.id).set(e.toMap());
  }

  Future<void> atualizarEquipamento(EquipamentoModel e) async {
    await _db
        .collection('equipamentos')
        .doc(e.id)
        .set(e.toMap(), SetOptions(merge: true));
  }

  Future<void> excluirEquipamento(String id) async {
    await _db.collection('equipamentos').doc(id).delete();
  }

  // ===============================
  // 🔹 MATERIAIS DE MARKETING
  // ===============================

  Stream<List<MaterialMarketingModel>> listarMateriaisMarketing() {
    return _db
        .collection('materiais_marketing')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MaterialMarketingModel.fromMap(
                  doc.data()..['id'] = doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<List<MaterialMarketingModel>> listarMateriaisMarketingOnce() async {
    final snapshot = await _db
        .collection('materiais_marketing')
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map(
          (doc) => MaterialMarketingModel.fromMap(
            doc.data()..['id'] = doc.id,
          ),
        )
        .toList();
  }

  Future<void> cadastrarMaterialMarketing(MaterialMarketingModel m) async {
    await _db.collection('materiais_marketing').doc(m.id).set(m.toMap());
  }

  Future<void> atualizarMaterialMarketing(MaterialMarketingModel m) async {
    await _db
        .collection('materiais_marketing')
        .doc(m.id)
        .set(m.toMap(), SetOptions(merge: true));
  }

  Future<void> excluirMaterialMarketing(String id) async {
    await _db.collection('materiais_marketing').doc(id).delete();
  }
}
