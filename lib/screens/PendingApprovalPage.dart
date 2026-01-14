import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Registrations'),
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase());
              },
            ),
          ),

          // 📋 Pending list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No pending registrations'),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullName'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No matching results'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👤 Name
                            Text(
                              data['fullName'] ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // ⬜ Info box (placeholder)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(Icons.badge, 'IC Number', data['icNumber']),
                                  const SizedBox(height: 6),
                                  _infoRow(Icons.phone, 'Phone', data['phoneNumber']),
                                  const SizedBox(height: 6),
                                  _infoRow(Icons.email, 'Email', data['email']),
                                  const SizedBox(height: 6),
                                  _infoRow(Icons.work, 'Role', data['role']),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ✅❌ Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await doc.reference.update({
                                        'status': 'approved',
                                      });

                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account approved'),
                                        ),
                                      );
                                    },
                                    child: const Text('Approve'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    onPressed: () async {
                                      String selectedReason = 'Incomplete information';

                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Reject Application'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Please select a rejection reason:',
                                                  style: TextStyle(fontSize: 14),
                                                ),
                                                const SizedBox(height: 12),
                                                DropdownButtonFormField<String>(
                                                  value: selectedReason,
                                                  items: [
                                                    'Incomplete information',
                                                    'Invalid IC number',
                                                    'Duplicate application',
                                                    'Does not meet requirements',
                                                    'Other',
                                                  ].map((reason) {
                                                    return DropdownMenuItem(
                                                      value: reason,
                                                      child: Text(reason),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      selectedReason = value;
                                                    }
                                                  },
                                                  decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                child: const Text('Reject'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirm == true) {
                                        await doc.reference.update({
                                          'status': 'rejected',
                                          'rejectionReason': selectedReason,
                                          'rejectedAt': FieldValue.serverTimestamp(),
                                        });

                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Application rejected'),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Reject'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}