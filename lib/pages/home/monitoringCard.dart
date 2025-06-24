import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ponder_app/pages/home/scheduledList.dart';

class MonitoringCard extends StatefulWidget {
  final double boxSize;
  final String apiKey;
  final VoidCallback onDelete;
  final String userId;

  const MonitoringCard({
    Key? key,
    required this.apiKey,
    required this.boxSize,
    required this.onDelete,
    required this.userId,
  }) : super(key: key);

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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sensor?'),
        content:
            const Text('Are you sure you want to delete this sensor card?'),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog

              try {
                final docRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId);

                await docRef.update({
                  'apiKey': FieldValue.arrayRemove([widget.apiKey])
                });

                widget.onDelete(); // remove card from UI
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
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
        child: Stack(
          children: [
            SingleChildScrollView(
              // place it first
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: widget.boxSize,
                          height: widget.boxSize + 15,
                          child: Container(
                            padding: const EdgeInsets.only(top: 15),
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 20,
                              color: progressColor,
                            ),
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
            // Put the delete button LAST so it sits on top
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _confirmDelete,
              ),
            ),
          ],
        ));
  }
}
