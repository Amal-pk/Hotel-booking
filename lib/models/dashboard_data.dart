import 'package:flutter/material.dart';

enum RoomStatus { available, occupied, dirty, maintenance, blocked }

extension RoomStatusX on RoomStatus {
  Color get color {
    switch (this) {
      case RoomStatus.available:
        return const Color(0xFF2E9E6C);
      case RoomStatus.occupied:
        return const Color(0xFF5B8DEF);
      case RoomStatus.dirty:
        return const Color(0xFFD65B5B);
      case RoomStatus.maintenance:
        return const Color(0xFFE8944A);
      case RoomStatus.blocked:
        return const Color(0xFF9AA1AC);
    }
  }

  String get label {
    switch (this) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.dirty:
        return 'Dirty';
      case RoomStatus.maintenance:
        return 'Maintenance';
      case RoomStatus.blocked:
        return 'Blocked';
    }
  }
}

class RoomTile {
  final int number;
  final RoomStatus status;
  const RoomTile({required this.number, required this.status});
}

class FloorData {
  final String label;
  final List<RoomTile> rooms;
  const FloorData({required this.label, required this.rooms});
}

class QuickAction {
  final String label;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final String? badge;
  const QuickAction({
    required this.label,
    required this.icon,
    required this.bg,
    required this.iconColor,
    this.badge,
  });
}

class OverviewStat {
  final String label;
  final String value;
  final bool highlighted;
  const OverviewStat({
    required this.label,
    required this.value,
    this.highlighted = false,
  });
}

class VacatingRoom {
  final String roomNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  const VacatingRoom({
    required this.roomNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

/// Hardcoded sample floor plan: two floors, a handful of rooms each, with a
/// mix of statuses so the legend/colors are all represented.
List<FloorData> buildSampleFloors() {
  RoomStatus statusFor(int i, {required bool dirtySeed}) {
    // Deterministic pseudo-variety so the grid looks "real" without random().
    if (dirtySeed && i % 11 == 0) return RoomStatus.dirty;
    if (i % 13 == 0) return RoomStatus.maintenance;
    if (i % 17 == 0) return RoomStatus.blocked;
    if (i == 1 || i == 3)
      return RoomStatus.occupied; // matches "4% occupied" demo stat
    return RoomStatus.available;
  }

  final floor1 = List.generate(
    20,
    (i) => RoomTile(number: 101 + i, status: statusFor(i, dirtySeed: true)),
  );
  final floor2 = List.generate(
    20,
    (i) => RoomTile(number: 201 + i, status: statusFor(i, dirtySeed: false)),
  );

  return [
    FloorData(label: 'Floor 1', rooms: floor1),
    FloorData(label: 'Floor 2', rooms: floor2),
  ];
}

List<QuickAction> buildQuickActions() => const [
  QuickAction(
    label: 'Guest Check-in',
    icon: Icons.event_available_outlined,
    bg: Color(0xFFDFF5E8),
    iconColor: Color(0xFF2E9E6C),
  ),
  QuickAction(
    label: 'Guest Check-Out',
    icon: Icons.logout_outlined,
    bg: Color(0xFFFCE4E4),
    iconColor: Color(0xFFE0685E),
  ),
  QuickAction(
    label: 'Reservations',
    icon: Icons.event_note_outlined,
    bg: Color(0xFFDCE8FB),
    iconColor: Color(0xFF5B8DEF),
  ),
  QuickAction(
    label: 'Housekeeping',
    icon: Icons.cleaning_services_outlined,
    bg: Color(0xFFD9F2F0),
    iconColor: Color(0xFF34B3A6),
  ),
  QuickAction(
    label: 'Restaurant',
    icon: Icons.restaurant_outlined,
    bg: Color(0xFFFDEBD8),
    iconColor: Color(0xFFE8944A),
  ),
  QuickAction(
    label: 'WhatsApp',
    icon: Icons.chat_outlined,
    bg: Color(0xFFDFF5E8),
    iconColor: Color(0xFF2E9E6C),
  ),
  QuickAction(
    label: 'Rooms',
    icon: Icons.meeting_room_outlined,
    bg: Color(0xFFEAE1FB),
    iconColor: Color(0xFF8B6FE0),
  ),
  QuickAction(
    label: 'Staff',
    icon: Icons.groups_outlined,
    bg: Color(0xFFEDEBFC),
    iconColor: Color(0xFF6B6BE0),
    badge: '2 tasks',
  ),
  QuickAction(
    label: 'Floors',
    icon: Icons.layers_outlined,
    bg: Color(0xFFD9F2F0),
    iconColor: Color(0xFF34B3A6),
  ),
  QuickAction(
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    bg: Color(0xFFFCEFC7),
    iconColor: Color(0xFFC99A16),
  ),
  QuickAction(
    label: 'Settings',
    icon: Icons.settings_outlined,
    bg: Color(0xFFECECEE),
    iconColor: Color(0xFF6B7280),
  ),
  QuickAction(
    label: 'New: Group Booking',
    icon: Icons.groups_2_outlined,
    bg: Color(0xFFDCE8FB),
    iconColor: Color(0xFF5B8DEF),
  ),
];

List<VacatingRoom> buildVacatingRooms() => const [
  VacatingRoom(
    roomNumber: '101',
    title: 'Room 101',
    subtitle: 'Departing · Guest Check-Out Scheduled',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFF5B8DEF),
  ),
  VacatingRoom(
    roomNumber: '102',
    title: 'Room 102',
    subtitle: 'Departing · Guest Checkout: 11:00 AM',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFFE8944A),
  ),
  VacatingRoom(
    roomNumber: '101',
    title: 'Room 101',
    subtitle: 'Departing · Guest Check-Out Scheduled',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFF5B8DEF),
  ),
  VacatingRoom(
    roomNumber: '102',
    title: 'Room 102',
    subtitle: 'Departing · Guest Checkout: 11:00 AM',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFFE8944A),
  ),
  VacatingRoom(
    roomNumber: '201',
    title: 'Room 201',
    subtitle: 'Departing · Guest Check-Out Scheduled',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFF5B8DEF),
  ),
  VacatingRoom(
    roomNumber: '202',
    title: 'Room 202',
    subtitle: 'Departing · Guest Checkout: 11:00 AM',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFFE8944A),
  ),
  VacatingRoom(
    roomNumber: '301',
    title: 'Room 301',
    subtitle: 'Departing · Guest Check-Out Scheduled',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFF5B8DEF),
  ),
  VacatingRoom(
    roomNumber: '302',
    title: 'Room 302',
    subtitle: 'Departing · Guest Checkout: 11:00 AM',
    icon: Icons.king_bed_outlined,
    iconColor: Color(0xFFE8944A),
  ),
];
