import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar un mensaje de ayuda al inicio de una lista.
/// Ejemplo: “Toca para editar / + para crear”.
class HintBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const HintBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.primaryContainer.withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: c.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
