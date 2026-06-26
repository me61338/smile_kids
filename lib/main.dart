import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveSessionsPage extends StatelessWidget {
  const LiveSessionsPage({super.key});

  void addSession() {
    FirebaseFirestore.instance.collection('sessions').add({
      'childName': 'New Child',
      'childrenCount': 1,
      'note': '',
      'createdBy': 'staff',
      'startTime': DateTime.now().toIso8601String(),
      'endTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      'totalMoney': 60,
      'ended': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Smile Kids'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addSession,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('sessions').snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No data yet'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['childName'] ?? ''),
                  subtitle: Text(data['createdBy'] ?? ''),
                  trailing: Text('${data['totalMoney']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
