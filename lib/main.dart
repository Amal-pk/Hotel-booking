import 'package:flutter/material.dart';
import 'package:hotel_booking_app/dashboard/dashboard_page.dart';

void main() {
  runApp(const HotelBookingApp());
}

const _navy = Color(0xFF1E3A5F);
const _pageBg = Color(0xFFF4F5F7);

class HotelBookingApp extends StatelessWidget {
  const HotelBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _pageBg,
        colorScheme: ColorScheme.fromSeed(seedColor: _navy),
        fontFamily: 'Roboto',
      ),
      home: const DashboardPage(),
    );
  }
}
