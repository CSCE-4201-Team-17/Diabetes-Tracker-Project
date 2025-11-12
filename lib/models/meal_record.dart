class MealRecord {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String? imageUrl;
  final String description;
  final double? carbsEstimate;
  final String? mealClassification;
  final double? predictedGlucose;
  final String? coachingMessage;

  MealRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
    this.imageUrl,
    required this.description,
    this.carbsEstimate,
    this.mealClassification,
    this.predictedGlucose,
    this.coachingMessage,
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      carbsEstimate: json['carbsEstimate']?.toDouble(),
      mealClassification: json['mealClassification'],
      predictedGlucose: json['predictedGlucose']?.toDouble(),
      coachingMessage: json['coachingMessage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'timestamp': timestamp.toIso8601String(),
    'imageUrl': imageUrl,
    'description': description,
    'carbsEstimate': carbsEstimate,
    'mealClassification': mealClassification,
    'predictedGlucose': predictedGlucose,
    'coachingMessage': coachingMessage,
  };
}