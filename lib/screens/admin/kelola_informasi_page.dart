import 'package:aplikasi_informasi_warga/screens/admin/kelola_informasi_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KelolaInformasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kelola Informasi"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KelolaInformasiForm()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('informasi').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              final youtubeId = data['youtubeVideoId'] as String?;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: ListTile(
                  leading: (youtubeId != null && youtubeId.isNotEmpty)
                      ? Icon(Icons.video_library, color: Colors.red)
                      : Icon(Icons.article),
                  title: Text(data['judul'] ?? 'No Title'),
                  subtitle: Text(data['isi'] ?? 'No Content', maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => KelolaInformasiForm(document: doc)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, doc),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Hapus Informasi"),
          content: Text("Apakah Anda yakin ingin menghapus informasi ini?"),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Hapus", style: TextStyle(color: Colors.red)),
              onPressed: () {
                doc.reference.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
