import 'package:aplikasi_informasi_warga/screens/warga/offline_video_player_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OfflineVideoListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Komunitas"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('video_komunitas').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text("Belum ada video yang tersedia."));

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              final String assetPath = data['assetPath'] ?? '';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.video_library, size: 40, color: Theme.of(context).primaryColor),
                  title: Text(data['judul'] ?? 'Tanpa Judul'),
                  subtitle: Text(data['deskripsi'] ?? ''),
                  trailing: Icon(Icons.chevron_right),
                  onTap: assetPath.isEmpty ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfflineVideoPlayerPage(
                          assetPath: assetPath,
                          title: data['judul'] ?? 'Tanpa Judul',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
