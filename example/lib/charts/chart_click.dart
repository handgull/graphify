import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

class ChartClick extends StatefulWidget {
  const ChartClick({super.key});

  @override
  State<ChartClick> createState() => _ChartClickState();
}

class _ChartClickState extends State<ChartClick> {
  final controller = GraphifyController();
  late final StreamSubscription<Map<String, dynamic>> clicks;
  String clicked = 'Tap a bar';

  @override
  void initState() {
    super.initState();
    clicks = controller.chartClickedEvent.listen(
      (event) =>
          setState(() => clicked = '${event['name']}: ${event['value']}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(clicked)),
        Expanded(
          child: GraphifyView(
            controller: controller,
            initialOptions: const {
              'backgroundColor': 'transparent',
              'xAxis': {
                'type': 'category',
                'data': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
              },
              'yAxis': {'type': 'value'},
              'series': [
                {
                  'type': 'bar',
                  'data': [120, 200, 150, 80, 70],
                },
              ],
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    unawaited(clicks.cancel());
    controller.dispose();
    super.dispose();
  }
}
