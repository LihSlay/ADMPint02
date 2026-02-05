import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IniciarSessaoPage extends StatefulWidget {
  const IniciarSessaoPage({super.key});

  @override
  State<IniciarSessaoPage> createState() => _IniciarSessaoPageState();
}

class _IniciarSessaoPageState extends State<IniciarSessaoPage> {
  int selectedField = -1;
  bool forgotPressed = false;
  bool aCarregar = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final ApiService _apiService = ApiService();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();

  bool mostrarPasse = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, preencha todos os campos")),
        );
      }
      return;
    }

    setState(() => aCarregar = true);

    try {
      final usuario = await _apiService.login(
        emailController.text,
        passController.text,
      );

      if (usuario != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt('id_perfis', usuario.idPerfis ?? 0);

        await prefs.setInt('id_utilizadores', usuario.idUtilizadores);

        final idPerfis = usuario.idPerfis ?? 0;
        bool jaAssinado =
            (usuario.termosAssinados == 1 ||
            usuario.termosAssinados == true ||
            usuario.termosAssinados == 'assinado');

        if (!jaAssinado) {
          jaAssinado = await _apiService.verificarConsentimentoLocal(idPerfis);
        }

        if (jaAssinado) {
          if (mounted) context.go('/inicio');
        } else {
          if (mounted) context.go('/termos_condicoes_login', extra: idPerfis);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Credenciais inválidas")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao conectar ao servidor")),
        );
      }
    } finally {
      if (mounted) setState(() => aCarregar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  Center(
                    child: Image.asset(
                      'assets/images/logoclinica.png',
                      width: MediaQuery.of(context).size.width * 0.50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Iniciar sessão",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF907041),
                            Color(0xFF97774D),
                            Color(0xFFA68A69),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          const Text(
                            "Email",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: selectedField == 0
                                  ? const Color(0xFFF1EFEA)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: emailController,
                              focusNode: emailFocus,
                              onTap: () => setState(() => selectedField = 0),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "email@gmail.com",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Palavra-passe",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: selectedField == 1
                                  ? const Color(0xFFF1EFEA)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: passController,
                              focusNode: passFocus,
                              onTap: () => setState(() => selectedField = 1),
                              obscureText: !mostrarPasse,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    mostrarPasse
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: const Color(0xFF907041),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      mostrarPasse = !mostrarPasse;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTapDown: (_) =>
                                  setState(() => forgotPressed = true),
                              onTapUp: (_) {
                                setState(() => forgotPressed = false);
                                context.push('/esqueceu_email');
                              },
                              onTapCancel: () =>
                                  setState(() => forgotPressed = false),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 120),
                                opacity: forgotPressed ? 0.4 : 1.0,
                                child: const Text(
                                  "Esqueceu-se da sua palavra-passe?",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: aCarregar ? null : _fazerLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
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
                                        color: Color(0xFFB49B6D),
                                      ),
                                    )
                                  : const Text(
                                      "Entrar",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
