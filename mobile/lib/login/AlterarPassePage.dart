import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class AlterarPassePage extends StatefulWidget {
  final String email;
  final String code;
  const AlterarPassePage({super.key, required this.email, required this.code});

  @override
  State<AlterarPassePage> createState() => _AlterarPassePageState();
}

class _AlterarPassePageState extends State<AlterarPassePage> {
  bool showPass1 = false;
  bool showPass2 = false;

  bool field1Selected = false;
  bool field2Selected = false;
  bool aCarregar = false;

  bool matches = false;
  String matchMessage = '';
  Color matchMessageColor = Colors.transparent;

  final TextEditingController pass1Controller = TextEditingController();
  final TextEditingController pass2Controller = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    pass1Controller.addListener(_updateMatchStatus);
    pass2Controller.addListener(_updateMatchStatus);
  }

  void _updateMatchStatus() {
    final p1 = pass1Controller.text;
    final p2 = pass2Controller.text;
    if (p1.isNotEmpty && p2.isNotEmpty) {
      if (p1 == p2) {
        matches = true;
        matchMessage = 'As palavras-passe coincidem.';
        matchMessageColor = const Color(0xFF2ECC71); // verde
      } else {
        matches = false;
        matchMessage = 'As palavras-passe não coincidem.';
        matchMessageColor = const Color(0xFFE74C3C); // vermelho
      }
    } else {
      matches = false;
      matchMessage = '';
      matchMessageColor = Colors.transparent;
    }
    if (mounted) setState(() {});
  }

  Future<void> _alterarPasse() async {
    final p1 = pass1Controller.text;
    final p2 = pass2Controller.text;

    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As palavras-passe não coincidem.")),
      );
      return;
    }

    // Fechar teclado antes de enviar
    FocusScope.of(context).unfocus();
    setState(() => aCarregar = true);

    try {
      final sucesso = await _apiService.resetPassword(widget.email, widget.code, p1);
      if (sucesso) {
        mostrarPopupSucesso();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao alterar palavra-passe.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.isNotEmpty ? msg : "Erro de ligação ao servidor.")),
        );
      }
    } finally {
      if (mounted) setState(() => aCarregar = false);
    }
  }

  void mostrarPopupSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 280,
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4F8E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2ECC71),
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Sucesso!",
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2ECC71),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "A palavra-passe foi alterada com sucesso!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF907041),
                        Color(0xFF97774D),
                        Color(0xFFA68A69),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Alterar palavra-passe",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Palavra-passe nova",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      campoPassword(
                        controller: pass1Controller,
                        show: showPass1,
                        selected: field1Selected,
                        onSelect: () => setState(() {
                          field1Selected = true;
                          field2Selected = false;
                        }),
                        onToggle: () => setState(() => showPass1 = !showPass1),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Confirmar palavra-passe nova",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      campoPassword(
                        controller: pass2Controller,
                        show: showPass2,
                        selected: field2Selected,
                        onSelect: () => setState(() {
                          field2Selected = true;
                          field1Selected = false;
                        }),
                        onToggle: () => setState(() => showPass2 = !showPass2),
                        borderColor: matches
                            ? const Color(0xFF2ECC71)
                            : (field2Selected
                                ? const Color(0xFFB49B6D)
                                : Colors.black26),
                        bgColor: matches ? const Color(0xFFE9F7EF) : null,
                      ),
                      if (matchMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          matchMessage,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            color: matchMessageColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: aCarregar ? null : _alterarPasse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: aCarregar
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  "Alterar palavra-passe",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF907041),
                        Color(0xFF97774D),
                        Color(0xFFA68A69),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contactos Clinimolelos",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Contacto telefónico",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "232 823 220",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Correio eletrónico",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                    ),
                  ),
                  Text(
                    "clinimolelos@gmail.com",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

Widget campoPassword({
  required TextEditingController controller,
  required bool show,
  required bool selected,
  required VoidCallback onToggle,
  required VoidCallback onSelect,
  Color? borderColor,
  Color? bgColor,
}) {
  return GestureDetector(
    onTap: onSelect,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: bgColor ?? (selected ? const Color(0xFFF1EFEA) : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 2,
          color: borderColor ?? (selected ? const Color(0xFFB49B6D) : Colors.black26),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !show,
              cursorColor: const Color(0xFFB49B6D),
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onTap: onSelect,
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              show ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
          )
        ],
      ),
    ),
  );
}
}
