import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_project_screen.dart';
import 'tasks_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late Future<List<dynamic>> projects;

  @override
  void initState() {
    super.initState();
    projects = ApiService.getProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('المشاريع'),
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddProjectScreen(),
          ),
        );

        if (result == true) {
          setState(() {
            projects = ApiService.getProjects();
          });
        }
      },
    ),
  ],
),
      body: FutureBuilder<List<dynamic>>(
        future: projects,
        builder: (context, snapshot) {
          // أثناء تحميل البيانات
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // في حال حدوث خطأ
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // لا توجد مشاريع
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('لا توجد مشاريع حاليًا'),
            );
          }

          final projects = snapshot.data!;

          // عرض المشاريع
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];

            return Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
    leading: const Icon(Icons.folder),
    title: Text(
      project['name'] ?? '',
    ),
    subtitle: Text(
      project['description'] ?? 'بدون وصف',
    ),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TasksScreen(
            projectId: project['id'],
            projectName: project['name'],
          ),
        ),
      );
    },
  ),
);
            },
          );
        },
      ),
    );
  }
}