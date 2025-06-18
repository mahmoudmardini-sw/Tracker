class Milestone {
  final double value;
  final String description;

  Milestone({required this.value, required this.description});

  Map<String, dynamic> toJson() => {
    'value': value,
    'description': description,
  };

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
    value: json['value'] as double,
    description: json['description'] as String,
  );
}