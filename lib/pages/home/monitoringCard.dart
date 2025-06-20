import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ponder_app/pages/home/scheduledList.dart';

class MonitoringCard extends StatefulWidget {
  final double boxSize;
  final String apiKey;

  const MonitoringCard({Key? key, required this.apiKey, required this.boxSize})
      : super(key: key);

  @override
  State<MonitoringCard> createState() => _MonitoringCardState();
}

class _MonitoringCardState extends State<MonitoringCard> {
  late String apiKey;
  List<dynamic> feeds = [];
  Timer? _timer;
  Color progressColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    apiKey = widget.apiKey;
    fetchFeeds();
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchFeeds());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchFeeds() async {
    final url =
        "https://api.thingspeak.com/channels/2983100/feeds.json?api_key=$apiKey&results=2";
    final uri = Uri.parse(url);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = response.body;
      final json = jsonDecode(body);
      final newFeeds = json["feeds"];

      setState(() {
        feeds = newFeeds;

        final value = double.tryParse(feeds[0]["field1"] ?? '');
        if (value != null) {
          if (value > 36) {
            progressColor = Colors.red;
          } else if (value > 28) {
            progressColor = Colors.green;
          } else {
            progressColor = Colors.red;
          }
        } else {
          progressColor = Colors.grey;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentTemp = feeds.isNotEmpty ? feeds[0]["field1"] ?? "N/A" : null;

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 166, 227, 233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        // 💡 Wrap with scroll view
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: widget.boxSize,
                    height: widget.boxSize,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 20,
                      color: progressColor,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Temperature"),
                      Text(
                        feeds.isNotEmpty
                            ? "${currentTemp ?? 'N/A'}"
                            : "Loading...",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            ScheduledList(sensorId: apiKey),
          ],
        ),
      ),
    );
  }
}
