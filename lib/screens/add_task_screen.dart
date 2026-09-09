import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddTaskScreen extends StatefulWidget {
  final int projectId;

  const AddTaskScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String priority = 'medium';
  bool isLoading = false;

  List<dynamic> users = [];
  int? assignedTo;
  
  List<dynamic> allTasks = [];
  int? parentTaskId;

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final result = await ApiService.getTasks();

      if (mounted) {
        setState(() {
          allTasks = result
              .where((task) => task['project_id'] == widget.projectId)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('خطأ في جلب المهام: $e');
    }
  }

  // جلب المستخدمين
  Future<void> loadUsers() async {
    try {
      final result = await ApiService.getUsers();

      if (mounted) {
        setState(() {
          users = result;
        });
      }
    } catch (e) {
      debugPrint('خطأ في جلب المستخدمين: $e');
    }
  }

  // حفظ المهمة
  Future<void> saveTask() async {
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
      final success = await ApiService.addTask(
        projectId: widget.projectId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        priority: priority,
        assignedTo: assignedTo,
        parentTaskId: parentTaskId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة المهمة بنجاح'),
          ),
        );

        Navigator.pop(context, true);
      }
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
        title: const Text('إضافة مهمة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // عنوان المهمة
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان المهمة',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // وصف المهمة
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'وصف المهمة',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // الأولوية
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

            const SizedBox(height: 16),
            // تعيين المهمة لعضو
            DropdownButtonFormField<int>(
              value: assignedTo,
              decoration: const InputDecoration(
                labelText: 'تعيين المهمة لعضو',
                border: OutlineInputBorder(),
              ),
              items: users.map((user) {
                return DropdownMenuItem<int>(
                  value: user['id'],
                  child: Text(user['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  assignedTo = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveTask,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('حفظ المهمة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
