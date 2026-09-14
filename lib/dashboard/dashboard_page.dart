import 'package:flutter/material.dart';
import 'package:hotel_booking_app/booking/booking_screen.dart';

import '../models/dashboard_data.dart';

const _navy = Color(0xFF1E3A5F);
const _pageBg = Color(0xFFF4F4F1);
const _cardBorder = Color(0xFFE7E7E2);
const _muted = Color(0xFF6B7280);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final List<FloorData> _floors;
  late final List<QuickAction> _quickActions;
  late final List<VacatingRoom> _vacatingRooms;
  final TextEditingController _roomFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _floors = buildSampleFloors();
    _quickActions = buildQuickActions();
    _vacatingRooms = buildVacatingRooms();
  }

  @override
  void dispose() {
    _roomFieldController.dispose();
    super.dispose();
  }

  int get _totalRooms => _floors.fold(0, (sum, f) => sum + f.rooms.length);

  int get _occupiedRooms => _floors
      .expand((f) => f.rooms)
      .where((r) => r.status == RoomStatus.occupied)
      .length;

  double get _occupancyFraction =>
      _totalRooms == 0 ? 0 : _occupiedRooms / _totalRooms;

  String get _occupancyLabel => '${(_occupancyFraction * 100).round()}%';

  bool get _hasOverdueDirtyRoom =>
      _floors.expand((f) => f.rooms).any((r) => r.status == RoomStatus.dirty);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1000;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Main Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    isWide
                        ? Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _quickActionsGrid(crossAxisCount: 8),
                              ),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: _operationalOverview()),
                            ],
                          )
                        : Column(
                            children: [
                              _quickActionsGrid(crossAxisCount: 3),
                              const SizedBox(height: 16),
                              _operationalOverview(),
                            ],
                          ),
                    const SizedBox(height: 16),
                    _floorViewPanel(isWide: isWide),
                    const SizedBox(height: 16),
                    isWide
                        ? Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 5, child: _vacatingRoomsPanel()),
                              const SizedBox(width: 16),
                              Expanded(flex: 3, child: _quickChangerPanel()),
                            ],
                          )
                        : Column(
                            children: [
                              _vacatingRoomsPanel(),
                              const SizedBox(height: 16),
                              _quickChangerPanel(),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Top bar ----------------

  Widget _topBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _navy,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Raintech',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  height: 1.1,
                ),
              ),
              Text(
                'HOTEL',
                style: TextStyle(fontSize: 10, letterSpacing: 1, color: _muted),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _pageBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cardBorder),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, size: 18, color: _muted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search guests, rooms, reservations, staff...',
                      style: TextStyle(fontSize: 13, color: _muted),
                    ),
                  ),
                  Text('Ctrl K', style: TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _pageBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _cardBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, size: 13, color: _muted),
                SizedBox(width: 6),
                Text(
                  'Thu, Jul 23, 2026 | 9:30 AM',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.bolt, size: 16),
            label: const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _pageBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardBorder),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  size: 18,
                  color: _muted,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD65B5B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 18,
            backgroundColor: _navy,
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  // ---------------- Quick actions ----------------

  Widget _quickActionsGrid({required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _quickActions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, i) => _quickActionTile(_quickActions[i]),
    );
  }

  Widget _quickActionTile(QuickAction action) {
    final highlighted = action.badge != null;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _handleQuickAction(action),
      child: Container(
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFFEDEBFC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted ? const Color(0xFFC9C2F5) : _cardBorder,
          ),
        ),
        child: Stack(
          children: [
            if (action.badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _navy,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    action.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: action.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action.icon, size: 17, color: action.iconColor),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      action.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(QuickAction action) {
    if (action.label == 'Reservations' ||
        action.label == 'New: Group Booking') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const BookingPage()));
    }
  }

  // ---------------- Operational overview ----------------

  Widget _operationalOverview() {
    final stats = [
      OverviewStat(
        label: 'Occupancy',
        value: _occupancyLabel,
        highlighted: true,
      ),
      const OverviewStat(label: 'Pending Check-ins', value: '0'),
      const OverviewStat(label: 'Pending Departures', value: '0'),
      const OverviewStat(label: 'Revenue Today', value: '₹0'),
    ];

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational Overview',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: stats.map(_statCard).toList(),
          ),
        ],
      ),
    );
  }

  Widget _statCard(OverviewStat stat) {
    final highlightColors = stat.highlighted
        ? const [Color(0xFFDCE8FB), Color(0xFF1E3A5F)]
        : const [_pageBg, Colors.black87];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlightColors[0],
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.label,
            style: const TextStyle(fontSize: 11, color: _muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: stat.value.length > 3 ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: stat.label == 'Revenue Today'
                  ? const Color(0xFF2E9E6C)
                  : highlightColors[1],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Floor view ----------------

  Widget _floorViewPanel({required bool isWide}) {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Room Status - Interactive Floor View',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '$_totalRooms rooms across your property',
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 16),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expanded(flex: 3, child: _floorsColumn()),
                    const SizedBox(width: 24),
                    SizedBox(width: 170, child: _occupancyDonut()),
                  ],
                )
              : Column(
                  children: [
                    _floorsColumn(),
                    const SizedBox(height: 16),
                    _occupancyDonut(),
                  ],
                ),
          const SizedBox(height: 12),
          _legend(),
          const SizedBox(height: 6),
          const Text(
            'Tap a room tile to open its quick-edit menu.',
            style: TextStyle(
              fontSize: 11,
              color: _muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _floorsColumn() {
    return Column(
      children: _floors
          .map(
            (floor) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _floorRow(floor),
            ),
          )
          .toList(),
    );
  }

  Widget _floorRow(FloorData floor) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                floor.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: floor.rooms.map(_roomTile).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomTile(RoomTile room) {
    return Tooltip(
      message: '${room.number} · ${room.status.label}',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _showRoomQuickEdit(room),
        child: Container(
          width: 40,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: room.status.color.withValues(alpha: 0.16),
            border: Border.all(color: room.status.color.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${room.number}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: room.status.color,
            ),
          ),
        ),
      ),
    );
  }

  void _showRoomQuickEdit(RoomTile room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room ${room.number}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: room.status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  room.status.label,
                  style: TextStyle(
                    color: room.status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _occupancyDonut() {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _occupancyFraction.clamp(0.02, 1.0),
                  strokeWidth: 10,
                  backgroundColor: _cardBorder,
                  valueColor: const AlwaysStoppedAnimation(_navy),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_totalRooms',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Rooms\nTotal',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: _muted, height: 1.1),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$_occupancyLabel Occupied',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
      ],
    );
  }

  Widget _legend() {
    final items = RoomStatus.values;
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: items
          .map(
            (s) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  s.label,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  // ---------------- Going to vacate ----------------

  Widget _vacatingRoomsPanel() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.meeting_room_outlined, size: 18, color: _navy),
              SizedBox(width: 8),
              Text(
                'Going to Vacate Rooms',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._vacatingRooms
                  .map((r) => Expanded(child: _vacatingRoomCard(r)))
                  .expand((w) => [w, const SizedBox(width: 12)]),
              Expanded(child: _departingSummary()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vacatingRoomCard(VacatingRoom room) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: room.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(room.icon, color: room.iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            room.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            room.subtitle,
            style: const TextStyle(fontSize: 10.5, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _departingSummary() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Departing',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                '0',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 5,
              backgroundColor: _cardBorder,
            ),
          ),
          // const Spacer(),
          if (_hasOverdueDirtyRoom)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Color(0xFFE8944A),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Room 101 cleaning overdue',
                    style: TextStyle(fontSize: 10.5, color: _muted),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ---------------- Quick room status changer ----------------

  Widget _quickChangerPanel() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Room Status Changer & Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          const Text('Room #', style: TextStyle(fontSize: 12, color: _muted)),
          const SizedBox(height: 6),
          TextField(
            controller: _roomFieldController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter number',
              hintStyle: const TextStyle(fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showActionSnack('Marked ready to serve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9E6C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.check, size: 16),
              label: const Text(
                'Cleaning done, ready to serve',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  _showActionSnack('All dirty rooms set to cleaning'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD65B5B),
                side: const BorderSide(color: _cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Set all Dirty to Cleaning',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  _showActionSnack('Opening all maintenance rooms'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: _cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View All Maintenance',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // ---------------- Shared card shell ----------------

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: child,
    );
  }
}
