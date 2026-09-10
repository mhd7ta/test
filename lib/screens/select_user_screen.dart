import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/current_user.dart';
import 'projects_screen.dart';

class SelectUserScreen extends StatefulWidget {
  const SelectUserScreen({super.key});

  @override
  State<SelectUserScreen> createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  late Future<List<AppUser>> _usersFuture;
  AppUser? _selected;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مين أنت؟')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<List<AppUser>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Text(
                  'ما في مستخدمين مسجّلين بعد. أضف مستخدم أول من الـ backend.');
            }
            final users = snapshot.data!;
            return Column(
              children: [
                const Text('اختر اسمك من القائمة عشان يتسجل كل تعديل باسمك:'),
                const SizedBox(height: 20),
                DropdownButtonFormField<AppUser>(
                  value: _selected,
                  items: users
                      .map((u) =>
                          DropdownMenuItem(value: u, child: Text(u.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _selected = value),
                  decoration: const InputDecoration(
                      labelText: 'المستخدم', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          CurrentUser.id = _selected!.id;
                          CurrentUser.name = _selected!.name;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProjectsScreen()),
                          );
                        },
                  child: const Text('دخول'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
