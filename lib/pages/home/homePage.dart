import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ponder_app/pages/home/monitoringCard.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> keys = [];
  bool isLoading = true;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadKeysFromFirestore();
  }

  Future<void> loadKeysFromFirestore() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      final data = doc.data();
      if (data != null && data['apiKeys'] is List) {
        setState(() {
          keys = List<String>.from(data['apiKeys']);
          isLoading = false;
        });
      } else {
        setState(() {
          keys = [];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        keys = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyCard() {
      return Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 166, 227, 233),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text("idk"));
    }

    Widget content() {
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return CarouselSlider(
          items: keys.map(
            (e) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxHeight * 0.28;

                  return (e == "New"
                      ? (emptyCard())
                      : (MonitoringCard(
                          apiKey: e,
                          boxSize: size,
                          userId: user!.uid,
                          onDelete: () {
                            setState(() {
                              keys.remove(e); // remove from local state
                            });
                          },
                        )));
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
    }

    return Scaffold(
      body: content(),
    );
  }
}
