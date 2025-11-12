class Medication {
  final String name;
  final String dosage;
  final int hour;
  final int minute;
  final bool taken;

  Medication({
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    this.taken = false,
  });

  //Helper method to format time as string
  String get timeString {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}