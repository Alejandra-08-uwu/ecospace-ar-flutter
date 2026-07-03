import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// `ARViewerScreen` soporta dos modos:
/// - Web (kIsWeb): abre la URL AR en el navegador externo.
/// - Móvil (Android/iOS): intenta abrir la URL dentro de un WebView
///   después de pedir permiso de cámara.
class ARViewerScreen extends StatefulWidget {
  final String url;
  final String nombreProducto;

  const ARViewerScreen({super.key, required this.url, required this.nombreProducto});

  @override
  State<ARViewerScreen> createState() => _ARViewerScreenState();
}

class _ARViewerScreenState extends State<ARViewerScreen> {
  WebViewController? _controller;
  bool _cargando = true;
  bool _permisoDenegado = false;

  @override
  void initState() {
    super.initState();
    // Si es web, o iOS, no inicializamos el WebView; la UI mostrará un botón
    // que abre Safari (getUserMedia funciona mejor en Safari que en WebView).
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.iOS) _inicializar();
  }

  Future<void> _inicializar() async {
    final estado = await Permission.camera.request();
    if (!estado.isGranted) {
      setState(() => _permisoDenegado = true);
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _cargando = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // Evitar referencias a tipos Android concretos en tiempo de compilación web.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final dynamic androidController = controller.platform;
      try {
        androidController.setMediaPlaybackRequiresUserGesture(false);
        androidController.setOnPlatformPermissionRequest((request) {
          request.grant();
        });
      } catch (_) {}
    }

    setState(() => _controller = controller);
  }

  Future<void> _abrirEnNavegador() async {
    final uri = Uri.parse(widget.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) {
      return Scaffold(
        appBar: AppBar(title: Text('AR: ${widget.nombreProducto}')),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Abrir en navegador (WebAR)'),
            onPressed: _abrirEnNavegador,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('AR: ${widget.nombreProducto}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _permisoDenegado
          ? _mensajePermisoDenegado()
          : Stack(
              children: [
                if (_controller != null) WebViewWidget(controller: _controller!),
                if (_cargando || _controller == null)
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
              ],
            ),
    );
  }

  Widget _mensajePermisoDenegado() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Necesitamos acceso a tu cámara para mostrar el objeto en Realidad Aumentada.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              child: const Text('Abrir configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
