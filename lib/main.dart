import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const StopwatchApp());
}

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontSize: 64, shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.white,
            ),
          ]),
          titleMedium: TextStyle(color: Colors.white, fontSize: 20, shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.white,
            ),
          ]),
        ),
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
  late Stopwatch _stopwatch;
  late Duration _elapsedTime;
  late bool _isRunning;
  late List<Duration> _lapTimes;
  late Duration _lapTime;
  late bool _showResetButton;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _elapsedTime = Duration.zero;
    _isRunning = false;
    _lapTimes = [];
    _lapTime = Duration.zero;
    _loadLapTimes();
    _showResetButton = false;
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _loadLapTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? lapTimesString = prefs.getStringList('lapTimes');
    if (lapTimesString != null) {
      setState(() {
        _lapTimes = lapTimesString
            .map((lapTimeString) =>
            Duration(milliseconds: int.parse(lapTimeString)))
            .toList();
      });
    }
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _showResetButton = false;
    });
    _stopwatch.start();
    _updateTime();
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
      _showResetButton = true;
    });
    _stopwatch.stop();
  }

  void _lapTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lapTimes.insert(0, _elapsedTime - _lapTime);
      _lapTime = _elapsedTime;
      prefs.setStringList(
          'lapTimes', _lapTimes.map((duration) => duration.inMilliseconds.toString()).toList());
    });
  }

  void _resetTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _elapsedTime = Duration.zero;
      _isRunning = false;
      _lapTimes.clear();
      _lapTime = Duration.zero;
      _showResetButton = false;
    });
    _stopwatch.reset();
    prefs.remove('lapTimes');
  }

  void _updateTime() {
    if (_isRunning) {
      setState(() {
        _elapsedTime = _stopwatch.elapsed;
      });
      Future.delayed(const Duration(milliseconds: 100), _updateTime);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds =
    twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return "$twoDigitMinutes:$twoDigitSeconds:$twoDigitMilliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _resetTimer,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.3),
              child: Text(
                _formatDuration(_elapsedTime),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopStopwatch : _startStopwatch,
                  child: Text(_isRunning ? 'Stop' : 'Start'),
                ),
                ElevatedButton(
                  onPressed: _showResetButton ? _resetTimer : _lapTimer,
                  child: Text(_showResetButton ? 'Reset' : 'Lap'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _lapTimes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Lap ${_lapTimes.length - index}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _formatDuration(_lapTimes[index]),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
