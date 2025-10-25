import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

class TestChartClick extends StatefulWidget {
  const TestChartClick({super.key});

  @override
  State<TestChartClick> createState() => _TestChartClickState();
}

class _TestChartClickState extends State<TestChartClick> {
  late final GraphifyController _controller;
  final List<Map<String, dynamic>> _clickEvents = [];
  String _status = 'Ready to test clicks';

  @override
  void initState() {
    super.initState();
    _controller = GraphifyController();
    _controller.chartClickedEvent.listen((data) {
      setState(() {
        _clickEvents.add(data);
        _status = 'Click received: ${data['name'] ?? 'Unknown'}';
      });

      log('TEST: Chart click received: $data');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            _status,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Expanded(
              child: ListView.builder(
                itemCount: _clickEvents.length,
                itemBuilder: (context, index) {
                  final event = _clickEvents[index];
                  return Card(
                    child: ListTile(
                      title: Text('Event ${index + 1}'),
                      subtitle: Text(
                        'Name: ${event['name'] ?? 'N/A'}\n'
                        'Value: ${event['value'] ?? 'N/A'}\n'
                        'Series: ${event['seriesName'] ?? 'N/A'}\n'
                        'Index: ${event['dataIndex'] ?? 'N/A'}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GraphifyView(
              controller: _controller,
              initialOptions: const {
                "tooltip": {
                  "trigger": "axis",
                  "axisPointer": {"type": "shadow"}
                },
                "legend": {
                  "data": ["Sales", "Marketing"]
                },
                "xAxis": {
                  "type": "category",
                  "data": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                },
                "yAxis": {"type": "value"},
                "series": [
                  {
                    "name": "Sales",
                    "type": "bar",
                    "data": [120, 200, 150, 80, 70, 110, 130],
                    "itemStyle": {"color": "#5470c6"}
                  },
                  {
                    "name": "Marketing",
                    "type": "bar",
                    "data": [60, 100, 75, 40, 35, 55, 65],
                    "itemStyle": {"color": "#91cc75"}
                  }
                ]
              },
            ),
          ),
        ),
      ],
    );
  }
}
