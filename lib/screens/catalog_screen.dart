import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const primary = Color(0xFF2D5016);
  static const secondary = Color(0xFFD4A373);

  final GlobalKey _catalogKey = GlobalKey();
  final GlobalKey<FormState> _contactFormKey = GlobalKey<FormState>();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactMessageController = TextEditingController();
  String activeFilter = 'todos';

  Future<void> _abrirAR(BuildContext context, Product p) async {
    final uri = Uri.parse(p.arUrl);

    if (kIsWeb) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    final estado = await Permission.camera.request();
    if (!estado.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Necesitas dar permiso de cámara para ver el AR.')),
        );
      }
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  IconData _iconoDe(String nombre) {
    switch (nombre) {
      case 'chair':
        return Icons.chair_alt;
      case 'table_restaurant':
        return Icons.table_restaurant;
      case 'shelves':
        return Icons.shelves;
      case 'weekend':
        return Icons.weekend;
      default:
        return Icons.chair;
    }
  }

  List<Product> get _productosFiltrados {
    if (activeFilter == 'todos') return catalogoProductos;
    return catalogoProductos.where((p) => p.material.toLowerCase().contains(activeFilter)).toList();
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.eco, color: primary, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('ECO SPACE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('VIVE DE FORMA SOSTENIBLE', style: TextStyle(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              color: const Color(0xFFF8F5F0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    backgroundColor: primary.withAlpha(31),
                    label: const Text('Economía Circular', style: TextStyle(color: Color(0xFF2D5016))),
                  ),
                  const SizedBox(height: 12),
                  const Text('Mobiliario con', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  const Text('propósito y sostenibilidad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF2D5016))),
                  const SizedBox(height: 12),
                  const Text('Descubre nuestro catálogo digital de muebles fabricados con materiales reciclados.', style: TextStyle(color: Color(0xFF6b6b6b))),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _scrollToCatalog(context),
                        style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                          child: Text('Ver catálogo', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _showEducativo,
                        style: OutlinedButton.styleFrom(side: BorderSide(color: primary.withAlpha(31)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                          child: Text('Leer más'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _heroStats(),
            ),
          ),
          SliverToBoxAdapter(
            key: _catalogKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _filterChip('todos', 'Todos'),
                  _filterChip('plástico', '♻️ Plástico'),
                  _filterChip('madera', '🌳 Madera'),
                  _filterChip('cartón', '📦 Cartón'),
                  _filterChip('metal', '🔩 Metal'),
                  _filterChip('textil', '🧵 Textil'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('${_productosFiltrados.length} productos encontrados', style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final p = _productosFiltrados[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _productCard(context, p),
                  );
                },
                childCount: _productosFiltrados.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _educationSection(),
                const SizedBox(height: 24),
                _contactSection(),
                const SizedBox(height: 24),
                _footerSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, Product p) {
    return InkWell(
      onTap: () => _showCotizador(p),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: const Color(0xFFE8E0D5),
              ),
              child: Center(child: Icon(_iconoDe(p.icono), size: 48, color: secondary)),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(p.precio, style: const TextStyle(color: primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Material: ${p.material}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text('Ver AR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () => _abrirAR(context, p),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Cotizar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary.withAlpha(31)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () => _showCotizador(p),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStats() {
    final stats = [
      {'value': '1,200+', 'label': 'Piezas sostenibles'},
      {'value': '85%', 'label': 'Materiales reciclados'},
      {'value': '5', 'label': 'Categorías verdes'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.map((stat) => Expanded(child: _heroStatCard(stat))).toList(),
          );
        }

        final cardWidth = constraints.maxWidth >= 600 ? (constraints.maxWidth - 12) / 2 : double.infinity;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: stats.map((stat) {
            return SizedBox(width: cardWidth, child: _heroStatCard(stat));
          }).toList(),
        );
      },
    );
  }

  Widget _heroStatCard(Map<String, String> stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(stat['value']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 10),
          Text(stat['label']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.35)),
        ],
      ),
    );
  }

  Widget _educationSection() {
    final cards = [
      {
        'icon': Icons.recycling,
        'title': '¿Qué es la Economía Circular?',
        'description': 'Un modelo que mantiene recursos en uso el mayor tiempo posible, recuperando materiales al final de su vida útil. Aquí explicamos cómo reutilizar y rediseñar para alargar la vida de los productos.',
      },
      {
        'icon': Icons.autorenew,
        'title': 'De residuo a recurso',
        'description': 'Plástico, madera, cartón y textil pueden transformarse en muebles de alta calidad. Te contamos procesos y ejemplos de reciclaje industrial y artesanal.',
      },
      {
        'icon': Icons.eco,
        'title': 'Impacto ambiental',
        'description': 'El mobiliario sostenible reduce la huella de CO₂ y protege el planeta. Mostramos comparativas, indicadores y pequeñas acciones con gran impacto.',
      },
      {
        'icon': Icons.handshake,
        'title': 'Tu aporte',
        'description': 'Elige muebles reciclados, repara en lugar de desechar y contribuye a una economía circular. Inspírate con casos reales y recomendaciones prácticas.',
      },
    ];

    return LayoutBuilder(builder: (context, constraints) {
      // On wide screens show a row of equally sized cards, on medium use two columns, on small use full width
      double maxWidth = constraints.maxWidth;
      int columns = 1;
      if (maxWidth >= 1000) {
        columns = 4;
      } else if (maxWidth >= 700) {
        columns = 2;
      } else {
        columns = 1;
      }

      final cardWidth = (maxWidth - (12 * (columns - 1))) / columns;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aprende', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Economía Circular y reciclaje', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards.map((card) {
                return SizedBox(width: cardWidth, child: _educationCard(card));
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _educationCard(Map<String, dynamic> card) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color.fromRGBO(53, 116, 61, 0.12),
                child: Icon(card['icon'], color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(card['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card['description'],
            style: const TextStyle(color: Colors.black54, fontSize: 13),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showEducationDetail(card['title'] as String, card['description'] as String),
              child: const Text('Ver más'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEducationDetail(String title, String description) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(description),
                    const SizedBox(height: 16),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar'))),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  Widget _contactSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contacto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Solicita tu cotización o cuéntanos tu proyecto sostenible.', style: TextStyle(color: Colors.black54, fontSize: 15)),
          const SizedBox(height: 18),
          Form(
            key: _contactFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _contactNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    filled: true,
                    fillColor: const Color(0xFFF4F2EE),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFFF4F2EE),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Ingresa un email válido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    filled: true,
                    fillColor: const Color(0xFFF4F2EE),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactMessageController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Mensaje',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: const Color(0xFFF4F2EE),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Cuéntanos brevemente tu idea' : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Enviar mensaje'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitContact() {
    if (_contactFormKey.currentState?.validate() ?? false) {
      final name = _contactNameController.text.trim();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gracias $name, recibimos tu mensaje.')));
      _contactNameController.clear();
      _contactEmailController.clear();
      _contactPhoneController.clear();
      _contactMessageController.clear();
    }
  }

  Widget _footerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('ECO SPACE', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Mobiliario sostenible y experiencias AR para tu hogar y oficina.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 16),
          Text('Contacto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('eco.space@contacto.com', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 4),
          Text('+51 987 654 321', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final active = activeFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => setState(() => activeFilter = key),
      selectedColor: primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: active ? Colors.white : Colors.black),
    );
  }

  void _scrollToCatalog(BuildContext context) {
    // Scroll to the catalog grid using the catalog key
    final ctx = _catalogKey.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
  }

  void _showEducativo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sobre Eco Space'),
        content: const Text('Eco Space muestra mobiliario sostenible y permite previsualizar piezas en AR. Usa "Ver AR" para abrir la experiencia en el navegador del dispositivo.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showCotizador(Product p) {
    final cotizadorFormKey = GlobalKey<FormState>();
    final cotNombreController = TextEditingController();
    final cotEmailController = TextEditingController();
    final cotTelefonoController = TextEditingController();
    final cotMensajeController = TextEditingController();
    String cotCantidad = '1';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Cotizar: ${p.nombre}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F2EE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: secondary.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(_iconoDe(p.icono), size: 28, color: secondary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text(p.material, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                const SizedBox(height: 8),
                                Text(p.precio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🌱 Impacto ambiental de tu compra', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          _impactRow('Material reciclado', p.reciclado),
                          _impactRow('Índice de sostenibilidad', p.sostenibilidad),
                          _impactRow('CO₂ ahorrado vs tradicional', p.co2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Form(
                      key: cotizadorFormKey,
                      child: Column(
                        children: [
                          _formGroup(label: 'Nombre completo *', child: TextFormField(
                            controller: cotNombreController,
                            decoration: const InputDecoration(hintText: 'Tu nombre'),
                            validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu nombre' : null,
                          )),
                          _formGroup(label: 'Correo electrónico *', child: TextFormField(
                            controller: cotEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(hintText: 'tu@email.com'),
                            validator: (value) => (value == null || !value.contains('@')) ? 'Ingresa un email válido' : null,
                          )),
                          _formGroup(label: 'Teléfono', child: TextFormField(
                            controller: cotTelefonoController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(hintText: '+51 9 1234 5678'),
                          )),
                          _formGroup(label: 'Cantidad', child: DropdownButtonFormField<String>(
                            initialValue: cotCantidad,
                            items: const [
                              DropdownMenuItem(value: '1', child: Text('1 unidad')),
                              DropdownMenuItem(value: '2', child: Text('2 unidades')),
                              DropdownMenuItem(value: '3', child: Text('3 unidades')),
                              DropdownMenuItem(value: '4', child: Text('4 unidades')),
                              DropdownMenuItem(value: '5', child: Text('5+ unidades')),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => cotCantidad = value);
                            },
                          )),
                          _formGroup(label: 'Mensaje o especificaciones', child: TextFormField(
                            controller: cotMensajeController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(hintText: 'Color, medidas, personalización...'),
                          )),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.send),
                              label: const Text('Enviar cotización'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                if (cotizadorFormKey.currentState?.validate() ?? false) {
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('¡Cotización solicitada para ${p.nombre} x$cotCantidad!')),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _impactRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: primary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _formGroup({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0D8CE)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
