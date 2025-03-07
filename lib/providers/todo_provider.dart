import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/notification_service.dart';

class TodoProvider with ChangeNotifier {
  final List<Todo> _todos = [];
  final NotificationService _notificationService = NotificationService();
  final _uuid = const Uuid();

  TodoProvider() {
    // Schedule daily reminder at midnight when the provider is initialized
    scheduleDailyReminder();
  }

  List<Todo> get todos => [..._todos];

  List<Todo> get pendingTodos =>
      _todos.where((todo) => !todo.isCompleted).toList();

  List<Todo> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  // Mengubah metode private menjadi publik agar dapat diakses dari luar
  void scheduleDailyReminder() {
    _notificationService.scheduleDailyReminderAt00();
  }

  void addTodo(String title, String description, DateTime deadline,
      {String subject = 'Umum', String difficulty = 'Sedang'}) {
    final newTodo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      deadline: deadline,
      subject: subject,
      difficulty: difficulty,
    );

    _todos.add(newTodo);
    _scheduleNotification(newTodo);
    notifyListeners();
  }

  void toggleTodoStatus(String id) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex >= 0) {
      _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;

      if (_todos[todoIndex].isCompleted) {
        _notificationService.cancelNotification(id);
      } else {
        _scheduleNotification(_todos[todoIndex]);
      }

      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    _notificationService.cancelNotification(id);
    notifyListeners();
  }

  void _scheduleNotification(Todo todo) {
    _notificationService.scheduleDeadlineNotifications(
      todo.id,
      todo.title,
      todo.deadline,
    );
  }
}
