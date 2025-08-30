import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MaterialsStatementsPage extends StatefulWidget {
  const MaterialsStatementsPage({super.key});

  @override
  _MaterialsStatementsPageState createState() =>
      _MaterialsStatementsPageState();
}

class _MaterialsStatementsPageState extends State<MaterialsStatementsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore instance for test mode (use different app/database if needed)
  final firestoreTest = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'test'
  );

  // Number of items per page
  final int _limit = 100;

  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  final List<Map<String, dynamic>> _materialsData = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    Query query =
    _firestore.collection("accounts_statements").limit(_limit);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final statementsSnapshot = await query.get();

    if (statementsSnapshot.docs.isNotEmpty) {
      _lastDoc = statementsSnapshot.docs.last;

      for (var statementDoc in statementsSnapshot.docs) {
        final statementData = statementDoc.data() as Map<String, dynamic>;
        statementData['id'] = statementDoc.id;

        // Fetch sub-collection of materials for each statement
        final subCollectionSnapshot = await _firestore
            .collection("account_statements")
            .doc(statementDoc.id)
            .collection(statementDoc.id)
            .get();

        List<Map<String, dynamic>> materials = [];
        for (var materialDoc in subCollectionSnapshot.docs) {
          final matData = materialDoc.data();
          matData['id'] = materialDoc.id;
          materials.add(matData);
        }

        statementData['materials'] = materials;
        _materialsData.add(statementData);
      }
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  // Function to add fetched data into test database
  Future<void> _addDataToTestMode() async {
    if (_materialsData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to add')),
      );
      return;
    }

    try {
      for (var statement in _materialsData) {
        final materials = statement['materials'] as List;

        // Add statement into test Firestore
        final docRef = firestoreTest
            .collection("accounts_statements")
            .doc(statement['id']);

        // Save materials inside sub-collection
        for (var material in materials) {
          await docRef
              .collection(statement['id'])
              .doc(material['id'])
              .set(material);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data added successfully in test mode')),
      );debugPrint("copying success");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while adding: $e')),
      );
    }
  }

  Widget _buildDataList(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        if (entry.value is Map) {
          return ExpansionTile(
            title: Text(entry.key),
            children: [_buildDataList(entry.value as Map<String, dynamic>)],
          );
        } else if (entry.value is List) {
          return ExpansionTile(
            title: Text(entry.key),
            children: (entry.value as List).map((item) {
              if (item is Map<String, dynamic>) {
                return _buildDataList(item);
              } else {
                return ListTile(title: Text(item.toString()));
              }
            }).toList(),
          );
        } else {
          return ListTile(
            title: Text(entry.key),
            subtitle: Text(entry.value.toString()),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Materials Statements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addDataToTestMode,
            tooltip: 'Add Data in Test Mode',
          ),
        ],
      ),
      body: _materialsData.isEmpty && !_isLoading
          ? const Center(child: Text('No Data Found'))
          : ListView.builder(
        itemCount: _materialsData.length + 1,
        itemBuilder: (context, index) {
          if (index < _materialsData.length) {
            final statement = _materialsData[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text('Statement: ${statement['id']}'),
                children: [_buildDataList(statement)],
              ),
            );
          } else {
            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasMore
                ? ElevatedButton(
              onPressed: _getData,
              child: const Text('Load More'),
            )
                : const Center(child: Text('No More Data'));
          }
        },
      ),
    );
  }
}
