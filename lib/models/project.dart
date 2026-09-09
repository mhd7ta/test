class Project {
  final int id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final int createdBy;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'created_by': createdBy,
      };
}