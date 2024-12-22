import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Domů",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}