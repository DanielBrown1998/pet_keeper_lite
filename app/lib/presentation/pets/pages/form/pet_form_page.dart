import 'package:flutter/material.dart';

import 'pet_form_create_page.dart';
import 'pet_form_edit_page.dart';

class PetFormPage extends StatelessWidget {
  final String? petId;

  const PetFormPage({super.key, this.petId});

  @override
  Widget build(BuildContext context) {
    if (petId == null) {
      return const PetFormCreatePage();
    }
    return PetFormEditPage(petId: petId!);
  }
}
