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
  final String _collection = 'users'; // Changed to users collection

  Future<PreacherPage> fetchPreachers({
    String? search,
    String? region,
    String? specialization,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    // Fetch users where role is 'Preacher'
    Query query = _db
        .collection(_collection)
        .where('role', isEqualTo: 'Preacher');

    if (region != null && region.isNotEmpty && region != 'All') {
      query = query.where('region', isEqualTo: region);
    }

    if (specialization != null &&
        specialization.isNotEmpty &&
        specialization != 'All') {
      query = query.where('specialization', arrayContains: specialization);
    }

    // Note: Search removed to avoid index requirements
    // You can add search filtering after fetching the data

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    var items =
        snapshot.docs.map((doc) => Preacher.fromFirestore(doc)).toList();

    // Sort by fullName in code instead of using orderBy
    items.sort((a, b) => a.fullName.compareTo(b.fullName));

    // Apply search filter if provided
    if (search != null && search.isNotEmpty) {
      items =
          items
              .where(
                (p) => p.fullName.toLowerCase().contains(search.toLowerCase()),
              )
              .toList();
    }

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
}
