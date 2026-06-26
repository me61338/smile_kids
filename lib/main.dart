import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String role = "admin"; // staff أو admin

  void addStudent() {
    FirebaseFirestore.instance.collection('students').add({
      'name': 'New Child',
      'status': 'present',
      'time': DateTime.now().toString(),
    });
  }

  void deleteStudent(String id) {
    FirebaseFirestore.instance.collection('students').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smile Kids Live"),
        backgroundColor: Colors.blue,
      ),

      floatingActionButton: role == "admin"
          ? FloatingActionButton(
              onPressed: addStudent,
              child: const Icon(Icons.add),
            )
          : null,

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('students')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No students yet"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];

              return Card(
                child: ListTile(
                  title: Text(doc['name']),
                  subtitle: Text(doc['status']),

                  trailing: role == "admin"
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteStudent(doc.id),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
