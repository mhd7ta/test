enum TaskPriority { high, medium, low }
enum TaskStatus { newTask, inProgress, done }

TaskPriority priorityFromString(String value) {
  return TaskPriority.values.firstWhere((e) => e.name == value);
}

TaskStatus statusFromString(String value) {
  switch (value) {
    case 'new':
      return TaskStatus.newTask;
    case 'in_progress':
      return TaskStatus.inProgress;
    case 'done':
      return TaskStatus.done;
    default:
      return TaskStatus.newTask;
  }
}

String statusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.newTask:
      return 'new';
    case TaskStatus.inProgress:
      return 'in_progress';
    case TaskStatus.done:
      return 'done';
  }
}

class Task {
  final int id;
  final int projectId;
  final int? parentTaskId; // null = مهمة رئيسية، غير null = مهمة فرعية تحت parentTaskId
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final int? assignedTo;

  Task({
    required this.id,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.assignedTo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      projectId: json['project_id'],
      parentTaskId: json['parent_task_id'],
      title: json['title'],
      description: json['description'],
      priority: priorityFromString(json['priority']),
      status: statusFromString(json['status']),
      assignedTo: json['assigned_to'],
    );
  }

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'parent_task_id': parentTaskId,
        'title': title,
        'description': description,
        'priority': priority.name,
        'status': statusToString(status),
        'assigned_to': assignedTo,
      };

  bool get isSubtask => parentTaskId != null;
}