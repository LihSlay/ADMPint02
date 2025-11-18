import 'package:flutter/material.dart';

class IniciarSessaoPage extends StatefulWidget {
  const IniciarSessaoPage({super.key});

  @override
  State<IniciarSessaoPage> createState() => _IniciarSessaoPageState();
}

class _IniciarSessaoPageState extends State<IniciarSessaoPage> {
  int selectedField = -1; 
  bool forgotPressed = false;

  final FocusNode emailFocus = FocusNode();
  final FocusNode passFocus = FocusNode();

  bool mostrarPasse = false; 

  @override
  void dispose() {
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            Center(
              child: Image.asset(
                'assets/images/logoclinica.png',
                width: 200,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),

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
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),

                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),

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
                          focusNode: passFocus,
                          onTap: () => setState(() => selectedField = 1),

                          obscureText: !mostrarPasse,
                          style: const TextStyle(color: Colors.black),

                          decoration: InputDecoration(
                            hintText: "••••••••••",
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
                          onTapDown: (_) => setState(() => forgotPressed = true),
                          onTapUp: (_) {
                            setState(() => forgotPressed = false);
                            Navigator.pushNamed(context, '/esqueceu_email');
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/termos_condicoes');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text(
                            "Entrar",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
