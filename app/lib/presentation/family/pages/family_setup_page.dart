import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';

class FamilySetupPage extends StatefulWidget {
  const FamilySetupPage({super.key});

  @override
  State<FamilySetupPage> createState() => _FamilySetupPageState();
}

class _FamilySetupPageState extends State<FamilySetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _familyCodeController = TextEditingController();
  bool _isCreating = true;

  @override
  void dispose() {
    _familyCodeController.dispose();
    super.dispose();
  }

  void _submit(FamilyBloc bloc) {
    if (_formKey.currentState?.validate() ?? false) {
      final code = _familyCodeController.text.trim().toUpperCase();
      if (_isCreating) {
        bloc.add(FamilyCreateRequested(code));
      } else {
        bloc.add(FamilyJoinRequested(code));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Família'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<FamilyBloc, FamilyState>(
        listener: (context, state) {
          if (state.isSuccess && state.family != null) {
            context.read<AuthBloc>().add(const AuthCheckRequested());
            context.go('/pets');
          } else if (state.isError && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.family_restroom,
                      size: 80,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Código de Família',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'O código de família permite que você compartilhe seus pets com outros membros da família.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Criar Família'),
                          icon: Icon(Icons.add),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Entrar em Família'),
                          icon: Icon(Icons.login),
                        ),
                      ],
                      selected: {_isCreating},
                      onSelectionChanged: (value) {
                        setState(() {
                          _isCreating = value.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _familyCodeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Código da Família',
                        hintText: 'Ex: SILVA2024',
                        prefixIcon: const Icon(Icons.group_outlined),
                        border: const OutlineInputBorder(),
                        helperText: _isCreating
                            ? 'Crie um código único para sua família'
                            : 'Digite o código da família para entrar',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o código da família';
                        }
                        if (value.length < 4) {
                          return 'O código deve ter pelo menos 4 caracteres';
                        }
                        if (value.length > 20) {
                          return 'O código deve ter no máximo 20 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _submit(context.read<FamilyBloc>()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isCreating
                                  ? 'Criar Família'
                                  : 'Entrar na Família',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Como funciona?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '• Crie um código único para sua família\n'
                              '• Compartilhe o código com outros membros\n'
                              '• Todos com o mesmo código verão os mesmos pets\n'
                              '• Vacinas e tarefas são compartilhadas em tempo real',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
