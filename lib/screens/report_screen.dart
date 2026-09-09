import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ReportScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<Map<String, dynamic>> report;

  @override
  void initState() {
    super.initState();
    report = ApiService.getProjectReport(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقرير ${widget.projectName}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: report,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          final data = snapshot.data!;

          final totalTasks = data['total_tasks'] ?? 0;
          final completedTasks = data['completed_tasks'] ?? 0;
          final percentage = data['completion_percentage'] ?? 0;

          final members = data['completed_per_member'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تقرير المشروع',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'إجمالي المهام: $totalTasks',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'المهام المكتملة: $completedTasks',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'نسبة إنجاز المشروع: $percentage%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'المهام المكتملة لكل عضو:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(
                            member['member_name'] ?? '',
                          ),
                          trailing: Text(
                            '${member['completed_tasks']} مهام مكتملة',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
