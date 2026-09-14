# Room Booking — Flutter

A single-page room booking screen: pick check-in/check-out dates, pick a room,
see nights + total price, with validation and booked-room conflict prevention.
No backend, database, auth, or payments — all data is hardcoded per the spec.

Styled to match the reference dashboard screenshots (navy header bars,
card-based sections, numbered "1 / 2 / 3" panels).

## Stack

- **Flutter** (Dart), Material 3, single `StatefulWidget` page.
- No third-party packages — date formatting and currency formatting are done
  by hand to keep the project dependency-free and easy to run anywhere.

## Project structure

```
lib/
  models/room.dart        # Room model + hardcoded sample rooms & bookings
  logic/booking_logic.dart# Pure functions: date validation, nights, total,
                           # overlap/conflict check (no widgets — easy to test)
  main.dart                # The single booking page (UI + state)
test/
  booking_logic_test.dart  # Unit tests for the logic above
```

## How to run

This repo ships only `lib/`, `test/`, and `pubspec.yaml` (the platform
folders — `android/`, `ios/`, `web/`, etc. — aren't included). To run it:

```bash
flutter create . --project-name hotel_booking   # generates platform folders in place
flutter pub get
flutter run -d chrome     # or any connected device/emulator
```

To run the unit tests:

```bash
flutter test
```

## What it does (mapped to the spec)

- **Room list**: left panel, hardcoded from the sample data table, filterable
  by a "min. guests" stepper (Filter room list by max guests).
- **Date pickers**: middle panel, native `showDatePicker` for check-in and
  check-out.
- **Validation**: check-in can't be in the past, check-out must be strictly
  after check-in (same-day is invalid — a stay needs ≥1 night). Errors are
  shown inline, never silently swallowed.
- **Nights / total price**: right panel recalculates `nights = checkOut - checkIn`
  and `total = nights × pricePerNight` live as dates/room change.
- **Booked-room conflict prevention**: two rooms (`R101`, `R201`) come with a
  hardcoded existing booking a few days out from "today". If your selected
  dates overlap an existing booking for a room, that room is shown in red,
  marked "Already booked for selected dates", and can't be selected. Picking
  new dates that clear the conflict re-enables it.
- **Unit tests**: `test/booking_logic_test.dart` covers the night/price math
  (including a time-of-day edge case), date validation edge cases (past
  check-in, same-day, inverted range), and the overlap check (including that
  a same-day checkout→check-in turnover is *not* a conflict).

## Edge cases handled

- Same-day check-in/check-out → rejected (0 nights isn't a valid stay).
- Check-in in the past → rejected.
- Check-out before check-in → rejected.
- Changing check-in to a date that invalidates the current check-out clears
  the check-out field instead of leaving a stale, invalid range on screen.
- Selecting a room, then changing dates so that room becomes booked, clears
  the selection rather than leaving a now-invalid room "selected".
- Empty filtered room list (guest count too high for any room) shows a
  friendly message instead of an empty blank panel.

## What I'd improve with more time

- Swap the hand-rolled currency/date formatting for `intl` once network
  access allows `flutter pub get` against pub.dev.
- Add widget tests (`flutter_test` + `WidgetTester`) for the interactive
  flows, on top of the current pure-logic unit tests.
- Persist the "existing bookings" list as actual mock JSON fixtures rather
  than generating them relative to `DateTime.now()`, so tests and the demo
  are fully deterministic regardless of the day it's run.
- Add keyboard/focus handling and semantics labels for accessibility.
