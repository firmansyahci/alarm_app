import 'dart:math';

import 'package:alarm_app/models/alarm.dart';
import 'package:flutter/material.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  DateTime _now = DateTime.now();
  int hour = 6;
  double minute = 0;

  bool isPressed = false;

  final List<Alarm> _alarmList = [
    Alarm(time: '20:40'),
    Alarm(time: '09:00'),
  ];

  String twoDigits(int number) {
    if (number < 0) {
      return '';
    }
    if (number < 10) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  String getFormattedTime() {
    return '${twoDigits(hour)}:${twoDigits(minute.toInt())}';
  }

  void _onIncreaseHour(double upPosition) async {
    setState(() {
      _now = _now.add(const Duration(hours: 1));
      if (hour == 23) {
        hour = 0;
      } else {
        hour += 1;
      }
    });
  }

  void _onIncreaseMinute(double upPosition) async {
    setState(() {
      if (minute.toInt() == 59) {
        minute = 0;
      } else {
        minute += upPosition / 10;
      }
    });
  }

  void _onDecreaseMinute(double downPosition) async {
    setState(() {
      if (minute.toInt() == 0) {
        minute = 59;
      } else {
        minute -= downPosition / 10;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Analog Clock
          GestureDetector(
            onTap: () {
              _onIncreaseHour(0);
            },
            onPanUpdate: (details) {
              int sensitivity = 1;
              if (details.delta.dy > sensitivity) {
                _onDecreaseMinute(details.delta.dy);
              }
              if (details.delta.dy < -sensitivity) {
                _onIncreaseMinute(-details.delta.dy);
              }
            },
            child: Container(
              width: 300,
              height: 300,
              padding: const EdgeInsets.all(20.0),
              child: Transform.rotate(
                child: CustomPaint(
                  painter: Clock(_now, hour, minute.toInt()),
                ),
                angle: -pi / 2,
              ),
            ),
          ),
          // Digital Clock
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              getFormattedTime(),
            ),
          ),
          // List alarm
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: _alarmList.length,
                itemBuilder: (ctx, i) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _alarmList.removeAt(i);
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          _alarmList[i].time,
                        ),
                      ),
                      Switch(
                        value: _alarmList[i].isActive,
                        onChanged: (value) {
                          setState(() {
                            _alarmList[i].isActive = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            _alarmList.add(Alarm(
              time: getFormattedTime(),
            ));
          });
        },
      ),
    );
  }
}

class Clock extends CustomPainter {
  final DateTime dateTime;
  final int hour;
  final int minute;

  Clock(this.dateTime, this.hour, this.minute);
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.height / 2;
    double centerY = size.width / 2;
    Offset center = Offset(centerX, centerY);
    double radius = min(centerX, centerY);

    // Minute Calculation
    double minX = centerX + size.width * 0.35 * cos((minute * 6) * pi / 180);
    double minY = centerY + size.width * 0.35 * sin((minute * 6) * pi / 180);

    Paint minHandBrush = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    // Hour Calculation
    double hourX = centerX + size.width * 0.3 * cos((hour * 30) * pi / 180);
    double hourY = centerY + size.width * 0.3 * sin((hour * 30) * pi / 180);

    Paint hourHandBrush = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    final fillBrush = Paint()..color = Colors.amberAccent;
    final centerFillBrush = Paint()..color = Colors.white;
    final outlineFillBrush = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    canvas.drawCircle(center, radius, fillBrush);
    canvas.drawCircle(center, radius, outlineFillBrush);

    canvas.drawLine(center, Offset(minX, minY), minHandBrush);
    canvas.drawLine(center, Offset(hourX, hourY), hourHandBrush);

    canvas.drawCircle(center, 16, centerFillBrush);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
