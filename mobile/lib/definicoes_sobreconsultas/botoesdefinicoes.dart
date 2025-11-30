import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SettingsButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,

      // Remove todos os efeitos escuros quando o rato passa ou clica
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,

      child: Container(
        padding: const EdgeInsets.all(20),           // Espaço interno do botão
        margin: const EdgeInsets.symmetric(vertical: 15), // Espaço externo entre botões

        decoration: BoxDecoration(
          color: Colors.white,                       // Fundo branco 

          borderRadius: BorderRadius.circular(3),     // Cantos quadrados 

          border: Border.all(                        // Borda igual aos outros botões
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),  // Cor da sombra
              blurRadius: 4,                          // Suavidade da sombra
              offset: const Offset(0, 2),             // Deslocamento vertical da sombra
            ),
          ],
        ),

        // Conteúdo do botão
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black87), // Ícone
            const SizedBox(width: 16),                  // Espaço entre ícone e texto

            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
