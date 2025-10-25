import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioAutoPlayPage extends StatefulWidget {
  const AudioAutoPlayPage({Key? key}) : super(key: key);

  @override
  State<AudioAutoPlayPage> createState() => _AudioAutoPlayPageState();
}

class _AudioAutoPlayPageState extends State<AudioAutoPlayPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playAudio();
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.play(AssetSource('audio.mp3'));
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _resumeAudio() async {
    await _audioPlayer.resume();
    setState(() {
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Play Audio'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlaying ? Icons.music_note : Icons.music_off,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              isPlaying ? 'Audio Playing...' : 'Audio Paused',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: isPlaying ? _pauseAudio : _resumeAudio,
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? 'Pause' : 'Resume'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}