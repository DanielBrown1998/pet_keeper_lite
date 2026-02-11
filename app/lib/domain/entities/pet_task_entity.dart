import 'package:equatable/equatable.dart';

enum TaskType { vaccine, grooming, other }

class PetTaskEntity extends Equatable {
  final String id;
  final String petId;
  final TaskType type;
  final String title;
  final DateTime? dueDate;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final bool done;

  const PetTaskEntity({
    required this.id,
    required this.petId,
    required this.type,
    required this.title,
    this.dueDate,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.done = false,
  });

  PetTaskEntity copyWith({
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
    return PetTaskEntity(
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

  @override
  List<Object?> get props => [
    id,
    petId,
    type,
    title,
    dueDate,
    notes,
    createdBy,
    createdAt,
    done,
  ];
}
