import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditTaskScreen extends StatefulWidget {
  final dynamic task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late String priority;
  int? assignedTo;
  int? parentTaskId;

  List<dynamic> users = [];
  List<dynamic> allTasks = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.task['title'] ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.task['description'] ?? '',
    );

    priority = widget.task['priority'] ?? 'medium';
    assignedTo = widget.task['assigned_to'];
    parentTaskId = widget.task['parent_task_id'];

    loadData();
  }

  Future<void> loadData() async {
    try {
      final usersResult = await ApiService.getUsers();
      final tasksResult = await ApiService.getTasks();

      if (!mounted) return;

      setState(() {
        users = usersResult;

        allTasks = tasksResult.where((task) {
          return task['project_id'] == widget.task['project_id'] &&
              task['id'] != widget.task['id'];
        }).toList();
      });
    } catch (e) {
      debugPrint('خطأ في جلب البيانات: $e');
    }
  }

  Future<void> saveChanges() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل عنوان المهمة'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.updateTask(
        taskId: widget.task['id'],
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: priority,
        assignedTo: assignedTo,
        parentTaskId: parentTaskId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعديل المهمة بنجاح'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المهمة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان المهمة',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف المهمة',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(
                labelText: 'الأولوية',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text('منخفضة'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('متوسطة'),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text('عالية'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    priority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: assignedTo,
              decoration: const InputDecoration(
                labelText: 'تعيين المهمة لعضو',
                border: OutlineInputBorder(),
              ),
              items: users.map((user) {
                return DropdownMenuItem<int>(
                  value: user.id,
                  child: Text(user.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  assignedTo = value;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: parentTaskId,
              decoration: const InputDecoration(
                labelText: 'المهمة الرئيسية',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('مهمة رئيسية'),
                ),
                ...allTasks.map((task) {
                  return DropdownMenuItem<int>(
                    value: task['id'],
                    child: Text(task['title']),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  parentTaskId = value;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveChanges,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('حفظ التعديلات'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}