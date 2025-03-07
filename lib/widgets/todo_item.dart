import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = todo.deadline.isBefore(now) && !todo.isCompleted;
    final isToday = todo.deadline.day == now.day &&
        todo.deadline.month == now.month &&
        todo.deadline.year == now.year;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isOverdue
          ? Colors.red.shade100
          : (isToday ? Colors.yellow.shade100 : Colors.white),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(todo.description),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Deadline: ${todo.deadline.day}/${todo.deadline.month}/${todo.deadline.year} at ${todo.deadline.hour}:${todo.deadline.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isOverdue ? Colors.red : Colors.grey,
                  fontWeight: isOverdue ? FontWeight.bold : null,
                ),
              ),
            ),
          ],
        ),
        leading: Checkbox(
          value: todo.isCompleted,
          activeColor: const Color(0xFF689F38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onChanged: (_) {
            _showToggleCompletionDialog(context);
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteConfirmationDialog(context);
          },
        ),
      ),
    );
  }

  void _showToggleCompletionDialog(BuildContext context) {
    final String dialogTitle =
        todo.isCompleted ? 'Mark as Incomplete?' : 'Mark as Complete?';
    final String dialogContent = todo.isCompleted
        ? 'Are you sure you want to mark "${todo.title}" as incomplete?'
        : 'Are you sure you want to mark "${todo.title}" as complete?';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogContent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false)
                  .toggleTodoStatus(todo.id);
              Navigator.of(ctx).pop();

              // Show a confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    todo.isCompleted
                        ? 'Task marked as incomplete'
                        : 'Task completed!',
                  ),
                  backgroundColor: const Color(0xFF689F38),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF689F38),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false)
                  .deleteTodoById(todo.id);
              Navigator.of(ctx).pop();

              // Show a confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
