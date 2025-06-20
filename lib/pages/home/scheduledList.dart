import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ponder_app/pages/add/addTime.dart';

class ScheduledList extends StatefulWidget {
  final String sensorId;

  const ScheduledList({Key? key, required this.sensorId}) : super(key: key);

  @override
  State<ScheduledList> createState() => _ScheduledListState();
}

class _ScheduledListState extends State<ScheduledList> {
  List<String> scheduledTimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchScheduledTimes();
  }

  Future<void> fetchScheduledTimes() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('sensors')
          .doc(widget.sensorId)
          .get();

      if (doc.exists) {
        List<dynamic>? times = doc.get('times');
        setState(() {
          scheduledTimes = times!.cast<String>();
        });
      }
    } catch (e) {
      print('Error fetching times: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> removeTime(String time) async {
    try {
      await FirebaseFirestore.instance
          .collection('sensors')
          .doc(widget.sensorId)
          .update({
        'times': FieldValue.arrayRemove([time]),
      });

      setState(() {
        scheduledTimes.remove(time);
      });
    } catch (e) {
      print('Error removing time: $e');
      // Optional: show a snackbar or alert
    }
  }

  void _updateSchedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Schedule"),
        content: const Text("Implement schedule update here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Scheduled Times",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (scheduledTimes.isEmpty)
                  const Text("No scheduled times found.")
                else
                  ...scheduledTimes.map((time) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.schedule,
                                    size: 20, color: Colors.blue),
                                const SizedBox(width: 10),
                                Text(time,
                                    style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeTime(time),
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddTime(sensorId: widget.sensorId),
                        ),
                      );

                      if (updated == true) {
                        fetchScheduledTimes(); // refresh the list
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Add Schedule"),
                  ),
                ),
              ],
            ),
    );
  }
}
