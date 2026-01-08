import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preacher.dart';

class PreacherPage {
  final List<Preacher> items;
  final DocumentSnapshot? lastDocument;

  const PreacherPage({required this.items, required this.lastDocument});
}

class PreacherAPIHandler {
  PreacherAPIHandler({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final String _collection = 'preachers';

  Future<PreacherPage> fetchPreachers({
    String? search,
    String? region,
    String? specialization,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _db.collection(_collection).orderBy('fullName');

    if (region != null && region.isNotEmpty && region != 'All') {
      query = query.where('region', isEqualTo: region);
    }

    if (specialization != null &&
        specialization.isNotEmpty &&
        specialization != 'All') {
      query = query.where('specialization', arrayContains: specialization);
    }

    if (search != null && search.isNotEmpty) {
      // Basic prefix search on fullName using range
      final endText = _endTextForSearch(search);
      query = query
          .where('fullName', isGreaterThanOrEqualTo: search)
          .where('fullName', isLessThan: endText);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    final items =
        snapshot.docs.map((doc) => Preacher.fromFirestore(doc)).toList();
    final last = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return PreacherPage(items: items, lastDocument: last);
  }

  Future<Preacher?> getPreacherById(String preacherId) async {
    final snapshot =
        await _db
            .collection(_collection)
            .where('preacherId', isEqualTo: preacherId)
            .limit(1)
            .get();
    if (snapshot.docs.isEmpty) return null;
    return Preacher.fromFirestore(snapshot.docs.first);
  }

  Future<void> updatePreacher(String docId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).doc(docId).update(data);
  }

  Future<void> createPreacher(Preacher preacher) async {
    await _db.collection(_collection).add(preacher.toFirestore());
  }

  String _endTextForSearch(String text) {
    if (text.isEmpty) return text;
    final lastChar = text.codeUnitAt(text.length - 1);
    final nextLastChar = String.fromCharCode(lastChar + 1);
    return text.substring(0, text.length - 1) + nextLastChar;
  }
}
