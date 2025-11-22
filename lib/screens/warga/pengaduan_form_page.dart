import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaduanFormPage extends StatefulWidget {
  @override
  _PengaduanFormPageState createState() => _PengaduanFormPageState();
}

class _PengaduanFormPageState extends State<PengaduanFormPage> {
  final TextEditingController _pengaduanController = TextEditingController();
  late Future<String?> _userEmailFuture;

  @override
  void initState() {
    super.initState();
    _userEmailFuture = _loadUserEmail();
  }

  Future<String?> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  void _kirimPengaduan() async {
    final userEmail = await _userEmailFuture;
    if (_pengaduanController.text.isNotEmpty && userEmail != null) {
      await FirebaseFirestore.instance.collection('pengaduan').add({
        'isi': _pengaduanController.text,
        'createdBy': userEmail,
        'status': 'Terkirim',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _pengaduanController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengaduan berhasil dikirim!')),
      );
      // Force rebuild of the status list by re-fetching the future. This is a simple approach.
      setState(() {
        _userEmailFuture = _loadUserEmail();
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi pengaduan dan pastikan Anda login.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaduan & Aspirasi"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Buat Pengaduan Baru",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _pengaduanController,
              decoration: InputDecoration(
                labelText: "Tulis pengaduan Anda di sini...",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _kirimPengaduan,
              child: Text("Kirim Pengaduan"),
            ),
            Divider(height: 40),
            Text(
              "Status Pengaduan Anda",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _buildStatusPengaduan(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPengaduan() {
    return FutureBuilder<String?>(
      future: _userEmailFuture,
      builder: (context, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!futureSnapshot.hasData || futureSnapshot.data == null) {
          return Center(child: Text("Tidak bisa memuat data pengguna."));
        }
        
        final userEmail = futureSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pengaduan')
              .where('createdBy', isEqualTo: userEmail)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (streamSnapshot.hasError) {
              return Center(child: Text("Error: ${streamSnapshot.error}"));
            }
            if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Anda belum membuat pengaduan."),
              ));
            }
            
            final docs = streamSnapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(data['isi'] ?? 'Tidak ada isi'),
                    subtitle: Text("Status: ${data['status'] ?? 'N/A'}"),
                    trailing: Chip(label: Text(data['status'] ?? 'N/A')),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
