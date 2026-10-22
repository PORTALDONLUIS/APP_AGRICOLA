import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/providers.dart';
import '../../../app/theme/donluis_theme.dart';
import '../../../shared/widgets/donluis_app_bar.dart';
import '../../../shared/widgets/donluis_gradient_scaffold.dart';
import '../data/tic_assignments_remote_ds.dart';

final ticAssignmentsRemoteProvider = Provider<TicAssignmentsRemoteDS>(
  (ref) => TicAssignmentsRemoteDS(ref.read(dioClientProvider).dio),
);

class TicAssignmentPage extends ConsumerStatefulWidget {
  const TicAssignmentPage({super.key});
  @override
  ConsumerState<TicAssignmentPage> createState() => _TicAssignmentPageState();
}

class _TicAssignmentPageState extends ConsumerState<TicAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _signatureKey = GlobalKey();
  final _document = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final List<Offset?> _points = [];
  List<Map<String, dynamic>> _assets = [];
  Map<String, dynamic>? _selected;
  Uint8List? _evidence;
  String? _category;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _assets = await ref.read(ticAssignmentsRemoteProvider).availableAssets(category: _category);
      _selected = null;
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo cargar el inventario disponible.')));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<Uint8List> _signaturePng() async {
    final boundary = _signatureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.5);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _pickEvidence() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 78, maxWidth: 1600);
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => _evidence = bytes);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selected == null) return;
    if (_points.whereType<Offset>().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicita la firma del trabajador.'))); return;
    }
    setState(() => _saving = true);
    try {
      final result = await ref.read(ticAssignmentsRemoteProvider).assign(
        assetId: _selected!['id'] as int, document: _document.text.trim(), name: _name.text.trim(),
        email: _email.text.trim(), phone: _phone.text.trim(), observations: _notes.text.trim(),
        signature: await _signaturePng(), evidence: _evidence,
      );
      if (!mounted) return;
      await Share.share(result['whatsapp_text'] as String? ?? 'Asignación TIC registrada correctamente.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignación registrada y constancia generada.'), backgroundColor: Color(0xff08765c)));
      _formKey.currentState!.reset(); _document.clear(); _name.clear(); _email.clear(); _phone.clear(); _notes.clear(); _points.clear(); _evidence = null; await _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo registrar: $e')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return DonLuisGradientScaffold(
      appBar: const DonLuisAppBar(title: Text('Asignación de equipos')),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _hero(), const SizedBox(height: 18), _section('1', 'Selecciona el equipo', [
          Wrap(spacing: 8, runSpacing: 8, children: const [('PHONE','Celular',Icons.smartphone),('LAPTOP','Laptop',Icons.laptop_mac),('PC','PC',Icons.desktop_windows),('OTHER','Otro',Icons.devices_other)].map((item) => ChoiceChip(avatar: Icon(item.$3,size:18), label: Text(item.$2), selected: _category==item.$1, onSelected: (_){setState(()=>_category=item.$1);_load();})).toList()),
          const SizedBox(height:12), if(_loading) const LinearProgressIndicator() else DropdownButtonFormField<Map<String,dynamic>>(value:_selected,isExpanded:true,decoration:const InputDecoration(labelText:'Equipo disponible',prefixIcon:Icon(Icons.qr_code_2)),items:_assets.map((a)=>DropdownMenuItem(value:a,child:Text('${a['code']} · ${a['brand']} ${a['model']}',overflow:TextOverflow.ellipsis))).toList(),onChanged:(v)=>setState(()=>_selected=v),validator:(v)=>v==null?'Selecciona un equipo':null),
        ]),
        _section('2','Datos del trabajador',[
          _field(_document,'DNI / documento',Icons.badge_outlined,required:true,keyboard:TextInputType.number), _field(_name,'Nombres y apellidos',Icons.person_outline,required:true),
          _field(_email,'Correo para la constancia',Icons.email_outlined,keyboard:TextInputType.emailAddress), _field(_phone,'WhatsApp',Icons.phone_outlined,keyboard:TextInputType.phone), _field(_notes,'Observaciones y accesorios entregados',Icons.notes,maxLines:3),
        ]),
        _section('3','Conformidad y evidencia',[
          const Text('Firma del trabajador',style:TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:8),
          Container(height:180,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:const Color(0xffcbd7e3))),child:Stack(children:[RepaintBoundary(key:_signatureKey,child:GestureDetector(onPanStart:(d)=>setState(()=>_points.add(d.localPosition)),onPanUpdate:(d)=>setState(()=>_points.add(d.localPosition)),onPanEnd:(_)=>_points.add(null),child:CustomPaint(painter:_SignaturePainter(_points),size:Size.infinite))),Positioned(right:4,top:4,child:IconButton(onPressed:()=>setState(()=>_points.clear()),icon:const Icon(Icons.refresh)))])),
          const SizedBox(height:12),OutlinedButton.icon(onPressed:_pickEvidence,icon:Icon(_evidence==null?Icons.add_a_photo_outlined:Icons.check_circle,color:_evidence==null?null:Colors.green),label:Text(_evidence==null?'Tomar foto del equipo':'Evidencia capturada')),
        ]),
        SizedBox(width:double.infinity,height:54,child:ElevatedButton.icon(onPressed:_saving?null:_submit,icon:_saving?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.verified_user_outlined),label:Text(_saving?'Registrando...':'Registrar entrega y generar constancia'))),const SizedBox(height:24),
      ])))),
    );
  }

  Widget _hero()=>Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xff073b4c),Color(0xff0c8f86)]),borderRadius:BorderRadius.circular(22)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.inventory_2_outlined,color:Colors.white,size:34),SizedBox(height:12),Text('Entrega digital de activos',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w800)),SizedBox(height:5),Text('Selecciona, fotografía, firma y comparte la constancia desde el celular.',style:TextStyle(color:Colors.white70,height:1.35))]));
  Widget _section(String n,String title,List<Widget> children)=>Container(margin:const EdgeInsets.only(bottom:16),padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.06),blurRadius:18,offset:const Offset(0,7))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[CircleAvatar(radius:15,backgroundColor:DonLuisColors.primary,child:Text(n,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),const SizedBox(width:10),Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800))]),const SizedBox(height:16),...children]));
  Widget _field(TextEditingController c,String label,IconData icon,{bool required=false,TextInputType? keyboard,int maxLines=1})=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextFormField(controller:c,keyboardType:keyboard,maxLines:maxLines,decoration:InputDecoration(labelText:label,prefixIcon:Icon(icon)),validator:required?(v)=>(v??'').trim().isEmpty?'Campo obligatorio':null:null));
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points); final List<Offset?> points;
  @override void paint(Canvas canvas,Size size){canvas.drawRect(Offset.zero&size,Paint()..color=Colors.white);final p=Paint()..color=const Color(0xff102a43)..strokeWidth=2.5..strokeCap=StrokeCap.round;for(var i=0;i<points.length-1;i++){if(points[i]!=null&&points[i+1]!=null)canvas.drawLine(points[i]!,points[i+1]!,p);}}
  @override bool shouldRepaint(covariant _SignaturePainter old)=>true;
}
