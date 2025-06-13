import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ponder_app/main.dart';
import 'package:http/http.dart' as http;

class homePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List<dynamic> feeds = [];
  Timer? _timer;
  Color progressColor = Colors.grey;
  bool _autoFeeder = false;

  Future<void> fetchFeeds() async {
    const url =
        "https://api.thingspeak.com/channels/2983100/feeds.json?api_key=GQHR6ZQTTHYCV08L&results=2";
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = response.body;
      final json = jsonDecode(body);
      final newFeeds = json["feeds"];

      print(newFeeds);
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
  void initState() {
    super.initState();
    fetchFeeds(); // initial fetch

    // fetch every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchFeeds());
  }

  @override
  void dispose() {
    _timer?.cancel(); // clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content() {
      return CarouselSlider(
        items: keys.map(
          (e) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxHeight * 0.28;

                return (e == "New"
                    ? (Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 166, 227, 233),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text("idk")))
                    : (Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 35, horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 166, 227, 233),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: size,
                                    height: size,
                                    child: CircularProgressIndicator(
                                      value: 1,
                                      strokeWidth: 20,
                                      color: progressColor,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Temperature"),
                                      Text(
                                        feeds.length > 0
                                            ? "${feeds[0]["field1"] ?? 'N/A'}"
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
                            SizedBox(
                              height: 35,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 15),
                              margin: EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Autor Feeder",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Switch(
                                    value: _autoFeeder,
                                    onChanged: (value) {
                                      setState(() {
                                        _autoFeeder = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))));
              },
            );
          },
        ).toList(),
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          aspectRatio: 7.0,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enableInfiniteScroll: false,
        ),
      );
    }

    return Scaffold(
      body: content(),
    );
  }
}
