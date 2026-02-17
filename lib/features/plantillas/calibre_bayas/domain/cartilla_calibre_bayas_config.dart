import '../../../cartillas/domain/cartilla_form_config.dart';
import '../../../cartillas/domain/cartilla_form_models.dart';

class CartillaCalibreBayasConfig implements CartillaFormConfig {
  // ========= Identidad =========
  static const String _templateKey = 'cartilla_calibre_bayas';
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
  static const String kHilera = 'hilera';
  static const String kPlanta = 'planta';
  static const String kCorresponde = 'corresponde';

  // ✅ BODY (calibres) 0.5mm .. 38mm (stepper int)
  static const String kMm0_5 = 'mm0_5';
  static const String kMm1 = 'mm1';
  static const String kMm1_5 = 'mm1_5';
  static const String kMm2 = 'mm2';
  static const String kMm2_5 = 'mm2_5';
  static const String kMm3 = 'mm3';
  static const String kMm3_5 = 'mm3_5';
  static const String kMm4 = 'mm4';
  static const String kMm4_5 = 'mm4_5';
  static const String kMm5 = 'mm5';
  static const String kMm5_5 = 'mm5_5';
  static const String kMm6 = 'mm6';
  static const String kMm6_5 = 'mm6_5';
  static const String kMm7 = 'mm7';
  static const String kMm7_5 = 'mm7_5';
  static const String kMm8 = 'mm8';
  static const String kMm8_5 = 'mm8_5';
  static const String kMm9 = 'mm9';
  static const String kMm9_5 = 'mm9_5';
  static const String kMm10 = 'mm10';
  static const String kMm10_5 = 'mm10_5';
  static const String kMm11 = 'mm11';
  static const String kMm11_5 = 'mm11_5';
  static const String kMm12 = 'mm12';
  static const String kMm12_5 = 'mm12_5';
  static const String kMm13 = 'mm13';
  static const String kMm13_5 = 'mm13_5';
  static const String kMm14 = 'mm14';
  static const String kMm14_5 = 'mm14_5';
  static const String kMm15 = 'mm15';
  static const String kMm15_5 = 'mm15_5';
  static const String kMm16 = 'mm16';
  static const String kMm16_5 = 'mm16_5';
  static const String kMm17 = 'mm17';
  static const String kMm17_5 = 'mm17_5';
  static const String kMm18 = 'mm18';
  static const String kMm18_5 = 'mm18_5';
  static const String kMm19 = 'mm19';
  static const String kMm19_5 = 'mm19_5';
  static const String kMm20 = 'mm20';
  static const String kMm20_5 = 'mm20_5';
  static const String kMm21 = 'mm21';
  static const String kMm21_5 = 'mm21_5';
  static const String kMm22 = 'mm22';
  static const String kMm22_5 = 'mm22_5';
  static const String kMm23 = 'mm23';
  static const String kMm23_5 = 'mm23_5';
  static const String kMm24 = 'mm24';
  static const String kMm24_5 = 'mm24_5';
  static const String kMm25 = 'mm25';
  static const String kMm25_5 = 'mm25_5';
  static const String kMm26 = 'mm26';
  static const String kMm26_5 = 'mm26_5';
  static const String kMm27 = 'mm27';
  static const String kMm27_5 = 'mm27_5';
  static const String kMm28 = 'mm28';
  static const String kMm28_5 = 'mm28_5';
  static const String kMm29 = 'mm29';
  static const String kMm29_5 = 'mm29_5';
  static const String kMm30 = 'mm30';
  static const String kMm30_5 = 'mm30_5';
  static const String kMm31 = 'mm31';
  static const String kMm31_5 = 'mm31_5';
  static const String kMm32 = 'mm32';
  static const String kMm32_5 = 'mm32_5';
  static const String kMm33 = 'mm33';
  static const String kMm33_5 = 'mm33_5';
  static const String kMm34 = 'mm34';
  static const String kMm34_5 = 'mm34_5';
  static const String kMm35 = 'mm35';
  static const String kMm35_5 = 'mm35_5';
  static const String kMm36 = 'mm36';
  static const String kMm36_5 = 'mm36_5';
  static const String kMm37 = 'mm37';
  static const String kMm37_5 = 'mm37_5';
  static const String kMm38 = 'mm38';

  // ✅ BODY (calculados)
  static const String kTotalBayasEvaluadas = 'totalBayasEvaluadas';
  static const String kPromCalibresPlanta = 'promCalibresPlanta';

  // ========= Header keys =========
  static const Set<String> _headerKeys = {
    kLoteId,
    kCampaniaId,
  };

  @override
  Set<String> get headerKeys => _headerKeys;

  // ========= Opciones estáticas =========
  static const List<String> _correspondeOptions = [
    'REPORDA',
    'PODA',
    'NINGUNO',
  ];

  // Interface obliga esto (aquí no aplica, devolvemos vacío)
  static const List<String> _etapas = [];
  @override
  List<String> get etapaFenologicaOptions => _etapas;

  // ========= (+1) replicables =========
  // Se replica: Lote, Campaña (header), Cant. Muestras y Corresponde (body)
  static const Set<String> _plusOneHeaderKeys = {
    kLoteId,
    kCampaniaId,
  };

  static const Set<String> _plusOneBodyKeys = {
    kCantidadMuestras,
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
          key: kHilera,
          label: '3. Hilera',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 2),
        ),
        CartillaFieldConfig(
          key: kPlanta,
          label: '4. Planta',
          type: CartillaFieldType.intNumber,
          rules: CartillaFieldRules(required: true, maxDigits: 3),
        ),
        CartillaFieldConfig(
          key: kCampaniaId,
          label: '5. Campaña',
          type: CartillaFieldType.dropdown,
          catalogSource: CartillaCatalogSource.campanias,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
        CartillaFieldConfig(
          key: kCorresponde,
          label: '6. Corresponde',
          type: CartillaFieldType.dropdown,
          staticOptions: _correspondeOptions,
          rules: CartillaFieldRules(required: true, copyOnPlus1: true),
        ),
      ],
    ),

    CartillaSectionConfig(
      key: 'calibres_0_5_18_5',
      title: 'CALIBRES 0.5mm – 18.5mm',
      fields: [
        CartillaFieldConfig(key: kMm0_5, label: '7. 0.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm1, label: '8. 1mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm1_5, label: '9. 1.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm2, label: '10. 2mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm2_5, label: '11. 2.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm3, label: '12. 3mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm3_5, label: '13. 3.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm4, label: '14. 4mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm4_5, label: '15. 4.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm5, label: '16. 5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm5_5, label: '17. 5.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm6, label: '18. 6mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm6_5, label: '19. 6.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm7, label: '20. 7mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm7_5, label: '21. 7.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm8, label: '22. 8mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm8_5, label: '23. 8.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm9, label: '24. 9mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm9_5, label: '25. 9.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm10, label: '26. 10mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm10_5, label: '27. 10.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm11, label: '28. 11mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm11_5, label: '29. 11.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm12, label: '30. 12mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm12_5, label: '31. 12.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm13, label: '32. 13mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm13_5, label: '33. 13.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm14, label: '34. 14mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm14_5, label: '35. 14.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm15, label: '36. 15mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm15_5, label: '37. 15.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm16, label: '38. 16mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm16_5, label: '39. 16.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm17, label: '40. 17mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm17_5, label: '41. 17.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm18, label: '42. 18mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm18_5, label: '43. 18.5mm', type: CartillaFieldType.stepperInt),
      ],
    ),

    CartillaSectionConfig(
      key: 'calibres_19_38',
      title: 'CALIBRES 19mm – 38mm',
      fields: [
        CartillaFieldConfig(key: kMm19, label: '44. 19mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm19_5, label: '45. 19.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm20, label: '46. 20mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm20_5, label: '47. 20.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm21, label: '48. 21mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm21_5, label: '49. 21.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm22, label: '50. 22mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm22_5, label: '51. 22.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm23, label: '52. 23mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm23_5, label: '53. 23.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm24, label: '54. 24mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm24_5, label: '55. 24.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm25, label: '56. 25mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm25_5, label: '57. 25.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm26, label: '58. 26mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm26_5, label: '59. 26.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm27, label: '60. 27mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm27_5, label: '61. 27.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm28, label: '62. 28mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm28_5, label: '63. 28.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm29, label: '64. 29mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm29_5, label: '65. 29.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm30, label: '66. 30mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm30_5, label: '67. 30.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm31, label: '68. 31mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm31_5, label: '69. 31.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm32, label: '70. 32mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm32_5, label: '71. 32.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm33, label: '72. 33mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm33_5, label: '73. 33.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm34, label: '74. 34mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm34_5, label: '75. 34.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm35, label: '76. 35mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm35_5, label: '77. 35.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm36, label: '78. 36mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm36_5, label: '79. 36.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm37, label: '80. 37mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm37_5, label: '81. 37.5mm', type: CartillaFieldType.stepperInt),
        CartillaFieldConfig(key: kMm38, label: '82. 38mm', type: CartillaFieldType.stepperInt),
      ],
    ),

    CartillaSectionConfig(
      key: 'resultados',
      title: 'RESULTADOS',
      fields: [
        CartillaFieldConfig(
          key: kTotalBayasEvaluadas,
          label: '83. Total de total bayas evaluadas',
          type: CartillaFieldType.decimalReadOnly,
        ),
        CartillaFieldConfig(
          key: kPromCalibresPlanta,
          label: '84. Prom. de calibres x planta',
          type: CartillaFieldType.decimalReadOnly,
        ),
      ],
    ),
  ];

  @override
  List<CartillaSectionConfig> get sections => _sections;
}
