import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List with SharedPreferences',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ToDoListPage(),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksData = prefs.getString('tasks');
    if (tasksData != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksData));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  void _addTask(String title) {
    setState(() {
      tasks.add({'title': title, 'isComplete': false});
    });
    _saveTasks();
    taskController.clear();
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index]['isComplete'] = !tasks[index]['isComplete'];
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _updateTask(int index, String newTitle) {
    setState(() {
      tasks[index]['title'] = newTitle;
    });
    _saveTasks();
  }

  void _editTask(int index) {
    taskController.text = tasks[index]['title'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateTask(index, taskController.text);
                taskController.clear();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                taskController.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'New Task',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      _addTask(taskController.text);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    tasks[index]['title'],
                    style: TextStyle(
                      decoration: tasks[index]['isComplete']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: tasks[index]['isComplete'],
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(index);
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTask(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
