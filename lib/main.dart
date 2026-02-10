import 'package:flutter/material.dart';
import 'package:field_sales_tracker/core/database/database_helper.dart';
import 'package:field_sales_tracker/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const FieldSalesApp());
}

class FieldSalesApp extends StatelessWidget {
  const FieldSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Sales',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
