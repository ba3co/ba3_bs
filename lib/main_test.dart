import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  runApp(const MaterialApp(home: TestFirestore()));
}

class TestFirestore extends StatelessWidget {
  const TestFirestore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firestore Test")),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('test').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found.'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(title: Text(doc.id));
              }).toList(),
            );
          }
        },
      ),
    );
  }
}