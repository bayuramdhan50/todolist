import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';
import '../helpers/database_helper.dart';

class TodoProvider with ChangeNotifier {
  final List<Todo> _todos = [];
  final NotificationService _notificationService = NotificationService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  TodoProvider() {
    _loadTodos();
    scheduleDailyReminder();
  }

  List<Todo> get todos => [..._todos];

  List<Todo> get pendingTodos =>
      _todos.where((todo) => !todo.isCompleted).toList();

  List<Todo> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  void scheduleDailyReminder() {
    _notificationService.scheduleDailyReminderAt00();
  }

  Future<void> addTodo(String title, String description, DateTime deadline,
      {String subject = 'Umum', String difficulty = 'Sedang'}) async {
    final newTodo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      deadline: deadline,
      subject: subject,
      difficulty: difficulty,
    );

    await _dbHelper.insertTodo(newTodo);
    await _loadTodos();
    _scheduleNotification(newTodo);
  }

  Future<void> toggleTodoStatus(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex >= 0) {
      final todo = _todos[todoIndex];
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        deadline: todo.deadline,
        subject: todo.subject,
        difficulty: todo.difficulty,
        isCompleted: !todo.isCompleted,
      );
      await _dbHelper.updateTodo(updatedTodo);
      await _loadTodos();

      if (updatedTodo.isCompleted) {
        _notificationService.cancelNotification(id);
      } else {
        _scheduleNotification(updatedTodo);
      }
    }
  }

  Future<void> deleteTodoById(String id) async {
    await _dbHelper.deleteTodo(id);
    await _loadTodos();
    _notificationService.cancelNotification(id);
  }

  void _scheduleNotification(Todo todo) {
    _notificationService.scheduleDeadlineNotifications(
      todo.id,
      todo.title,
      todo.deadline,
    );
  }

  Future<void> _loadTodos() async {
    _todos.clear();
    _todos.addAll(await _dbHelper.getTodos());
    notifyListeners();
  }
}
