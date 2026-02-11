import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/pet_task_entity.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class TaskFormPage extends StatefulWidget {
  final String petId;
  final String? taskId;

  const TaskFormPage({super.key, required this.petId, this.taskId});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dueDate;
  TaskType _selectedType = TaskType.vaccine;
  PetTaskEntity? _existingTask;

  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadTask();
    }
  }

  void _loadTask() {
    final taskBloc = context.read<TaskBloc>();
    final task = taskBloc.state.tasks
        .where((t) => t.id == widget.taskId)
        .firstOrNull;
    if (task != null) {
      _existingTask = task;
      _titleController.text = task.title;
      _notesController.text = task.notes ?? '';
      _dueDate = task.dueDate;
      _selectedType = task.type;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _submit() {
    final bloc = context.read<TaskBloc>();
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      final userId = authState.user?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: usuário não encontrado')),
        );
        return;
      }

      final task = PetTaskEntity(
        id: widget.taskId ?? const Uuid().v4(),
        petId: widget.petId,
        type: _selectedType,
        title: _titleController.text.trim(),
        dueDate: _dueDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdBy: _existingTask?.createdBy ?? userId,
        createdAt: _existingTask?.createdAt ?? DateTime.now(),
        done: _existingTask?.done ?? false,
      );

      if (isEditing) {
        bloc.add(TaskUpdateRequested(task));
      } else {
        bloc.add(TaskCreateRequested(task));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Adicionar Tarefa'),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listenWhen: (previous, current) =>
            previous.error != current.error ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.successMessage != null) {
            context.pop();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.isSubmitting;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Task type
                    Text('Tipo', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<TaskType>(
                      segments: const [
                        ButtonSegment<TaskType>(
                          value: TaskType.vaccine,
                          label: Text('Vacina'),
                          icon: Icon(Icons.vaccines),
                        ),
                        ButtonSegment<TaskType>(
                          value: TaskType.grooming,
                          label: Text('Banho'),
                          icon: Icon(Icons.bathtub),
                        ),
                        ButtonSegment<TaskType>(
                          value: TaskType.other,
                          label: Text('Outro'),
                          icon: Icon(Icons.task),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (value) {
                        setState(() {
                          _selectedType = value.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: _getPlaceholderForType(_selectedType),
                        prefixIcon: Icon(_getIconForType(_selectedType)),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Due date
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Data',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                            hintText: _dueDate != null
                                ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                                : 'Selecione a data',
                            suffixIcon: _dueDate != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _dueDate = null;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          controller: TextEditingController(
                            text: _dueDate != null
                                ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                                : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing
                                  ? 'Salvar Alterações'
                                  : 'Adicionar Tarefa',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),

                    // Quick add suggestions for vaccines
                    if (_selectedType == TaskType.vaccine && !isEditing) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Sugestões rápidas:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSuggestionChip('V8/V10'),
                          _buildSuggestionChip('Antirrábica'),
                          _buildSuggestionChip('Vermífugo'),
                          _buildSuggestionChip('Antipulgas'),
                          _buildSuggestionChip('Quádrupla Felina'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _titleController.text = label;
      },
    );
  }

  String _getPlaceholderForType(TaskType type) {
    switch (type) {
      case TaskType.vaccine:
        return 'Nome da Vacina';
      case TaskType.grooming:
        return 'Descrição';
      case TaskType.other:
        return 'Título da Tarefa';
    }
  }

  IconData _getIconForType(TaskType type) {
    switch (type) {
      case TaskType.vaccine:
        return Icons.vaccines;
      case TaskType.grooming:
        return Icons.bathtub;
      case TaskType.other:
        return Icons.task;
    }
  }
}
