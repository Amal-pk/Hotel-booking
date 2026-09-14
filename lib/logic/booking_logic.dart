import '../models/room.dart';

/// Result of validating a check-in/check-out date pair.
class DateValidationResult {
  final bool isValid;
  final String? errorMessage;

  const DateValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const DateValidationResult.invalid(String message)
      : isValid = false,
        errorMessage = message;
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);


DateValidationResult validateDates({
  required DateTime? checkIn,
  required DateTime? checkOut,
  required DateTime today,
}) {
  if (checkIn == null || checkOut == null) {
    return const DateValidationResult.invalid(
      'Please select both a check-in and a check-out date.',
    );
  }

  final ci = dateOnly(checkIn);
  final co = dateOnly(checkOut);
  final t = dateOnly(today);

  if (ci.isBefore(t)) {
    return const DateValidationResult.invalid(
      'Check-in date cannot be in the past.',
    );
  }

  if (!co.isAfter(ci)) {
    return const DateValidationResult.invalid(
      'Check-out date must be after check-in date.',
    );
  }

  return const DateValidationResult.valid();
}


int calculateNights(DateTime checkIn, DateTime checkOut) {
  final ci = dateOnly(checkIn);
  final co = dateOnly(checkOut);
  return co.difference(ci).inDays;
}

double calculateTotal(int nights, double pricePerNight) {
  if (nights <= 0) return 0;
  return nights * pricePerNight;
}


bool rangesOverlap(
  DateTime aStart,
  DateTime aEnd,
  DateTime bStart,
  DateTime bEnd,
) {
  final as_ = dateOnly(aStart);
  final ae = dateOnly(aEnd);
  final bs = dateOnly(bStart);
  final be = dateOnly(bEnd);
  return as_.isBefore(be) && bs.isBefore(ae);
}


bool isRoomBookedForDates({
  required String roomCode,
  required DateTime checkIn,
  required DateTime checkOut,
  required List<BookedRange> bookings,
}) {
  for (final b in bookings) {
    if (b.roomCode != roomCode) continue;
    if (rangesOverlap(checkIn, checkOut, b.checkIn, b.checkOut)) {
      return true;
    }
  }
  return false;
}
