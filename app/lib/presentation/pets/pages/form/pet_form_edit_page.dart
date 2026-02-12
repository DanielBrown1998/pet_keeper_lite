import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/text_pet_keeper.dart';

import '../../../../domain/entities/pet_entity.dart';
import '../../../../core/helpers/pet_species.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../common/widgets/camera_dialog.dart';
import '../../bloc/pet_bloc.dart';
import '../../bloc/pet_event.dart';
import '../../bloc/pet_state.dart';

class PetFormEditPage extends StatefulWidget {
  final String petId;

  const PetFormEditPage({super.key, required this.petId});

  @override
  State<PetFormEditPage> createState() => _PetFormEditPageState();
}

class _PetFormEditPageState extends State<PetFormEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _birthDate;
  PetSpecies _selectedSpecies = PetSpecies.dog;
  File? _photo;
  PetEntity? _existingPet;
  bool _isLoaded = false;

  void _loadPet() {
    if (_isLoaded) return;

    final petBloc = context.read<PetBloc>();
    final pet = petBloc.state.getPetById(widget.petId);
    if (pet != null) {
      _isLoaded = true;
      _existingPet = pet;
      _nameController.text = pet.name;
      _weightController.text = pet.weightKg?.toString() ?? '';
      _birthDate = pet.birthDate;
      _selectedSpecies = PetSpecies.fromValue(pet.species);
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _photo = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextPetKeeper('Erro ao selecionar imagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await CameraDialog.show(context);

      if (photo != null && mounted) {
        setState(() {
          _photo = photo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextPetKeeper('Erro ao tirar foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_existingPet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TextPetKeeper('Erro: pet não encontrado')),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;
      final familyCode = authState.user?.familyCode;

      if (familyCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TextPetKeeper('Erro: família não encontrada'),
          ),
        );
        return;
      }

      final pet = PetEntity(
        id: widget.petId,
        familyCode: familyCode,
        name: _nameController.text.trim(),
        species: _selectedSpecies.value,
        birthDate: _birthDate,
        weightKg: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        photoUrl: _existingPet?.photoUrl,
        createdAt: _existingPet!.createdAt,
      );

      context.read<PetBloc>().add(PetUpdateRequested(pet: pet, photo: _photo));
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    if (_existingPet == null) {
      return Scaffold(
        appBar: AppBar(title: const TextPetKeeper('Editar Pet')),
        body: const Center(child: TextPetKeeper('Pet não encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const TextPetKeeper('Editar Pet')),
      body: BlocConsumer<PetBloc, PetState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            context.pop();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: TextPetKeeper(state.error!),
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
                    // Photo picker
                    Center(
                      child: GestureDetector(
                        onTap: () => _showPhotoOptions(),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _photo != null
                                  ? FileImage(_photo!)
                                  : (_existingPet?.photoUrl != null
                                        ? NetworkImage(_existingPet!.photoUrl!)
                                              as ImageProvider
                                        : null),
                              child:
                                  (_photo == null &&
                                      _existingPet?.photoUrl == null)
                                  ? const Icon(
                                      Icons.pets,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.teal,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Pet',
                        prefixIcon: Icon(Icons.pets),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do pet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Species
                    DropdownButtonFormField<PetSpecies>(
                      initialValue: _selectedSpecies,
                      decoration: const InputDecoration(
                        labelText: 'Espécie',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: PetSpecies.values.map((species) {
                        return DropdownMenuItem(
                          value: species,
                          child: TextPetKeeper(species.displayNameWithEmoji),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedSpecies = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Birth date
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Data de Nascimento',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                            hintText: _birthDate != null
                                ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                                : 'Selecione a data',
                          ),
                          controller: TextEditingController(
                            text: _birthDate != null
                                ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                                : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                        hintText: 'Ex: 5.5',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0) {
                            return 'Por favor, insira um peso válido';
                          }
                        }
                        return null;
                      },
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
                          : const TextPetKeeper(
                              'Salvar Alterações',
                              style: TextStyle(fontSize: 16),
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

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const TextPetKeeper('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const TextPetKeeper('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
