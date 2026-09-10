import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // ==================== PROJECTS ====================

  // جلب جميع المشاريع
  static Future<List<dynamic>> getProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل جلب المشاريع');
    }
  }

  // إضافة مشروع جديد
  static Future<bool> addProject({
    required String name,
    String? description,
    String? startDate,
    String? endDate,
    required int createdBy,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        'created_by': createdBy,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    }

    final data = jsonDecode(response.body);
    throw Exception(data['error'] ?? 'فشل إضافة المشروع');
  }

  // ==================== TASKS ====================

  // إضافة مهمة جديدة
  static Future<bool> addTask({
    required int projectId,
    int? parentTaskId,
    required String title,
    String? description,
    String priority = 'medium',
    String status = 'new',
    int? assignedTo,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'project_id': projectId,
        'parent_task_id': parentTaskId,
        'title': title,
        'description': description,
        'priority': priority,
        'status': status,
        'assigned_to': assignedTo,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    }

    final data = jsonDecode(response.body);
    throw Exception(data['error'] ?? 'فشل إضافة المهمة');
  }

  // جلب جميع المهام
  static Future<List<dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    final data = jsonDecode(response.body);
    throw Exception(data['error'] ?? 'فشل جلب المهام');
  }

// جلب جميع المستخدمين
  static Future<List<AppUser>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => AppUser.fromJson(json)).toList();
    }

    final data = jsonDecode(response.body);
    throw Exception(data['error'] ?? 'فشل جلب المستخدمين');
  }

  static Future<bool> updateTaskStatus({
    required int taskId,
    required String status,
    required int changedBy,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status,
        'changed_by': changedBy,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    }

    final data = jsonDecode(response.body);
    throw Exception(
      data['error'] ?? 'فشل تغيير حالة المهمة',
    );
  }

  static Future<Map<String, dynamic>> getProjectReport(
    int projectId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId/report'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    final data = jsonDecode(response.body);

    throw Exception(
      data['error'] ?? 'فشل جلب التقرير',
    );
  }

  static Future<List<dynamic>> getActivityLog(
    int projectId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId/activity-log'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    final data = jsonDecode(response.body);

    throw Exception(
      data['error'] ?? 'فشل جلب سجل النشاط',
    );
  }

  static Future<bool> deleteTask(int taskId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId'),
    );

    if (response.statusCode == 200) {
      return true;
    }

    final data = jsonDecode(response.body);

    throw Exception(
      data['error'] ?? 'فشل حذف المهمة',
    );
  }

  static Future<void> deleteProject(int projectId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$projectId'),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'فشل حذف المشروع');
    }
  }
}
