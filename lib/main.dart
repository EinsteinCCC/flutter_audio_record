import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Audio Recorder',
      home: AudioRecorderPage(),
    );
  }
}

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  String _path = 'audio_record.aac'; // Specifying the file name directly

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _audioRecorder!.openRecorder();
    _audioRecorder!.setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future<void> _startRecording() async {
    await _audioRecorder!.startRecorder(toFile: _path);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _sendEmail() async {
    final Email email = Email(
      body: 'Here is the recorded audio.',
      subject: 'Audio Recording',
      recipients: ['example@example.com'],
      attachmentPaths: [_path],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Audio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmail,
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    super.dispose();
  }
}