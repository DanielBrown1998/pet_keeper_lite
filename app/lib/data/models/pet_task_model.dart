import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pet_task_entity.dart';

class PetTaskModel extends PetTaskEntity {
  const PetTaskModel({
    required super.id,
    required super.petId,
    required super.type,
    required super.title,
    super.dueDate,
    super.notes,
    required super.createdBy,
    required super.createdAt,
    super.done,
  });

  factory PetTaskModel.fromEntity(PetTaskEntity entity) {
    return PetTaskModel(
      id: entity.id,
      petId: entity.petId,
      type: entity.type,
      title: entity.title,
      dueDate: entity.dueDate,
      notes: entity.notes,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      done: entity.done,
    );
  }

  factory PetTaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Task document data is null');
    }
    return PetTaskModel(
      id: doc.id,
      petId: data['petId'] ?? '',
      type: _parseTaskType(data['type']),
      title: data['title'] ?? '',
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      done: data['done'] ?? false,
    );
  }

  static TaskType _parseTaskType(String? type) {
    switch (type) {
      case 'vaccine':
        return TaskType.vaccine;
      case 'grooming':
        return TaskType.grooming;
      default:
        return TaskType.other;
    }
  }

  static String _taskTypeToString(TaskType type) {
    switch (type) {
      case TaskType.vaccine:
        return 'vaccine';
      case TaskType.grooming:
        return 'grooming';
      case TaskType.other:
        return 'other';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'type': _taskTypeToString(type),
      'title': title,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'done': done,
    };
  }

  @override
  PetTaskModel copyWith({
    String? id,
    String? petId,
    TaskType? type,
    String? title,
    DateTime? dueDate,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    bool? done,
  }) {
    return PetTaskModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      done: done ?? this.done,
    );
  }
}
