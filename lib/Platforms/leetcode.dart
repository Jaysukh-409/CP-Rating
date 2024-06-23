import 'package:flutter/material.dart';

class LeetcodePage extends StatefulWidget {
  const LeetcodePage({super.key});

  @override
  State<LeetcodePage> createState() => _LeetcodePageState();
}

class _LeetcodePageState extends State<LeetcodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Leetcode Visualizer'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        // onPressed: () => _showForm(null),
        onPressed: () => {},
      ),
    );
  }
}
