import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../core/network/http_error_handler.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../../shared/widgets/donluis_empty_state.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../domain/persona.dart';
import '../domain/persona_tipo.dart';

class PersonasPage extends ConsumerStatefulWidget {
  const PersonasPage({super.key});

  @override
  ConsumerState<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends ConsumerState<PersonasPage> {
  final _dniCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Persona> _personas = const [];
  List<PersonaTipo> _tipos = const [];

  Persona? _editingPersona;
  PersonaTipo? _selectedTipo;

  bool _activo = true;
  bool _loadingPage = true;
  bool _saving = false;
  bool _consultingDni = false;
  String? _pageError;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loadingPage = true;
      _pageError = null;
    });

    try {
      final repo = ref.read(personasRepoProvider);
      final tipos = await repo.fetchTipos();
      final personas = await repo.fetchPersonas();

      if (!mounted) return;

      setState(() {
        _tipos = tipos;
        _personas = personas;
        _selectedTipo = _resolvePreferredTipo(tipos, current: _selectedTipo);
        _loadingPage = false;
      });
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _loadingPage = false;
        _pageError = HttpErrorHandler.toUserMessage(e, st);
      });
    }
  }

  PersonaTipo? _resolvePreferredTipo(
    List<PersonaTipo> tipos, {
    PersonaTipo? current,
  }) {
    if (tipos.isEmpty) return null;
    if (current != null) {
      for (final tipo in tipos) {
        if (tipo.id == current.id) return tipo;
      }
    }

    for (final tipo in tipos) {
      if (tipo.codigo.toUpperCase() == 'PODADOR') return tipo;
    }
    return tipos.first;
  }

  Future<void> _consultarDni() async {
    final dni = _dniCtrl.text.trim();
    if (!_isValidDni(dni)) {
      _showSnackBar('El DNI debe tener exactamente 8 dígitos.', isError: true);
      return;
    }

    setState(() => _consultingDni = true);

    try {
      final result = await ref.read(personasRepoProvider).consultarDni(dni);
      if (!mounted) return;

      if (result.found && (result.nombreCompleto ?? '').trim().isNotEmpty) {
        _nombreCtrl.text = result.nombreCompleto!.trim();
        _showSnackBar('DNI consultado correctamente.');
      } else {
        _showSnackBar(
          result.message ??
              'No se encontró información. Ingresa el nombre manualmente.',
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      _showSnackBar(HttpErrorHandler.toUserMessage(e, st), isError: true);
    } finally {
      if (mounted) {
        setState(() => _consultingDni = false);
      }
    }
  }

  Future<void> _savePersona() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final selectedTipo = _selectedTipo;
    if (selectedTipo == null) {
      _showSnackBar('Selecciona un tipo de persona.', isError: true);
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(personasRepoProvider);
      final dni = _dniCtrl.text.trim();
      final nombreCompleto = _nombreCtrl.text.trim();
      final isEditing = _editingPersona != null;

      if (!isEditing) {
        await repo.createPersona(
          dni: dni,
          nombreCompleto: nombreCompleto,
          tipoId: selectedTipo.id,
          estado: _activo,
        );
      } else {
        await repo.updatePersona(
          personaId: _editingPersona!.id,
          dni: dni,
          nombreCompleto: nombreCompleto,
          tipoId: selectedTipo.id,
          estado: _activo,
        );
      }

      await _loadInitialData();
      if (!mounted) return;

      _resetForm();
      _showSnackBar(
        !isEditing
            ? 'Persona registrada correctamente.'
            : 'Persona actualizada correctamente.',
      );
    } catch (e, st) {
      if (!mounted) return;
      _showSnackBar(_extractSaveError(e, st), isError: true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _deactivatePersona(Persona persona) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Desactivar persona'),
            content: Text(
              'Se marcará como inactiva a ${persona.nombreCompleto}.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Desactivar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await ref.read(personasRepoProvider).deletePersona(persona.id);
      await _loadInitialData();
      if (!mounted) return;

      if (_editingPersona?.id == persona.id) {
        _resetForm();
      }
      _showSnackBar('Persona desactivada correctamente.');
    } catch (e, st) {
      if (!mounted) return;
      _showSnackBar(HttpErrorHandler.toUserMessage(e, st), isError: true);
    }
  }

  void _startEditing(Persona persona) {
    final tipo = _tipos.cast<PersonaTipo?>().firstWhere(
      (item) => item?.id == persona.tipoId,
      orElse: () => _selectedTipo,
    );

    setState(() {
      _editingPersona = persona;
      _dniCtrl.text = persona.dni;
      _nombreCtrl.text = persona.nombreCompleto;
      _selectedTipo = tipo;
      _activo = persona.estado;
    });
  }

  void _resetForm() {
    setState(() {
      _editingPersona = null;
      _dniCtrl.clear();
      _nombreCtrl.clear();
      _activo = true;
      _selectedTipo = _resolvePreferredTipo(_tipos);
    });
  }

  bool _isValidDni(String value) {
    return RegExp(r'^\d{8}$').hasMatch(value);
  }

  String _extractSaveError(Object error, StackTrace st) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final errors = data['errors'];
        if (errors is Map<String, dynamic>) {
          for (final entry in errors.values) {
            if (entry is List && entry.isNotEmpty) {
              return entry.first.toString();
            }
          }
        }
      }
    }
    return HttpErrorHandler.toUserMessage(error, st);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _dniCtrl.text.trim();
    final filtered = query.isEmpty
        ? _personas
        : _personas.where((persona) => persona.dni.contains(query)).toList();

    return DonLuisGradientScaffold(
      appBar: DonLuisAppBar(title: const Text('Personas')),
      body: _loadingPage
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (_pageError != null) ...[
                    _InfoBanner(message: _pageError!, isError: true),
                    const SizedBox(height: 12),
                  ],
                  _buildFormCard(context),
                  const SizedBox(height: 16),
                  _buildListHeader(filtered.length),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    const SizedBox(
                      height: 240,
                      child: DonLuisEmptyState(
                        message: 'No hay personas registradas',
                        submessage:
                            'Crea una nueva persona o ajusta el DNI para filtrar.',
                        icon: Icons.badge_outlined,
                      ),
                    )
                  else
                    ...filtered.map(_buildPersonaCard),
                ],
              ),
            ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DonLuisColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _editingPersona == null
                          ? Icons.person_add_alt_1
                          : Icons.edit_note,
                      color: DonLuisColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingPersona == null
                              ? 'Registrar persona'
                              : 'Editar persona',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Consulta el DNI desde backend o completa el nombre manualmente.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (_editingPersona != null)
                    TextButton(
                      onPressed: _saving ? null : _resetForm,
                      child: const Text('Cancelar edición'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dniCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  hintText: '8 dígitos',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final dni = (value ?? '').trim();
                  if (dni.isEmpty) {
                    return 'El DNI es obligatorio.';
                  }
                  if (!_isValidDni(dni)) {
                    return 'El DNI debe tener exactamente 8 dígitos.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _consultingDni || _saving ? null : _consultarDni,
                  icon: _consultingDni
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: const Text('Consultar DNI'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa el nombre completo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PersonaTipo>(
                value: _selectedTipo,
                items: _tipos
                    .map(
                      (tipo) => DropdownMenuItem<PersonaTipo>(
                        value: tipo,
                        child: Text(tipo.descripcion),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() => _selectedTipo = value);
                      },
                decoration: const InputDecoration(
                  labelText: 'Tipo persona',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) {
                  if (value == null) return 'Selecciona un tipo de persona.';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _activo,
                contentPadding: EdgeInsets.zero,
                activeColor: DonLuisColors.secondary,
                title: const Text('Activo'),
                subtitle: Text(
                  _activo
                      ? 'La persona estará habilitada.'
                      : 'La persona quedará desactivada.',
                ),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _activo = value),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _savePersona,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _editingPersona == null ? 'Guardar' : 'Actualizar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(int count) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personas registradas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '$count resultado(s) ${_dniCtrl.text.trim().isEmpty ? '' : 'para el DNI filtrado'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Recargar',
          onPressed: _loadingPage ? null : _loadInitialData,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildPersonaCard(Persona persona) {
    final estadoColor = persona.estado
        ? DonLuisColors.secondary
        : Colors.red.shade600;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: DonLuisColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: DonLuisColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.nombreCompleto,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DNI ${persona.dni} • ${persona.tipoCodigo}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DonLuisColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            label: persona.estado ? 'Activo' : 'Inactivo',
                            color: estadoColor,
                          ),
                          _StatusChip(
                            label: persona.tipoDescripcion,
                            color: DonLuisColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : () => _startEditing(persona),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: (!persona.estado || _saving)
                        ? null
                        : () => _deactivatePersona(persona),
                    icon: const Icon(Icons.person_off_outlined),
                    label: const Text('Desactivar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : DonLuisColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
