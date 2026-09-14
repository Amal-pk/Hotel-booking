import 'package:flutter/material.dart';
import 'package:hotel_booking_app/logic/booking_logic.dart';
import 'package:hotel_booking_app/models/room.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late final DateTime _today;
  late final List<BookedRange> _existingBookings;

  DateTime? _checkIn;
  DateTime? _checkOut;
  Room? _selectedRoom;
  int _minGuests = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _existingBookings = buildSampleBookings(_today);
  }

  DateValidationResult get _dateValidation =>
      validateDates(checkIn: _checkIn, checkOut: _checkOut, today: _today);

  bool get _datesValid =>
      _checkIn != null && _checkOut != null && _dateValidation.isValid;

  int get _nights => _datesValid ? calculateNights(_checkIn!, _checkOut!) : 0;

  double get _total => _selectedRoom != null
      ? calculateTotal(_nights, _selectedRoom!.pricePerNight)
      : 0;

  bool _isRoomBooked(Room room) {
    if (!_datesValid) return false;
    return isRoomBookedForDates(
      roomCode: room.code,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      bookings: _existingBookings,
    );
  }

  List<Room> get _visibleRooms =>
      sampleRooms.where((r) => r.maxGuests >= _minGuests).toList();

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn
        ? (_checkIn ?? _today)
        : (_checkOut ?? (_checkIn ?? _today).add(const Duration(days: 1)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(_today) ? _today : initial,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: _navy),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        // If checkout is now invalid relative to the new check-in, clear it.
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = null;
        }
      } else {
        _checkOut = picked;
      }
      // Re-validate current room selection against the (possibly) new dates.
      if (_selectedRoom != null && _isRoomBooked(_selectedRoom!)) {
        _selectedRoom = null;
      }
    });
  }

  void _selectRoom(Room room) {
    if (_isRoomBooked(room)) return;
    setState(() {
      _selectedRoom = _selectedRoom?.code == room.code ? null : room;
    });
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Select date';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  String _fmtMoney(double v) {
    // Simple 3-digit thousands-separated formatting, no extra packages.
    final whole = v.round().toString();
    final out = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      out.write(whole[i]);
      final remaining = whole.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) out.write(',');
    }
    return '₹$out.00';
  }

  @override
  Widget build(BuildContext context) {
    final validation = _dateValidation;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 980;

    final columns = [
      _panel(title: '1. Select Room', child: _roomSelectionColumn()),
      _panel(
        title: '2. Choose Dates & Guests',
        child: _datesColumn(validation),
      ),
      _panel(title: '3. Booking Summary', child: _summaryColumn(validation)),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isWide
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: columns[0]),
                            const SizedBox(width: 20),
                            Expanded(flex: 3, child: columns[1]),
                            const SizedBox(width: 20),
                            Expanded(flex: 3, child: columns[2]),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          columns[0],
                          const SizedBox(height: 20),
                          columns[1],
                          const SizedBox(height: 20),
                          columns[2],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.hotel, color: _navy, size: 26),
          const SizedBox(width: 10),
          const Text(
            'Room Booking',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _pageBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: _muted),
                const SizedBox(width: 6),
                Text(
                  _fmtDate(_today),
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Panel shell (matches the navy header-bar cards in the ref UI) ----------

  Widget _panel({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_navy, _navyDark]),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  // ---------- Column 1: room list + max-guests filter ----------

  Widget _roomSelectionColumn() {
    final rooms = _visibleRooms;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Min. guests',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _stepper(
              value: _minGuests,
              onChanged: (v) => setState(() => _minGuests = v),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Showing rooms that fit at least $_minGuests guest${_minGuests > 1 ? 's' : ''}.',
          style: const TextStyle(fontSize: 12, color: _muted),
        ),
        const SizedBox(height: 12),
        if (rooms.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No rooms match that guest count.',
                style: TextStyle(color: _muted),
              ),
            ),
          )
        else
          ...rooms.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _roomCard(r),
            ),
          ),
      ],
    );
  }

  Widget _stepper({required int value, required ValueChanged<int> onChanged}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove, size: 16),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add, size: 16),
            onPressed: value < 8 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _roomCard(Room room) {
    final booked = _isRoomBooked(room);
    final selected = _selectedRoom?.code == room.code;

    Color borderColor = _cardBorder;
    Color bg = Colors.white;
    if (booked) {
      borderColor = _occupiedRed.withValues(alpha: 0.4);
      bg = _occupiedRed.withValues(alpha: 0.06);
    } else if (selected) {
      borderColor = _navy;
      bg = _navy.withValues(alpha: 0.06);
    }

    return InkWell(
      onTap: booked ? null : () => _selectRoom(room),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor, width: selected ? 1.6 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: booked
                    ? _occupiedRed.withValues(alpha: 0.12)
                    : _available.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.king_bed_outlined,
                size: 20,
                color: booked ? _occupiedRed : _available,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        room.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        room.type,
                        style: const TextStyle(fontSize: 13, color: _muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtMoney(room.pricePerNight)} / night · up to ${room.maxGuests} guests',
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                  if (booked) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Already booked for selected dates',
                      style: TextStyle(
                        fontSize: 11,
                        color: _occupiedRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!booked)
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? _navy : _cardBorder,
              ),
          ],
        ),
      ),
    );
  }

  // ---------- Column 2: date pickers + validation ----------

  Widget _datesColumn(DateValidationResult validation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Check-in date',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        _dateField(
          label: _fmtDate(_checkIn),
          onTap: () => _pickDate(isCheckIn: true),
        ),
        const SizedBox(height: 16),
        const Text(
          'Check-out date',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        _dateField(
          label: _fmtDate(_checkOut),
          onTap: () => _pickDate(isCheckIn: false),
        ),
        const SizedBox(height: 16),
        if (!validation.isValid)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _occupiedRed.withValues(alpha: 0.08),
              border: Border.all(color: _occupiedRed.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: _occupiedRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validation.errorMessage ?? '',
                    style: const TextStyle(fontSize: 12, color: _occupiedRed),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _available.withValues(alpha: 0.08),
              border: Border.all(color: _available.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: _available,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_nights night${_nights == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _available,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dateField({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: _muted),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ---------- Column 3: summary + total ----------

  Widget _summaryColumn(DateValidationResult validation) {
    final hasRoom = _selectedRoom != null;
    final canBook = validation.isValid && hasRoom;

    String? blockingMessage;
    if (!validation.isValid) {
      blockingMessage = validation.errorMessage;
    } else if (!hasRoom) {
      blockingMessage = 'Select a room from the list to see pricing.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (blockingMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _pageBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              blockingMessage,
              style: const TextStyle(fontSize: 13, color: _muted),
            ),
          )
        else ...[
          _summaryRow(
            'Room',
            '${_selectedRoom!.code} · ${_selectedRoom!.type}',
          ),
          _summaryRow('Check-in', _fmtDate(_checkIn)),
          _summaryRow('Check-out', _fmtDate(_checkOut)),
          _summaryRow('Nights', '$_nights'),
          _summaryRow('Rate / night', _fmtMoney(_selectedRoom!.pricePerNight)),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                _fmtMoney(_total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canBook ? () => _showConfirmation(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _cardBorder,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm Booking',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _muted)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Booking summary'),
        content: Text(
          'Room ${_selectedRoom!.code} (${_selectedRoom!.type})\n'
          '${_fmtDate(_checkIn)} → ${_fmtDate(_checkOut)}\n'
          '$_nights night${_nights == 1 ? '' : 's'} · Total ${_fmtMoney(_total)}\n\n',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

const _navy = Color(0xFF1E3A5F);
const _navyDark = Color(0xFF16283F);
const _pageBg = Color(0xFFF4F5F7);
const _cardBorder = Color(0xFFE2E5EA);
const _available = Color(0xFF2E9E6C);
const _occupiedRed = Color(0xFFD65B5B);
const _muted = Color(0xFF6B7280);
