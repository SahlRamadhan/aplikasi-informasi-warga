import 'dart:io';

import 'package:aplikasi_informasi_warga/services/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KelolaPengaduanPage extends StatelessWidget {
  void _updateStatus(BuildContext context, DocumentSnapshot doc) {
    String currentStatus = doc['status'] ?? 'Terkirim';

    // Define the order of statuses
    const statuses = ['Terkirim', 'Dibaca', 'Selesai'];

    // Create a menu of options
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Ubah Status Pengaduan'),
          children: statuses.map((String status) {
            return SimpleDialogOption(
              onPressed: () {
                doc.reference.update({'status': status}).then((_) {
                  AudioService.playNotificationSound();
                });
                Navigator.pop(context);
              },
              child: Text(
                status,
                style: TextStyle(
                  fontWeight: currentStatus == status
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: currentStatus == status
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(imagePath)),
              TextButton(
                child: Text("Tutup"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kelola Pengaduan")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pengaduan')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Belum ada pengaduan dari warga."));
          }
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String status = data['status'] ?? 'N/A';
              // Read 'imagePath' which contains the local file path
              String? imagePath = data['imagePath'];

              Color statusColor;
              switch (status) {
                case 'Selesai':
                  statusColor = Colors.green;
                  break;
                case 'Dibaca':
                  statusColor = Colors.orange;
                  break;
                default:
                  statusColor = Colors.grey;
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: ListTile(
                  leading: imagePath != null
                      ? GestureDetector(
                          onTap: () => _showImageDialog(context, imagePath),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            // Use Image.file to display the local image
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Show a placeholder if the file is not found
                                return Icon(Icons.broken_image, size: 40);
                              },
                            ),
                          ),
                        )
                      : null,
                  title: Text(data['isi'] ?? 'Tidak ada konten'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Dari: ${data['createdBy'] ?? 'Unknown'}"),
                  ),
                  trailing: InkWell(
                    onTap: () => _updateStatus(context, doc),
                    child: Chip(
                      label: Text(
                        status,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: statusColor,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
