import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:trabajo_integrador_flutter/src/state/ingredientes_controller.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';
import 'package:trabajo_integrador_flutter/src/utils/error_ia.dart';

class ScanPage extends StatefulWidget {
  final IngredientesController controller;

  const ScanPage({super.key, required this.controller});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imagen;
  XFile? _foto;
  bool _cargando = false;
  bool _analizando = false;

  Future<void> _abrirCamara() async {
    if (_cargando || _analizando) return;

    setState(() => _cargando = true);

    try {
      var permiso = await Permission.camera.status;

      if (permiso.isDenied) {
        permiso = await Permission.camera.request();
      }

      if (!mounted) return;

      if (permiso.isPermanentlyDenied || permiso.isRestricted) {
        _mostrarMensaje(
          'El acceso a la cámara está bloqueado. '
          'Revisá los permisos en la configuración.',
        );

        if (permiso.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }

      if (!permiso.isGranted) {
        _mostrarMensaje(
          'Necesitás permitir el acceso a la cámara para escanear.',
        );
        return;
      }

      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 80,
      );

      if (!mounted || foto == null) return;

      final bytes = await foto.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imagen = bytes;
        _foto = foto;
      });
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('No se pudo abrir la cámara. Intentá nuevamente.');
        debugPrint('Error al abrir la cámara: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _analizarFoto() async {
    final foto = _foto;
    if (foto == null || _analizando) return;

    setState(() => _analizando = true);
    try {
      final nuevos = await widget.controller.agregarDesdeFoto(foto);
      if (!mounted) return;
      _mostrarMensaje(
        nuevos > 0
            ? 'Agregué $nuevos ingrediente(s) a tu lista'
            : 'No detecté ingredientes nuevos',
      );
    } catch (e) {
      debugPrint('ERROR IA: $e');
      if (mounted) _mostrarMensaje(mensajeErrorIa(e));
    } finally {
      if (mounted) setState(() => _analizando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.dark,
        ),
      );
  }

  void _eliminarFoto() {
    setState(() {
      _imagen = null;
      _foto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ocupado = _cargando || _analizando;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Qué hay en casa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escaneá tus ingredientes',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sacá una foto de los alimentos que tenés '
                'y preparate para descubrir nuevas recetas.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Vista previa de la foto.
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagen == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 76,
                            color: AppColors.darkGreenText,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tu foto aparecerá aquí',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Enfocá bien los alimentos',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Image.memory(
                        _imagen!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
              ),

              const SizedBox(height: 24),

              // Botón para tomar una foto.
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: ocupado ? null : _abrirCamara,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.green.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera_alt_rounded),
                  label: Text(
                    _cargando
                        ? 'Abriendo cámara...'
                        : _imagen == null
                            ? 'Abrir cámara'
                            : 'Volver a escanear',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (_imagen != null) ...[
                const SizedBox(height: 12),

                // Botón para analizar la foto con IA.
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: ocupado ? null : _analizarFoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.dark.withOpacity(0.5),
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _analizando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _analizando ? 'Analizando...' : 'Detectar ingredientes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: ocupado ? null : _eliminarFoto,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar foto'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}