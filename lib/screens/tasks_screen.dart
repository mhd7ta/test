import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_task_screen.dart';
import 'report_screen.dart';
import 'activity_log_screen.dart';
import '../services/current_user.dart';
import 'edit_task_screen.dart';
class TasksScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const TasksScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<dynamic>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = getProjectTasks();
  }

  Future<List<dynamic>> getProjectTasks() async {
    final allTasks = await ApiService.getTasks();

    return allTasks
        .where((task) => task['project_id'] == widget.projectId)
        .toList();
  }

  void refreshTasks() {
    setState(() {
      tasks = getProjectTasks();
    });
  }

  Future<void> changeStatus(int taskId, String status) async {
    try {
      await ApiService.updateTaskStatus(
        taskId: taskId,
        status: status,
        changedBy: CurrentUser.id!,
      );

      refreshTasks();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
        ),
      );
    }
  }

  List<dynamic> getTasksByStatus(
    List<dynamic> allTasks,
    String status,
  ) {
    return allTasks.where((task) => task['status'] == status).toList();
  }

  Future<void> showDeleteDialog(dynamic task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف المهمة'),
          content: Text(
            'هل أنت متأكد من حذف "${task['title']}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteTask(task['id']);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف المهمة'),
        ),
      );

      refreshTasks();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
        ),
      );
    }
  }

  Widget buildTaskCard(dynamic task) {
    return Draggable<int>(
      data: task['id'],
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 250,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                task['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: buildNormalTaskCard(task),
      ),
      child: buildNormalTaskCard(task),
    );
  }

  Widget buildNormalTaskCard(dynamic task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'تعديل',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(
                            task: task,
                          ),
                        ),
                      );

                      if (result == true) {
                        refreshTasks();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'حذف',
                    onPressed: () {
                      showDeleteDialog(task);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'الأولوية: ${task['priority'] ?? 'medium'}',
              ),
              if (task['parent_task_id'] != null) ...[
                const SizedBox(height: 4),
                const Text(
                  'مهمة فرعية',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ],
          )),
    );
  }

  Widget buildColumn(
    String title,
    String status,
    List<dynamic> taskList,
  ) {
    return Expanded(
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          changeStatus(details.data, status);
        },
        builder: (
          context,
          candidateData,
          rejectedData,
        ) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: taskList.isEmpty
                        ? const Center(
                            child: Text('اسحب المهمة إلى هنا'),
                          )
                        : ListView.builder(
                            itemCount: taskList.length,
                            itemBuilder: (context, index) {
                              return buildTaskCard(
                                taskList[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'التقرير',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportScreen(
                    projectId: widget.projectId,
                    projectName: widget.projectName,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'سجل النشاط',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityLogScreen(
                    projectId: widget.projectId,
                    projectName: widget.projectName,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة مهمة',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(
                    projectId: widget.projectId,
                  ),
                ),
              );

              if (result == true) {
                refreshTasks();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: tasks,
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

          if (!snapshot.hasData) {
            return const Center(
              child: Text('لا توجد بيانات'),
            );
          }

          final allTasks = snapshot.data!;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildColumn(
                'جديدة',
                'new',
                getTasksByStatus(
                  allTasks,
                  'new',
                ),
              ),
              buildColumn(
                'قيد التنفيذ',
                'in_progress',
                getTasksByStatus(
                  allTasks,
                  'in_progress',
                ),
              ),
              buildColumn(
                'مكتملة',
                'done',
                getTasksByStatus(
                  allTasks,
                  'done',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
