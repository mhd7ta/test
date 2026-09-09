import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ActivityLogScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ActivityLogScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ActivityLogScreen> createState() =>
      _ActivityLogScreenState();
}

class _ActivityLogScreenState
    extends State<ActivityLogScreen> {
  late Future<List<dynamic>> logs;

  @override
  void initState() {
    super.initState();
    logs = ApiService.getActivityLog(widget.projectId);
  }

  String statusName(String status) {
    switch (status) {
      case 'new':
        return 'جديدة';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'done':
        return 'مكتملة';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل النشاط'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: logs,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final activityLogs = snapshot.data ?? [];

          if (activityLogs.isEmpty) {
            return const Center(
              child: Text('لا يوجد نشاط حتى الآن'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activityLogs.length,
            itemBuilder: (context, index) {
              final log = activityLogs[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(
                    log['task_title'] ?? 'مهمة',
                  ),
                  subtitle: Text(
                    '${statusName(log['old_status'])} '
                    '→ ${statusName(log['new_status'])}\n'
                    'بواسطة: ${log['changed_by_name'] ?? 'غير معروف'}\n'
                    'التاريخ: ${log['changed_at']}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}