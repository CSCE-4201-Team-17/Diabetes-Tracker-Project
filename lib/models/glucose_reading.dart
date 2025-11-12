class BloodSugarReading {
  final double value;
  final DateTime timestamp;
  final String type; //fasting, after meal, before meal, etc.
  final String? notes;

  BloodSugarReading({
    required this.value,
    required this.timestamp,
    required this.type,
    this.notes,
  });

  //Used for API integration
  factory BloodSugarReading.fromJson(Map<String, dynamic> json) {
    return BloodSugarReading(
      value: (json['value'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'notes': notes,
  };
}