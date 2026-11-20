import 'package:flutter/material.dart';
import 'package:trabajo_integrador_flutter/src/state/ingredientes_controller.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';
import 'package:trabajo_integrador_flutter/src/widgets/lista_ingredientes.dart';
import 'package:trabajo_integrador_flutter/src/widgets/boton_generar_receta.dart';

class InicioPage extends StatefulWidget {
  final IngredientesController ingredientes;
  final VoidCallback onEscanear;

  const InicioPage({
    super.key,
    required this.ingredientes,
    required this.onEscanear,
  });

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  
  static const double _altoBarraInferior = 80;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _mostrarInput = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.dark,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _agregar() {
    final texto = _controller.text.trim();

    if (texto.isEmpty) {
      _mensaje('Escribí el nombre de un ingrediente');
      return;
    }

    if (widget.ingredientes.agregar(texto)) {
      setState(() {
        _controller.clear();
        _mostrarInput = false;
      });
    } else {
      _mensaje('"$texto" ya está en tu lista');
    }
  }


  void _alternarInput() {
    setState(() {
      _mostrarInput = !_mostrarInput;
    });

    if (_mostrarInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final altoPantalla = MediaQuery.sizeOf(context).height;
    final tecladoAlto = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

   
    final altoImagen = (altoPantalla * 0.27).clamp(170.0, 260.0);

    
    final paddingInferior =
        24.0 + _altoBarraInferior + safeBottom + tecladoAlto;

    return Column(
      children: [
       
        Container(
          width: double.infinity,
          color: AppColors.dark,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: const Text(
            'SnapChef',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),

        
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(20, 20, 20, paddingInferior),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                const Text(
                  'TU COCINA, MÁS CREATIVA',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '¿Qué tenés en tu cocina?',
                  style: TextStyle(
                    color: AppColors.dark,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Agregá ingredientes y descubrí nuevas recetas.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),
                
                // Imagen principal
                _imagenPrincipal(altoImagen),

                const SizedBox(height: 16),

                // Contador de ingredientes
                _contador(),

                if (_mostrarInput) ...[
                  const SizedBox(height: 12),
                  _campoIngrediente(),
                ],

                const SizedBox(height: 18),


                // Acciones principales
                _botones(),
                const SizedBox(height: 18),
                BotonGenerarReceta(ingredientes: widget.ingredientes),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagenPrincipal(double alto) {
    return Container(
      height: alto,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/imagenApp.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 44,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Descubrí nuevas recetas',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _contador() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => mostrarListaIngredientes(
          context,
          widget.ingredientes,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedBuilder(
            animation: widget.ingredientes,
            builder: (context, _) {
              final cantidad = widget.ingredientes.cantidad;

              return Row(
                children: [
                  const Icon(
                    Icons.kitchen_rounded,
                    color: AppColors.green,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cantidad == 0
                              ? 'Tus ingredientes'
                              : 'Tus ingredientes ($cantidad)',
                          style: const TextStyle(
                            color: AppColors.dark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cantidad == 0
                              ? 'Todavía no agregaste ingredientes'
                              : 'Tocá para ver tu lista',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.green,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _campoIngrediente() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _agregar(),
            decoration: InputDecoration(
              labelText: 'Nombre del ingrediente',
              prefixIcon: const Icon(
                Icons.eco_outlined,
                color: AppColors.green,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _agregar,
              child: const Text('Guardar ingrediente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botones() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _alternarInput,
            icon: Icon(
              _mostrarInput ? Icons.close : Icons.add,
              size: 21,
            ),
            label: Text(
              _mostrarInput ? 'Cancelar' : 'Agregar',
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: widget.onEscanear,
            icon: const Icon(Icons.camera_alt_rounded, size: 21),
            label: const Text(
              'Escanear',
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}