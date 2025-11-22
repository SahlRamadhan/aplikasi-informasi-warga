import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerPage extends StatefulWidget {
  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  PlayerState? _playerState;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        _playerState = s;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _play(String assetPath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    setState(() {
      _currentlyPlayingId = assetPath;
    });
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _currentlyPlayingId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Podcast & Audio Warga"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('audio_komunitas').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return Center(child: Text("Belum ada audio yang tersedia."));

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              final String assetPath = data['assetPath'] ?? '';
              final bool isPlaying = _currentlyPlayingId == assetPath && _playerState == PlayerState.playing;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.audiotrack, size: 40, color: Theme.of(context).primaryColor),
                  title: Text(data['judul'] ?? 'Tanpa Judul'),
                  subtitle: Text(data['deskripsi'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle, size: 30),
                    onPressed: assetPath.isEmpty ? null : () {
                      if (isPlaying) {
                        _stop();
                      } else {
                        _play(assetPath);
                      }
                    },
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
