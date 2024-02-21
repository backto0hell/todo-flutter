import 'package:flutter/material.dart';
import 'package:flutter_todo_project/pages/home_page.dart';

void main() => runApp(
      MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.deepOrangeAccent,
        ),
        home: const HomePage(),
      ),
    );
