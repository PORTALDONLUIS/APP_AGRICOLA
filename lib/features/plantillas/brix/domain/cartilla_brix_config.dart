import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaBrixConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_brix';
  static const int _payloadVersion = 1;

  static const int payloadVersionStatic = _payloadVersion;
  static const String templateKeyStatic = _templateKey;

  @override
  String get templateKey => _templateKey;

  @override
  int get payloadVersion => _payloadVersion;

  // ========= Keys =========
  // ✅ HEADER
  static const String kLoteId = 'loteId';
  static const String kCampaniaId = 'campaniaId';

  // ✅ BODY (datos generales)
  static const String kCantidadMuestras = 'cantidadMuestras';
  static const String kFenologia = 'fenologia';
  static const String kDetalleFenologia = 'detalleFenologia';
  static const String kCorresponde = 'corresponde';
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';

  // ✅ BODY (medición BRIX: conteos por “%”)
  static const String kBrix5 = 'brix5';
  static const String kBrix5_5 = 'brix5_5';
  static const String kBrix6 = 'brix6';
  static const String kBrix6_5 = 'brix6_5';
  static const String kBrix7 = 'brix7';
  static const String kBrix7_5 = 'brix7_5';
  static const String kBrix8 = 'brix8';
  static const String kBrix8_5 = 'brix8_5';
  static const String kBrix9 = 'brix9';
  static const String kBrix9_5 = 'brix9_5';
  static const String kBrix10 = 'brix10';
  static const String kBrix10_5 = 'brix10_5';
  static const String kBrix11 = 'brix11';
  static const String kBrix11_5 = 'brix11_5';
  static const String kBrix12 = 'brix12';
  static const String kBrix12_5 = 'brix12_5';
  static const String kBrix13 = 'brix13';
  static const String kBrix13_5 = 'brix13_5';
  static const String kBrix14 = 'brix14';
  static const String kBrix14_5 = 'brix14_5';
  static const String kBrix15 = 'brix15';
  static const String kBrix15_5 = 'brix15_5';
  static const String kBrix16 = 'brix16';
  static const String kBrix16_5 = 'brix16_5';
  static const String kBrix17 = 'brix17';
  static const String kBrix17_5 = 'brix17_5';
  static const String kBrix18 = 'brix18';
  static const String kBrix18_5 = 'brix18_5';
  static const String kBrix19 = 'brix19';
  static const String kBrix19_5 = 'brix19_5';
  static const String kBrix20 = 'brix20';
  static const String kBrix20_5 = 'brix20_5';
  static const String kBrix21 = 'brix21';
  static const String kBrix21_5 = 'brix21_5';
  static const String kBrix22 = 'brix22';
  static const String kBrix22_5 = 'brix22_5';
  static const String kBrix23 = 'brix23';
  static const String kBrix23_5 = 'brix23_5';

  // ✅ BODY (calculados)
  static const String kTotalBayasEvaluadas = 'totalBayasEvaluadas';
  static const String kPromBrixPlanta = 'promBrixPlanta';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Opciones estáticas =========
  static const List<String> _fenologiaOptions = [
    'ORILLA',
    'INTERIOR',
  ];

  /// [detalleFenologia] solo tiene sentido con [fenologia] == `ORILLA` (orillas del lote).
  /// Si no es ORILLA (p. ej. INTERIOR), el valor se limpia en `_recompute` del formulario BRIX.
  static bool detalleFenologiaAplica(String? fenologiaRaw) {
    return (fenologiaRaw ?? '').toString().trim() == 'ORILLA';
  }

  static const List<String> _correspondeOptions = [
    'REPORDA',
    'PODA',
    'NINGUNO',
  ];

  // Interface obliga esto (no aplica aquí)
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // PDF: Lote, Cantidad muestras, Fenología, Detalle Fenología, Corresponde, Campaña replican con +1.
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kCantidadMuestras,
    kFenologia,
    kDetalleFenologia,
    kCorresponde,
  };

  @override
  Set<String> get plusOneReplicableHeaderKeys => _plusOneHeaderKeys;

  @override
  Set<String> get plusOneReplicableBodyKeys => _plusOneBodyKeys;

  // ========= Sections =========
  static const List<CartillaSectionConfig> _sections = [
    CartillaSectionConfig(
      key: 'datos_generales',
      title: 'DATOS GENERALES',
      fields: [
        CartillaFieldConfig(
          key: kLoteId,
          label: '1. Lote',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.lotes,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCantidadMuestras,
          label: '2. Cantidad de muestras',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kFenologia,
          label: '3. Fenología',
          type: CartillaFieldType.dropdown,
          staticOptions: _fenologiaOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        // Orillas del lote: la UI solo habilita el catálogo si Fenología = ORILLA.
        CartillaFieldConfig(
          key: kDetalleFenologia,
          label: '4. Detalle Fenología',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.orillasPorLote,
          dependsOnHeaderKey: kLoteId,
          rules: CartillaFieldRules(required: false, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCorresponde,
          label: '5. Corresponde',
          type: CartillaFieldType.dropdown,
          staticOptions: _correspondeOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '6. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kHilera,
          label: '7. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '8. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'medicion_brix',
      title: 'MEDICIÓN DE BRIX',
      fields: [
        CartillaFieldConfig(key: kBrix5, label: '9. 5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix5_5, label: '10. 5.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix6, label: '11. 6%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix6_5, label: '12. 6.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix7, label: '13. 7%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix7_5, label: '14. 7.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix8, label: '15. 8%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix8_5, label: '16. 8.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix9, label: '17. 9%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix9_5, label: '18. 9.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix10, label: '19. 10%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix10_5, label: '20. 10.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix11, label: '21. 11%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix11_5, label: '22. 11.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix12, label: '23. 12%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix12_5, label: '24. 12.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix13, label: '25. 13%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix13_5, label: '26. 13.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix14, label: '27. 14%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix14_5, label: '28. 14.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix15, label: '29. 15%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix15_5, label: '30. 15.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix16, label: '31. 16%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix16_5, label: '32. 16.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix17, label: '33. 17%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix17_5, label: '34. 17.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix18, label: '35. 18%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix18_5, label: '36. 18.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix19, label: '37. 19%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix19_5, label: '38. 19.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix20, label: '39. 20%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix20_5, label: '40. 20.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix21, label: '41. 21%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix21_5, label: '42. 21.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix22, label: '43. 22%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix22_5, label: '44. 22.5%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix23, label: '45. 23%', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kBrix23_5, label: '46. 23.5%', type: CartillaFieldType.stepperInt),

        CartillaFieldConfig(
          key: kTotalBayasEvaluadas,
          label: '47. Total de bayas evaluadas',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kPromBrixPlanta,
          label: '48. Prom. Brix*Planta',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
