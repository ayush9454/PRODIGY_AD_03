import 'package:flutter/material.dart';

void main() {
  runApp(const StopwatchApp());
}

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  Duration _elapsedTime = Duration.zero;
  late Stopwatch _stopwatch;
  late bool _isRunning;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _isRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${_elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                  '${(_elapsedTime.inSeconds.remainder(60)).toString().padLeft(2, '0')}:'
                  '${(_elapsedTime.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: !_isRunning ? null : _pauseTimer,
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _stopwatch.start();
    _updateElapsedTime();
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _stopwatch.stop();
  }

  void _resetTimer() {
    setState(() {
      _elapsedTime = Duration.zero;
      _isRunning = false;
    });
    _stopwatch.reset();
  }

  void _updateElapsedTime() {
    if (_isRunning) {
      setState(() {
        _elapsedTime = _stopwatch.elapsed;
      });
      Future.delayed(const Duration(milliseconds: 10), _updateElapsedTime);
    }
  }
}
