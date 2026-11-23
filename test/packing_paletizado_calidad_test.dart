import 'package:donluis_forms/features/cartillas/application/cartilla_validator.dart';
import 'package:donluis_forms/features/plantillas/packing_quality/domain/cartilla_packing_quality_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Paletizado exige la presentación y permite fotos opcionales', () {
    final config = CartillaPackingQualityConfig(
      'cartilla_packing_paletizado_calidad',
    );
    final header = <String, dynamic>{'loteId': 1, 'campaniaId': '2026'};
    final body = <String, dynamic>{
      'variedad': 7,
      'totalCajas': 0,
      'motivoPallet': 'COMPLETO',
      'codigoLugarProduccion': '016-00929-02',
      'etiqueta': 'MUSCAT TREAS',
      'envase': 'CARTON 5.0 KG. CLM-1.1LB',
      'categoria': 'CATEGORIA 1',
      'calibre': 'XL',
      'color': 'VC',
      'numeroPaleta': 'P-001',
      'horaRegistroPaleta': '12:30',
    };

    List<ValidationIssue> validate() => validateRequired(
      config: config,
      getHeaderValue: (key) => header[key],
      getBodyValue: (key) => body[key],
    );

    expect(validate().map((issue) => issue.fieldKey), ['destino']);
    body['destino'] = 'TAIWAN, PROVINCIA DE CHINA';
    expect(validate(), isEmpty);
  });
}
