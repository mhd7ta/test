class ActivityLog {
  final int id;
  final int taskId;
  final int changedBy;
  final String oldStatus;
  final String newStatus;
  final DateTime changedAt;

  ActivityLog({
    required this.id,
    required this.taskId,
    required this.changedBy,
    required this.oldStatus,
    required this.newStatus,
    required this.changedAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      taskId: json['task_id'],
      changedBy: json['changed_by'],
      oldStatus: json['old_status'],
      newStatus: json['new_status'],
      changedAt: DateTime.parse(json['changed_at']),
    );
  }
}