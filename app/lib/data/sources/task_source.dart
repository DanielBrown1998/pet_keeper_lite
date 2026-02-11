import '../models/pet_task_model.dart';

/// Contract for task data source (Firestore)
abstract class TaskSource {
  /// Watch tasks for a pet (real-time stream)
  Stream<List<PetTaskModel>> watchTasks(String petId);

  /// Get a single task by ID
  Future<PetTaskModel?> getTask(String taskId);

  /// Create a new task
  Future<void> createTask(PetTaskModel task);

  /// Update an existing task
  Future<void> updateTask(PetTaskModel task);

  /// Delete a task
  Future<void> deleteTask(String taskId);

  /// Toggle task done status
  Future<void> toggleTaskDone(String taskId, bool done);
}
