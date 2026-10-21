import '../domain/cartilla_form_config.dart';

class ValidationIssue {
  final String sectionKey;
  final String sectionTitle;
  final String fieldKey;
  final String fieldLabel;

  const ValidationIssue({
    required this.sectionKey,
    required this.sectionTitle,
    required this.fieldKey,
    required this.fieldLabel,
  });
}

bool _isEmpty(dynamic v) {
  if (v == null) return true;
  if (v is String) return v.trim().isEmpty;
  if (v is Iterable) return v.isEmpty;
  return false;
}

List<ValidationIssue> validateRequired({
  required CartillaFormConfig config,
  required dynamic Function(String key) getHeaderValue,
  required dynamic Function(String key) getBodyValue,
}) {
  final issues = <ValidationIssue>[];

  for (final section in config.sections) {
    if (config.templateKey == 'cartilla_movilidades_cosecha' && section.key == 'datos_guia') {
      final guides = getBodyValue('guias');
      if (guides is List && guides.isNotEmpty) {
        for (var i = 0; i < guides.length; i++) {
          final guide = guides[i];
          for (final field in section.fields) {
            final value = guide is Map ? guide[field.key] : null;
            if ((field.rules.required && _isEmpty(value)) ||
                (field.key == 'cantidadCajas' &&
                  (int.tryParse('$value') == null || int.parse('$value') < 0))) {
              issues.add(ValidationIssue(sectionKey: section.key,
                sectionTitle: '${section.title} · Guía ${i + 1}',
                fieldKey: field.key, fieldLabel: 'Guía ${i + 1}: ${field.label}'));
            }
          }
        }
        continue;
      }
    }
    for (final field in section.fields) {
      final rules = field.rules;
      if (!rules.required) continue;

      final isHeader = config.headerKeys.contains(field.key);
      final value = isHeader
          ? getHeaderValue(field.key)
          : getBodyValue(field.key);

      // Para contadores: 0 puede ser válido o no dependiendo tu negocio.
      // Aquí: requerido = no vacío. Si quieres requerido>0, dime y lo ajusto.
      if (_isEmpty(value)) {
        issues.add(
          ValidationIssue(
            sectionKey: section.key,
            sectionTitle: section.title,
            fieldKey: field.key,
            fieldLabel: field.label,
          ),
        );
      }
    }
  }

  return issues;
}
