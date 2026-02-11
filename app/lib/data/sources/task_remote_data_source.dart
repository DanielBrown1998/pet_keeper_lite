import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pet_task_model.dart';

/// Contract for task data source (Firestore)
abstract class TaskRemoteDataSource {
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

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Stream<List<PetTaskModel>> watchTasks(String petId) {
    return _firestore
        .collection('pet_tasks')
        .where('petId', isEqualTo: petId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PetTaskModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<PetTaskModel?> getTask(String taskId) async {
    final doc = await _firestore.collection('pet_tasks').doc(taskId).get();
    if (!doc.exists) return null;
    return PetTaskModel.fromFirestore(doc);
  }

  @override
  Future<void> createTask(PetTaskModel task) {
    return _firestore
        .collection('pet_tasks')
        .doc(task.id)
        .set(task.toFirestore());
  }

  @override
  Future<void> updateTask(PetTaskModel task) {
    return _firestore
        .collection('pet_tasks')
        .doc(task.id)
        .update(task.toFirestore());
  }

  @override
  Future<void> deleteTask(String taskId) {
    return _firestore.collection('pet_tasks').doc(taskId).delete();
  }

  @override
  Future<void> toggleTaskDone(String taskId, bool done) {
    return _firestore.collection('pet_tasks').doc(taskId).update({
      'done': done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
