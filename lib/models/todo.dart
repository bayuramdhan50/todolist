class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final String subject; // Matakuliah
  final String difficulty; // Tingkat kesulitan
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.subject,
    required this.difficulty,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.millisecondsSinceEpoch,
      'subject': subject,
      'difficulty': difficulty,
      'isCompleted': isCompleted ? 1 : 0, // Store as integer for SQLite
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline']),
      subject: map['subject'] ?? 'Semua Matakuliah',
      difficulty: map['difficulty'] ?? 'Sedang',
      isCompleted: map['isCompleted'] == 1, // Convert integer to boolean
    );
  }
}
