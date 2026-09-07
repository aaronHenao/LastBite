import 'package:flutter/material.dart';
import 'package:lastbite/core/widgets/boton_volver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lastbite/core/responsive/responsive_container.dart';
import 'package:lastbite/core/theme/app_theme.dart';
import '../domain/perfil_nutricional.dart';
import 'perfil_nutricional_provider.dart';

class PerfilNutricionalScreen extends ConsumerStatefulWidget {
  const PerfilNutricionalScreen({super.key});

  @override
  ConsumerState<PerfilNutricionalScreen> createState() =>
      _PerfilNutricionalScreenState();
}

class _PerfilNutricionalScreenState
    extends ConsumerState<PerfilNutricionalScreen> {
  final _restriccionesController = TextEditingController();
  final _alergiasController = TextEditingController();
  String _userType = 'none';
  String _goal = 'none';
  String _dietaryType = 'omnivore';
  bool _inicializado = false;

  @override
  void dispose() {
    _restriccionesController.dispose();
    _alergiasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perfilState = ref.watch(perfilNutricionalProvider);
    final textTheme = Theme.of(context).textTheme;

    perfilState.whenData((perfil) {
      if (!_inicializado) {
        if (perfil != null) {
          _userType = perfil.userType;
          _goal = perfil.goal;
          _dietaryType = perfil.dietaryType;
          _restriccionesController.text = perfil.restrictions.join(', ');
          _alergiasController.text = perfil.allergies.join(', ');
        }
        // Se marca aunque el perfil venga vacio: si no, cualquier re-emision
        // posterior pisaba lo que el usuario ya hubiera elegido.
        _inicializado = true;
      }
    });

    // Hasta que el perfil resuelva no se muestra un formulario con valores por
    // defecto que no son los del usuario.
    if (perfilState.isLoading && !_inicializado) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: context.paleta.marca)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 700,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              const BotonVolver(),
              const SizedBox(height: 24),
              Text(
                'PERFIL NUTRICIONAL',
                style: textTheme.titleSmall?.copyWith(
                  letterSpacing: 1.5,
                  color: context.paleta.apagado,
                ),
              ),
              const SizedBox(height: 6),
              Text('Preferencias de recetas', style: textTheme.headlineMedium),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Tipo de usuario',
                value: _userType,
                items: const {
                  'none': 'Sin preferencia',
                  'athlete': 'Deportista',
                  'nutritional_plan': 'Plan nutricional',
                },
                onChanged: (value) => setState(() => _userType = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Objetivo nutricional',
                value: _goal,
                items: const {
                  'none': 'Sin objetivo específico',
                  'lose_weight': 'Perder peso',
                  'maintain_weight': 'Mantener peso',
                  'gain_weight': 'Ganar peso',
                },
                onChanged: (value) => setState(() => _goal = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Tipo de alimentación',
                value: _dietaryType,
                items: const {
                  'omnivore': 'Omnívora',
                  'vegetarian': 'Vegetariana',
                  'vegan': 'Vegana',
                  'other': 'Otra',
                },
                onChanged: (value) => setState(() => _dietaryType = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _restriccionesController,
                label: 'Restricciones alimentarias',
                hint: 'Ej. cerdo, mariscos',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _alergiasController,
                label: 'Alergias o intolerancias',
                hint: 'Ej. maní, gluten',
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: perfilState.isLoading ? null : _guardar,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar perfil'),
                // Colores del tema: con la paleta nueva, texto oscuro sobre
                // el verde de marca no llegaba al contraste minimo.
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              if (perfilState.hasError) ...[
                const SizedBox(height: 12),
                Text(
                  'No se pudo guardar el perfil: ${perfilState.error}',
                  style: TextStyle(color: context.paleta.vencido),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: context.paleta.superficie,
      items: items.entries
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.key,
              child: Text(item.value),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Future<void> _guardar() async {
    final perfil = PerfilNutricional(
      userType: _userType,
      goal: _goal,
      dietaryType: _dietaryType,
      restrictions: _parseList(_restriccionesController.text),
      allergies: _parseList(_alergiasController.text),
    );

    await ref.read(perfilNutricionalProvider.notifier).guardar(perfil);
    if (!mounted) return;
    if (!ref.read(perfilNutricionalProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil nutricional guardado')),
      );
    }
  }

  List<String> _parseList(String value) => value
      .split(',')
      .map((item) => item.trim().toLowerCase())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();
}
