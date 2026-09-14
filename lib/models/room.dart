/// A single hotel room, from the hardcoded sample data set.
class Room {
  final String code;
  final String type;
  final double pricePerNight;
  final int maxGuests;

  const Room({
    required this.code,
    required this.type,
    required this.pricePerNight,
    required this.maxGuests,
  });
}

/// Sample room inventory (from spec doc). No backend/API — hardcoded.
const List<Room> sampleRooms = [
  Room(code: 'R101', type: 'Deluxe Room', pricePerNight: 3500, maxGuests: 2),
  Room(code: 'R102', type: 'Deluxe Room', pricePerNight: 3500, maxGuests: 2),
  Room(code: 'R201', type: 'Executive Suite', pricePerNight: 5800, maxGuests: 3),
  Room(code: 'R202', type: 'Executive Suite', pricePerNight: 5800, maxGuests: 3),
  Room(code: 'R301', type: 'Family Room', pricePerNight: 4200, maxGuests: 4),
];

/// A hardcoded existing booking, used to test the "already booked" guard.
class BookedRange {
  final String roomCode;
  final DateTime checkIn;
  final DateTime checkOut;

  const BookedRange({
    required this.roomCode,
    required this.checkIn,
    required this.checkOut,
  });
}

/// A couple of existing bookings to test conflict-prevention against.
/// Dates are set relative to "today" at app start so the demo always has
/// a realistic, currently-relevant conflict to try out.
List<BookedRange> buildSampleBookings(DateTime today) {
  final base = DateTime(today.year, today.month, today.day);
  return [
    // R101 is booked 3-6 days from now.
    BookedRange(
      roomCode: 'R101',
      checkIn: base.add(const Duration(days: 3)),
      checkOut: base.add(const Duration(days: 6)),
    ),
    // R201 is booked 1-2 days from now.
    BookedRange(
      roomCode: 'R201',
      checkIn: base.add(const Duration(days: 1)),
      checkOut: base.add(const Duration(days: 2)),
    ),
  ];
}
